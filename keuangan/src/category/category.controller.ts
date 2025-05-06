import { Body, Controller, Delete, Get, HttpCode, HttpException, Param, Post, Put, Query, Request, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { CategoryService } from './category.service';
import { UserJWT } from 'src/model/user_jwt.dto';
import { CreateCategoryDTO, UpdateCategoryDTO } from 'src/model/category.dto';
import { Category } from 'src/model/category.entity';
import { User } from 'src/model/user.entity';
import { SkipThrottle } from '@nestjs/throttler';

@SkipThrottle()
@Controller('category')
export class CategoryController {
    constructor(
        private readonly categoryService: CategoryService, 
            
    ) {}

    @Get('/')
    @UseGuards(AuthGuard('jwt'))
    async get_list_all_category(@Request() req, @Query('date') filter_date?: string) : Promise<any>{
        const userData: UserJWT = req.user
        
        // this.transactionService.get_all_transaction_custom()
        const result = await this.categoryService.find_all_and_count_relation({ user_id:userData.userId,})
        // const result = await this.categoryService.find_multi([{userId:userData.userId, canDelete:true}, {canDelete:false}])
        return {'data':result};
    }
    
    
    @Post('/create')
    @UseGuards(AuthGuard('jwt'))
    @HttpCode(200)
    async create_category(@Request() req, @Body() data: CreateCategoryDTO): Promise<any>{
        // try{
        const userData: UserJWT = req.user
        const cat = new Category()
        cat.category_name = data.category_name
        console.log(cat);
        const user = new User()
        user.id = userData.userId

        cat.user = user
        // cat.canDelete
        const res = await this.categoryService.create_category(cat);
        return {'message':'success', 'result':cat}
    }
    @Put('/update')
    @UseGuards(AuthGuard('jwt'))
    @HttpCode(200)
    async update_category(@Request() req, @Body() data: UpdateCategoryDTO): Promise<any>{
        const userData: UserJWT = req.user
        let cat = await this.categoryService.find({id:data.id},{user:true})
        if(cat == null){
            throw new HttpException({'message':'Category not found. Please use another category'}, 400);   
        }
        if(cat!.canDelete  == false || cat!.user.id != userData.userId){
            throw new HttpException({'message':'Category cant modify. Please use another category'}, 400); 
        }
        cat.category_name = data.category_name
        const res = await this.categoryService.update_category(cat, data.id);
        return {'message':'success', 'result':res}
    }
    @Delete('/delete/:id')
    @UseGuards(AuthGuard('jwt'))
    @HttpCode(200)
    async delete_category(@Request() req, @Param('id') id: string): Promise<any>{
        const userData: UserJWT = req.user
        let find = await this.categoryService.find_and_count_relation(id,{'user_id':userData.userId});
       

        if(find==null){
            throw new HttpException({'message':'Category not found. Please use another category'}, 400);   
        }
        if(find['canDelete']  == false){
            throw new HttpException({'message':'Category cant delete. Please use another category'}, 400); 
        }
        if(parseInt(find['count_t']) > 0){
            throw new HttpException({'message':'Category is used. Please use another category'}, 400);
        }
        const res = await this.categoryService.delete_category({id:parseInt(id)});
        return {'message':'success', 'result':res}
        
    }
    @Get('/:id')
    @UseGuards(AuthGuard('jwt'))
    async get_detail_category(@Request() req,  @Param('id') idTx: string,) : Promise<any>{
        const userData: UserJWT = req.user
            // const resTx = await this.categoryService.find_transaction({id:idTx})
            // if(resTx == null){
            //     return {'detail':resTx}
            // }
            
            // const resCat = await this.categoryService.find_multi([{userId:userData.userId, canDelete:true}, {canDelete:false}])
            // return {'data':resTx, 'category':resCat};
    }
    // @UseGuards(AuthGuard('jwt'))
    // @HttpCode(200)
    // @Get('/accumulation_month')
    // async get_monthly_spend(@Request() req, @Query('date') filter_date?: string){
    //     const userData: UserJWT = req.user
    //     let search = {'tanggal_transaksi': filter_date, 'userId':userData.userId}
    //     const res = await this.transactionService.accumulation_save(search)
    //     return {'data':res}   
    // }
    
        // @Put('/update')
        // @UseGuards(AuthGuard('jwt'))
        // async update_transaction(@Request() req, @Body() body:UpdateTransactionDTO): Promise<any>{
            
        //     const userData: UserJWT = req.user
        //     const tx = await this.transactionService.find_transaction({id:body.id})
            
        //     if(tx ==null){
        //         throw new HttpException({'message':'Transaction not found. Please use another Transaction'}, 404);
        //     }
            
        //     if(tx.user.id !== userData.userId){
        //         throw new HttpException({'message':'Transaction not found. Please use another Transaction'}, 401);
        //     }
        //     let cat : Category | null = null;
        //     if(body.category != undefined){
        //         cat = await this.categoryService.find({'id':body.category}, {user:true})
        //         if (cat?.canDelete && cat?.user.id!= userData.userId){
        //             throw new HttpException({'message':'please use another category'}, 401);
        //         }
        //     }
            
        //     const {user, category,id,  createdon, updatedon, ...result} = tx
        //     let valueSave: Partial<Transaction> = result;
        //     valueSave.name = body.name
        //     valueSave.detail = body.detail
        //     valueSave.harga = body.harga
        //     valueSave.debcre = body.debcre
        //     valueSave.tanggal_transaksi = body.tanggal_transaksi
        //     if (cat !=null && body.category != undefined) {
        //         let cat = new Category()
        //         cat.id = body.category ?? 0
        //         valueSave.category = cat
        //     }
        //     const res = await this.transactionService.update_transaction(valueSave, id)
        //     return res
            
        // }
        // @Delete('/delete/:id')
        // @UseGuards(AuthGuard('jwt'))
        // async delete_transaction(@Request() req, @Param('id') id: string): Promise<any>{
        //     console.log(parseInt(id))
        //     let tx = await this.transactionService.find_transaction({id:parseInt(id)})
        //     console.log(tx)
        //     if(tx ==null){
        //         throw new HttpException({'message':'please use another transaction'}, 404);
        //         // return {'message':'not access'}
        //     }
        //     const userData: UserJWT = req.user
            
        //     if (tx.user.id != userData.userId){
        //         throw new HttpException({'message':'please use another transaction'}, 401);
        //     }
        //     let pos = Number(id)
        //     console.log('delete',isNaN(pos))
        //     const res = await this.transactionService.delete_transaction({id:parseInt(id)});
        //     return {'message':'success',"info":res}
        // }
}
