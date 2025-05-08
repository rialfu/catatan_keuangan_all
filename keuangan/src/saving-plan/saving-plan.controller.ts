import { Body, Controller, Delete, Get, HttpException, HttpStatus, Param, Post, Put, Request, UseGuards } from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import { SavingPlanService } from './saving-plan.service';
import { SavingPlan } from 'src/model/saving_plan.entity';
import { CreateSavingPlanCheckoutDTO, CreateSavingPlanDTO, UpdateSavingPlanDTO } from 'src/model/saving_plan.dto';
import { User } from 'src/model/user.entity';
import { UserJWT } from 'src/model/user_jwt.dto';
import { AuthGuard } from '@nestjs/passport';
import { SavingPlanCheckout } from 'src/model/saving_plan_checkout_entity';
import { InjectUserToBody } from 'src/config/apply_decorator';

// @SkipThrottle()
@Controller('saving-plan')
export class SavingPlanController {
    constructor(
        private readonly savingPlanService: SavingPlanService, 
        
    ) {}
    @Get('/sample')
    async get_data(){
        const res = await this.savingPlanService.get_data();
        return {'result':res}
    }

    @Get('dummy')
    async get_data_dummy(@Request() req,) {
        console.log('test')
        let data = new SavingPlan()
        data.name = 'beli tv'
        data.type_reminder = 'monthly'
        data.date_reminder = '31'
        data.target_date = '2025-06-03'
        data.target_money = 2000000
        const user = new User()
        user.id = 'a858bd9b-7c44-45cf-ac2e-ab0acfa9ef23'
        data.user = user

        let res = await this.savingPlanService.create(data)
        const svc1 = new SavingPlanCheckout()
        svc1.savingPlan = res
        svc1.money = 100000
        svc1.date_checkout = '2025-03-31'
        this.savingPlanService.save_checkout(svc1)
        const svc2 = new SavingPlanCheckout()
        svc2.savingPlan = res
        svc2.money = 100000
        svc2.date_checkout = '2025-03-31'
        this.savingPlanService.save_checkout(svc1)


        data = new SavingPlan()
        data.name = 'beli tv'
        data.type_reminder = 'weekly'
        data.date_reminder = 'monday'
        data.target_date = '2025-06-15'
        data.target_money = 2000000
        // const user = new User()
        // user.id = 'a858bd9b-7c44-45cf-ac2e-ab0acfa9ef23'
        data.user = user
        res = await this.savingPlanService.create(data)

        data = new SavingPlan()
        data.name = 'beli tv'
        data.type_reminder = 'daily'
        // data.date_reminder = 'monday'
        data.target_date = '2025-06-15'
        data.target_money = 2000000
        // const user = new User()
        // user.id = 'a858bd9b-7c44-45cf-ac2e-ab0acfa9ef23'
        data.user = user
        res = await this.savingPlanService.create(data)


    }
    // Get('dummy')
    // get_setData(@Request() req,){

    // }

    @Get('/')
    @UseGuards(AuthGuard('jwt'))
    async get(@Request() req){
        const userData: UserJWT = req.user
        const res = await this.savingPlanService.get_data_with_search(
            {
                user:{
                    id:userData.userId
                }
            }, 
            {
                checkout:true
            }
        );
       return {'data':res, 'message':'berhasil'};
    }
    @Post('create')
    @UseGuards(AuthGuard('jwt'))
    @InjectUserToBody()
    async create(@Body() body:CreateSavingPlanDTO, @Request() req,){
        const userData: UserJWT = req.user

        const data = new SavingPlan()
        data.name = body.name
        data.type_reminder = body.type_reminder
        data.date_reminder = body.date_reminder
        data.target_date = body.target_date
        data.target_money = body.target_money
        data.notification = body.notification

        const user = new User()
        user.id = userData.userId
        data.user = user
        await this.savingPlanService.create(data)
        return {'message':'berhasil', 'result':data}
        // 
    }
    @Put('update')
    @UseGuards(AuthGuard('jwt'))
    @InjectUserToBody()
    async Update(@Body() body:UpdateSavingPlanDTO, @Request() req,){
        const userData: UserJWT = req.user
        const tx = await this.savingPlanService.get_single_data_with_custom(
            {
                'id': body.id,
                'userId':userData.userId,
            }
        )
        if(tx == null){
            throw new HttpException({'message':'please use another saving plan'}, 422);
        }
        
        const data : Partial<SavingPlan> = new SavingPlan()
        data.name = body.name
        data.type_reminder = body.type_reminder
        data.date_reminder = body.date_reminder
        data.target_date = body.target_date
        data.target_money = body.target_money
        
        
        if(tx['isAchiveTarget'] == '1' || tx['isAchiveTarget'] == true){
            throw new HttpException({'message':'target is achive, notification can\'t active'}, 422);
            
        }else{
            data.notification = body.notification
        }
        
        await this.savingPlanService.update(data, body.id)

        return {'message':'berhasil', 'result':data}
        // this.savingPlanService.create(data)
    }
    @Delete('/delete/:id')
    @UseGuards(AuthGuard('jwt'))
    async delete_transaction(@Request() req, @Param('id') id: string): Promise<any>{
        const userData: UserJWT = req.user
        let tx = await this.savingPlanService.get_data_with_search_single({id, user:{ id: userData.userId }})
        if(tx ==null){
            throw new HttpException({'message':'please use another saving plan'}, 400);
        }
        console.log(id)
        const res = await this.savingPlanService.delete({id});
        console.log(res);
        return {'message':'success',"info":res}
    }
    @Get('checkout/:id')
    @UseGuards(AuthGuard('jwt'))
    async get_data_checkout(@Request() req, @Param('id') id: string){
        const userData: UserJWT = req.user
        let checkouts = await this.savingPlanService.get_data_checkout_with_search({
            savingPlan:{
                id,
                user:{
                    id:userData.userId
                }
            }
        },)
        return {'data':checkouts };
    }
    @Post('checkout/create')
    @UseGuards(AuthGuard('jwt'))
    async create_checkout(@Body() body:CreateSavingPlanCheckoutDTO, @Request() req,){
        const userData: UserJWT = req.user
        
        const data = new SavingPlanCheckout()
        data.date_checkout = body.date_checkout
        data.money = body.money
        const res = await this.savingPlanService.process_create_checkout(data, body.id_saving_plan, userData.userId);
        if(res['result'] == false){
            throw new HttpException({'message':res['message']}, res['code']);
        }

        return {'message':'berhasil', 'result':res['data']}
        // this.savingPlanService.create(data)
    }
    @Delete('/checkout/delete/:id')
    @UseGuards(AuthGuard('jwt'))
    async Update_checkout(@Request() req, @Param('id') id: string){
        const userData: UserJWT = req.user
        let idCheckout:number = 0
        try{
            idCheckout = parseInt(id)
        }catch(err){
            throw new HttpException({'message':'please fix'}, 500);
        }
        let tx = await this.savingPlanService.get_data_checkout_with_search_single(
            {
                id:idCheckout, 
                
            },{
                savingPlan:{
                    user:true
                }
            })
        if(tx == null || (tx?.savingPlan.user.id ?? '') != userData.userId){
            throw new HttpException({'message':'please use another checkout'}, 422);
        }
        const res = await this.savingPlanService.delete_checkout({id:idCheckout})
        return { 'message':'berhasil', "info":res }
        // this.savingPlanService.create(data)
    }
}
