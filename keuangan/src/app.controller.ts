import { BadRequestException, Body, Controller, Get, HttpCode, HttpException, HttpStatus, Ip, Logger, Post, Request, Res, UnauthorizedException, UseGuards, UseInterceptors } from '@nestjs/common';
import { AppService } from './app.service';
import { AuthGuard } from '@nestjs/passport';
import { UsersService } from './users/users.service';
import { User } from './model/user.entity';
import { RolesService } from './roles/roles.service';
import { AuthService } from './auth/auth.service';
import { HasRoles } from './auth/roles.decorator';
import { Role, RoleType } from './model/role.entity';
import { RolesGuard } from './auth/roles.guard';
import { CreateUserDTO, VerifyPasswordDTO } from './model/user.dto';
import { UserJWT } from './model/user_jwt.dto';
import { SkipThrottle, Throttle, ThrottlerGuard, ThrottlerStorageService } from '@nestjs/throttler';
import * as admin from "firebase-admin"
import { UserToken } from './model/user_token.entity';
import { CodeReset } from './users/entities/code_reset.entity';
import { generate_text } from './config/support_string';
import { after } from 'node:test';
import { MailService } from './mail/mail.service';
import { ResetPasswordDTO, SendEmailDTO } from './users/dto/reset_password.dto';
import { LogInSSODTO } from './users/dto/login_sso.dto';
import { OAuth2Client } from 'google-auth-library';
import { RegisterSSODTO } from './users/dto/register_sso.dto';
@Controller()
export class AppController {
  constructor(
    private readonly appService: AppService, 
    private readonly userService: UsersService, 
    private readonly roleService: RolesService,
    private readonly authService: AuthService,
    private readonly mailService: MailService,
  ) {}

  @Get('/')
  getHello(@Request() req, @Ip() ip){
    return {'message':req['headers']['x-forwarded-for'], 'request':req['headers']};
    // return ['gak ', parseInt(process.env.PORT_DB || '3306') ||'gk nemu prot', process.env.USERNAME_DB||'asdads', process.env.PASS_DB || 'adas',process.env.DB||'db'];return ['gak ', parseInt(process.env.PORT_DB || '3306') ||'gk nemu prot', process.env.USERNAME_DB||'asdads', process.env.PASS_DB || 'adas',process.env.DB||'db'];
  }
  @Get('test')
  // @Throttle({ default: { limit: 1, ttl: 30000 } })
  async test(): Promise<any> {
    const d = await this.appService.getHello()
    return {'message':'success1', 'data':d};
  }
  
  
  @Post('/login-sso')
  async login_sso(@Request() req, @Body() body:LogInSSODTO){
    try{
      const clientId = process.env.oauth_client_id ?? ''
      const client = new OAuth2Client(clientId)
      const tick = await client.verifyIdToken({
        idToken:body.token,
        audience:clientId,
      })

      const payload = tick.getPayload()
      if(payload == undefined || payload['email'] == undefined){
        throw new HttpException({'message':'payload empty'}, HttpStatus.INTERNAL_SERVER_ERROR);
      }
      const email = payload['email']
      let user = await this.userService.findOne(email);
      if(user == null){
        return {'register':true }
      }
      return this.authService.login(user)
      
    }catch(err){
      const errorMessage = (err.message ?? '').toLowerCase()
      if (errorMessage.includes('token used too late')) {
        throw new UnauthorizedException('Token sudah kadaluwarsa (expired)');
      } else if (errorMessage.includes('invalid token signature')) {
        throw new UnauthorizedException('Tanda tangan token tidak valid');
      } else if (errorMessage.includes('wrong number of segments')) {
        throw new BadRequestException('Format token rusak (terpotong)');
      } else {
        throw new UnauthorizedException('Verifikasi token gagal: ' + err.message);
      }
    }
  }

  @Post('/register-sso')
  async register_sso(@Request() req, @Body() body:RegisterSSODTO){
    try{
      const clientId = process.env.oauth_client_id ?? ''
      const client = new OAuth2Client(clientId)
      const tick = await client.verifyIdToken({
        idToken:body.token,
        audience:clientId,
      })

      const payload = tick.getPayload()
      if(payload == undefined || payload['email'] == undefined){
        throw new HttpException({'message':'payload empty'}, HttpStatus.INTERNAL_SERVER_ERROR);
      }
      const email = payload['email']
      let user = await this.userService.findOne(email);
      if(user == null){
        user = new User()
        user.email = email
        user.name = body.name
        user.password = body.password
        const role = new Role()
        role.id = 2
        user.role = role
        const res = await this.userService.create(user)
      }
      return this.authService.login(user)
      
    }catch(err){
      const errorMessage = (err.message ?? '').toLowerCase()
      if (errorMessage.includes('token used too late')) {
        throw new UnauthorizedException('Token sudah kadaluwarsa (expired)');
      } else if (errorMessage.includes('invalid token signature')) {
        throw new UnauthorizedException('Tanda tangan token tidak valid');
      } else if (errorMessage.includes('wrong number of segments')) {
        throw new BadRequestException('Format token rusak (terpotong)');
      } else {
        throw new UnauthorizedException('Verifikasi token gagal: ' + err.message);
      }
    }
  }

  @SkipThrottle()
  @Post('/create-account')
  async create_account(@Request() req, @Body() body:CreateUserDTO){
    console.log('create-')
    const exist = await this.userService.findOne(body.email)
    if(exist != null){
      throw new HttpException({'message':['Email has used']}, HttpStatus.BAD_REQUEST);
    }
    
    const user = new User()
    user.email = body.email
    user.name = body.name
    user.password = body.password
    const role = new Role()
    role.id = 2
    user.role = role
    const res = await this.userService.create(user)
    return {'message':'Success', 'result':res}
  }
  formatDate(date :  Date) : string{
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0'); // Months are 0-indexed
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  @UseGuards(AuthGuard('local'))
  @Post('auth/login')
  @HttpCode(HttpStatus.OK)
  async login(@Request() req) {
    const token = req['body']['fcm_token']
    if(token != undefined && (typeof token === 'string' )){
      let userToken : UserToken | null = await this.userService.get_user_token(req['user']['id'])
      const tokenInDb : UserToken | null  = await this.userService.get_token_exist(token)

      if(userToken == null){
        const user = new User()
        user.id = req.user.id
        if(tokenInDb != null){
          tokenInDb.user = user
          let date = new Date()
          date = new Date(new Date(date).setMonth(date.getMonth() + 8));
          tokenInDb.expired_date = this.formatDate(date)
          // console.log('1')
          await this.userService.update_token_user(tokenInDb, tokenInDb.id)
        }else{
          userToken = new UserToken()
          userToken.fcm_token = token      
          userToken.user = user
          let date = new Date()
          date = new Date(new Date(date).setMonth(date.getMonth() + 8));
          userToken.expired_date = this.formatDate(date)
          // console.log('2')
          await this.userService.insert_token_user(userToken)
        }
       
      }else{
        if(tokenInDb == null){
          // console.log('3')
          userToken.fcm_token = token
          let date = new Date()
          date = new Date(new Date(date).setMonth(date.getMonth() + 8));
          userToken.expired_date = this.formatDate(date)
          await this.userService.update_token_user(userToken, userToken.id)
          
        }else{
          if( userToken.id == tokenInDb.id){
            // console.log('4')
            let date = new Date()
            date = new Date(new Date(date).setMonth(date.getMonth() + 8));
            userToken.expired_date = this.formatDate(date)
            await this.userService.update_token_user(userToken, userToken.id)
          }else{
            // console.log('5')
          }
        }
      }
    }
    return this.authService.login(req.user)
  }
  
  @Get('/auth/refresh_token')
  @UseGuards(AuthGuard('jwt-refresh'))
  async refresh_token(@Request() req){
    const userData: UserJWT = req.user
    let user = await this.userService.findOne(userData.email)
    return this.authService.login(user!)
  }
  
  // @HasRoles(RoleType.User, RoleType.Admin)
  //use jwt for verify
  @UseGuards(AuthGuard('jwt'))
  @Get('/user')
  @HttpCode(HttpStatus.OK)
  async get_user_info(@Request() req){
    const userData: UserJWT = req.user
    const user_res = await this.userService.findOne(userData.email)
    if(user_res !=null){
      const {name, email,} = user_res!
      return {'message':'berhasil', 'data':{name, email, role:userData.roles} }
    }
    return {'message':'gagal', 'data':{}}
    
  }
  @UseGuards(AuthGuard('jwt'))
  @Post('auth/verify_password')
  async verify_password(@Request() req, @Body() body:VerifyPasswordDTO){
    const userData: UserJWT = req.user
    
    const user_res = await this.userService.findOneById(userData.userId)
    if(user_res == null){
      throw new HttpException({'message':['Your account not found, you can message to admin']}, HttpStatus.FORBIDDEN);
    }
    if(user_res!.password != body.password){
      throw new HttpException({'message':['Your Password is not match']}, HttpStatus.FORBIDDEN);
    }
    return {'message':'berhasil','email':user_res.email}

  }
  // @Throttle({default:{limit:3, ttl:30000}})
  @Post('auth/send-email')
  async send_email(@Request() req,@Body() body:SendEmailDTO){
    const email = body.email;
    const resUser = await this.userService.find_code_reset_from_user(email);
    if(resUser == null){
      return {'message':'Please wait, email will send'}
    }
    if(resUser.code_reset == null || resUser.code_reset == undefined){
      let now = new Date()
      let afterTwo = new Date(now)
      afterTwo.setMinutes(now.getMinutes() +2)
      const data = new CodeReset()
      data.code = '123456',
      data.expired_date = afterTwo;
      const res = await this.userService.save_code_reset(data)
      const user:Partial<User> = new User()
      user.code_reset = res
      await this.userService.update_user(user, resUser.id)
      // return {'message':'email will send'}
      return {'message':'Please wait, email will send'}
    }
    let now = new Date()
    let conditionBefore = new Date(resUser.code_reset.expired_date)
    conditionBefore.setMinutes(conditionBefore.getMinutes() - 2)
    if(((now.getTime() - conditionBefore.getTime()) / 1000 )< 30){
      return {'message':'please wait '+(30 - (now.getTime() - conditionBefore.getTime()  ) / 1000).toFixed(2)+ 's for resend code' }
    }
    now = new Date()
    const dataUpdate : Partial<CodeReset> = new CodeReset()
    dataUpdate.code = generate_text(6)
    now.setMinutes(now.getMinutes() + 2)
    dataUpdate.valid = true;
    dataUpdate.expired_date = now;
    await this.userService.update_code_reset(dataUpdate, resUser.code_reset.id)
    this.mailService.example(resUser.email, dataUpdate.code)
    return {'message':'Please wait, email will send'}
    
  }
  
  @Post('auth/reset-password')
  async reset_password(@Request() req,@Body() body:ResetPasswordDTO){
    let now = new Date()
    let pass = body.password.trim()
    const email = body.email;
    const resUser = await this.userService.find_code_reset_from_user(email);
    if(resUser == null){
      throw new HttpException({'message':'Fail change password, You don\'t have access'}, 403)
    }
    if(resUser.code_reset == null || resUser.code_reset == undefined){
      throw new HttpException({'message':'Fail change password, You don\'t have access'}, 403)
    }
    if(resUser.code_reset.expired_date.getTime() < now.getTime() ){
      throw new HttpException({'message':'Fail change password, The code is Expired or wrong'}, 403)
    }
    if(resUser.code_reset.code != body.code){
      throw new HttpException({'message':'Fail change password, The code is Expired or wrong'}, 403)
    }
    if(resUser.code_reset.valid == false){
      throw new HttpException({'message':'Fail change password, The code is Expired or wrong'}, 403)
    }
    const user:Partial<User> = new User()
    user.password = pass
    await this.userService.update_user(user, resUser.id)
    const dataUpdate : Partial<CodeReset> = new CodeReset()
    dataUpdate.valid =false;
    await this.userService.update_code_reset(dataUpdate, resUser.code_reset.id)
    return {'messsage':'Success change password'}
  }

}
