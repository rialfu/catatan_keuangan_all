import { Body, Controller, Get, HttpCode, HttpException, HttpStatus, Logger, Post, Request, Res, UseGuards, UseInterceptors } from '@nestjs/common';
import { AppService } from './app.service';
import { AuthGuard } from '@nestjs/passport';
import { UsersService } from './users/users.service';
import { User } from './model/user.entity';
import { RolesService } from './roles/roles.service';
import { AuthService } from './auth/auth.service';
import { HasRoles } from './auth/roles.decorator';
import { Role, RoleType } from './model/role.entity';
import { RolesGuard } from './auth/roles.guard';
import { CreateUserDTO } from './model/user.dto';
import { UserJWT } from './model/user_jwt.dto';
import { SkipThrottle, Throttle, ThrottlerGuard, ThrottlerStorageService } from '@nestjs/throttler';
import * as admin from "firebase-admin"
import { UserToken } from './model/user_token.entity';
@Controller()
export class AppController {
  constructor(
    private readonly appService: AppService, 
    private readonly userService: UsersService, 
    private readonly roleService: RolesService,
    private readonly authService: AuthService,
  ) {}

  @Get('/')
  getHello(): any[] {
    return ['gak ', parseInt(process.env.PORT_DB || '3306') ||'gk nemu prot', process.env.USERNAME_DB||'asdads', process.env.PASS_DB || 'adas',process.env.DB||'db'];return ['gak ', parseInt(process.env.PORT_DB || '3306') ||'gk nemu prot', process.env.USERNAME_DB||'asdads', process.env.PASS_DB || 'adas',process.env.DB||'db'];
  }
  @Post('/test')
  // @Throttle({ default: { limit: 1, ttl: 30000 } })
  async test(): Promise<any> {
    const response = await admin.messaging().send({
      token:'eLNUb75sTwKv5vIeRtZY1b:APA91bE-GXIKTPWVTTtDwqDyGpvet0FFKcp_YY9uhUxWETKH36vyVe4wVBLF9ZM8yOPmPaYgUN0XNKdJMh9o_dbbyQ4rvTYcuNCUZNWJUJX_AWXofI9mu2E',
      notification:{
        title: 'Notification Title',
        body: 'Notification body',
      }
      
    });
    console.log(response)
    return {'message':'success1'};
    // try{
    //   const RoleAdmin = await this.roleService.findRole('admin')
    //   if (RoleAdmin == null){
    //     return ['not found']
    //   }
    //   const data: Partial<User> ={
    //     // username:'admin@test.com',
    //     email:'admin@test.com',
    //     password:'123456',
    //     name:'rema',
    //     role:RoleAdmin,
    //   }
    //   await this.userService.create(data)
    //   return 'work'
    // }catch(err){
    //   Logger.error('error')
    //   return 'error'
    //   return err
    // }
    
  }
  
  
  @SkipThrottle()
  @Post('/create-account')
  async create_account(@Request() req, @Body() body:CreateUserDTO){
    console.log('create-')
    const exist = await this.userService.findOne(body.email)
    if(exist != null){
      throw new HttpException({'message':['Email has used']}, 400);
    }
    // const role = await this.roleService.findRole('user')
    // if(role == null){
    //   throw new HttpException({'message':'Error something'}, 500);
    // }
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
          console.log('1')
          await this.userService.update_token_user(tokenInDb, tokenInDb.id)
        }else{
          userToken = new UserToken()
          userToken.fcm_token = token      
          userToken.user = user
          let date = new Date()
          date = new Date(new Date(date).setMonth(date.getMonth() + 8));
          userToken.expired_date = this.formatDate(date)
          console.log('2')
          await this.userService.insert_token_user(userToken)
        }
       
      }else{
        if(tokenInDb == null){
          console.log('3')
          userToken.fcm_token = token
          let date = new Date()
          date = new Date(new Date(date).setMonth(date.getMonth() + 8));
          userToken.expired_date = this.formatDate(date)
          await this.userService.update_token_user(userToken, userToken.id)
          
        }else{
          if( userToken.id == tokenInDb.id){
            console.log('4')
            let date = new Date()
            date = new Date(new Date(date).setMonth(date.getMonth() + 8));
            userToken.expired_date = this.formatDate(date)
            await this.userService.update_token_user(userToken, userToken.id)
          }else{
            console.log('5')
          }
        }
        
      }

      // const userToken : Partial<UserToken> = new UserToken()
      // userToken.fcm_token = token
      // console.log(res)
      // // console.log(req)
      // if(res != null){
      //   console.log('update')
      //   // userToken.id = res.id
      //   // await this.userService.update_token_user(userToken, req.user.id)
      // }else{
      //   console.log('insert')
      //   const user = new User()
      //   user.id = req.user.id
      //   userToken.user = user
      //   // await this.userService.insert_token_user(userToken)
      // }
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
  
}
