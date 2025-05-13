import { Controller, Get, Post, Request, Delete, Put, UseGuards, Param, Logger, Body, Res, HttpException, HttpCode, Query, UsePipes, UseInterceptors } from '@nestjs/common';
import { TransactionService } from './transaction.service';
import { AuthGuard } from '@nestjs/passport';
import { CategoryService } from 'src/category/category.service';
import { User } from 'src/model/user.entity';
import {Response}  from 'express'
import { UserJWT } from 'src/model/user_jwt.dto';
import { CreateTransactionDTO, TransactionGet, UpdateTransactionDTO } from 'src/transaction/dto/transaction.dto';
import { Category } from 'src/model/category.entity';
import * as ExcelJS from 'exceljs';
import { InjectUserToBody } from 'src/config/apply_decorator';
import { SkipThrottle } from '@nestjs/throttler';
import { Transaction } from './entities/transaction.entity';

// @SkipThrottle()
@Controller('transaction')
export class TransactionController {
    constructor(
        private readonly transactionService: TransactionService,
        private readonly categoryService: CategoryService, 
        
    ) {}
    
    @Get('/')
    
    @UseGuards(AuthGuard('jwt'))
    async get_list_all_transaction(@Request() req, @Query('date') filter_date: string) : Promise<any>{
        // console.log(req);
        // const regex = /^d{4}-\d{2}-\d{2}/g
        const regex = new RegExp(/^\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]{1})$/)
        filter_date = (filter_date ?? '').replace(/\'/g,'')
        if(filter_date==undefined || filter_date == ''){
            const newDate = new Date()
            filter_date = newDate.getFullYear()+'-'+(newDate.getMonth()+1)+'-'+'01'
        }else if(regex.test(filter_date) === false){
            const newDate = new Date()
            filter_date = newDate.getFullYear()+'-'+(newDate.getMonth()+1)+'-'+'01'
        }
        const data = {tanggal_transaksi:filter_date}
        // console.log(data);
        const result = await this.transactionService.get_all_transaction(req.user.userId, data)
        // console.log(result);
        return {'data':result};
    }
    @Get('/download')
    async download_file(@Request() req,  @Query('date') filter_date?: string, @Query('start') start_date?: string, @Query('end') end_date?: string){
        if(start_date ==undefined){
            throw new HttpException({'message':'Please choose start date'}, 400);
        }
        const format_date_start = new Date(start_date)
        if(!isNaN(format_date_start.getDate()) == false){
            throw new HttpException({'message':'Please choose start date'}, 500);
        }
        if(end_date ==undefined){
            throw new HttpException({'message':'Please choose end date'}, 400);
        }
        const format_date_end = new Date(end_date)
        if(!isNaN(format_date_end.getDate()) == false){
            throw new HttpException({'message':'Please choose end date'}, 500);
        }
        if(format_date_start > format_date_end){
            throw new HttpException({'message':'Please choose end date is newer than start or same'}, 500);
        }
        // if(filter_date==undefined || filter_date == ''){
        //     const newDate = new Date()
        //     filter_date = newDate.getFullYear()+'-'+(newDate.getMonth()+1)+'-'+'01'
        // }
        // const regex = /^\d{4}-\d{2}-\d{2}$/;
        // if(regex.test(filter_date) === false){
        //     const newDate = new Date()
        //     filter_date = newDate.getFullYear()+'-'+(newDate.getMonth()+1)+'-'+'01'
        // }
        // const data = {tanggal_transaksi:filter_date}
        // // const data = {}
        // // this.transactionService.get_all_transaction_custom()
        // const result = await this.transactionService.get_all_transaction(req.user.userId, data)

        // const Workbook =new ExcelJS.Workbook()
        // const worksheet = Workbook.addWorksheet('TestExportXLS');
        
        // worksheet.columns = [
        //     { header: 'name', key: 'name' },
        //     { header: 'age', key: 'age' }
        // ];

        // worksheet.addRow({
        //     name: 'Neo Luo',
        //     age: 18
        // });
        // const buffer = await Workbook.csv.writeBuffer()
        // res.set('Content-Disposition', 'attachment; filename=anlikodullendirme.csv');
        // res.set('Content-Type', 'application/octet-stream');
        // res.send(buffer)
        return {'message':'success please wait creating file'};
  
    }
    

    @Post('/create')
    
    @UseGuards(AuthGuard('jwt'))
    @InjectUserToBody()
    @HttpCode(200)
    async create_transaction( @Body() body:CreateTransactionDTO, @Request() req,): Promise<any>{
        // try{
        const userData: UserJWT = req.user
        // const category = await this.categoryService.find({'id':body.category},{user:true})
        // if(category == null){
        //     throw new HttpException({'message':'Category not found. Please use another category'}, 400);
        // }
        // if (category?.canDelete && category?.user.id!= userData.userId){
        //     throw new HttpException({'message':'please use another category'}, 400);
        // }
        
        const data = new Transaction()
        data.name = body.name
        data.detail= body.detail ?? null;
        data.harga = body.harga
        
        data.debcre = body.debcre
        data.tanggal_transaksi = new Date(body.tanggal_transaksi)
        // data.tanggal_transaksi = body.tanggal_transaksi;
        
        const cat = new Category()
        cat.id = body.category
        data.category = cat

        const user = new User()
        user.id = userData.userId
        data.user = user

        const res = await this.transactionService.create_transaction(data)
        return {'message':'success', 'result':res}
    }
    @UseGuards(AuthGuard('jwt'))
    // @HttpCode(200)
    @Get('/accumulation_month')
    async get_monthly_spend(@Request() req, @Query('date') filter_date?: string){
        // return {'data':'s'}
        const userData: UserJWT = req.user
        let search = {'tanggal_transaksi': filter_date, 'userId':userData.userId}
        const res = await this.transactionService.accumulation_based_month(search)
        return {'data':res}   
    }

    @Put('/update')
    @UseGuards(AuthGuard('jwt'))
    @InjectUserToBody()
    async update_transaction(@Request() req, @Body() body:UpdateTransactionDTO): Promise<any>{
        
        const userData: UserJWT = req.user
        console.log({data:body});
        // const tx = await this.transactionService.find_transaction({id:body.id})
        
        // if(tx ==null){
        //     throw new HttpException({'message':'Transaction not found. Please use another Transaction'}, 400);
        // }
        
        // if(tx.user.id !== userData.userId){
        //     throw new HttpException({'message':'Transaction not found. Please use another Transaction'}, 400);
        // }
        // let cat : Category | null = null;
        // console.log(body.category);
        // if(body.category != undefined){
        //     cat = await this.categoryService.find({'id':body.category}, {user:true})
        //     if (cat == null || (cat?.canDelete && cat?.user.id!= userData.userId)){
        //         throw new HttpException({'message':'please use another category'}, 400);
        //     }
        // }
        // const {user, category,id,  createdon, updatedon, ...result} = tx
        // let valueSave: Partial<Transaction> = result;
        let valueSave : Partial<Transaction> = new Transaction();
        valueSave.name = body.name
        valueSave.detail = body.detail
        valueSave.harga = body.harga
        valueSave.debcre = body.debcre
        if(body.tanggal_transaksi != undefined){
            valueSave.tanggal_transaksi = new Date( body.tanggal_transaksi)
        }
        // valueSave.tanggal_transaksi = body.tanggal_transaksi
        if(body.category != undefined){
            let cat = new Category()
            cat.id = body.category
            valueSave.category = cat
        }
        const res = await this.transactionService.update_transaction(valueSave, body.id)
        return {message:"success", result:res}
        
    }
    @Delete('/delete/:id')
    @UseGuards(AuthGuard('jwt'))
    async delete_transaction(@Request() req, @Param('id') id: string): Promise<any>{
        const userData: UserJWT = req.user
        let tx = await this.transactionService.find_transaction({id:parseInt(id)})
        if(tx ==null){
            throw new HttpException({'message':'please use another transaction'}, 400);
        }
        if (tx.user.id != userData.userId){
            throw new HttpException({'message':'please use another transaction'}, 400);
        }
        const res = await this.transactionService.delete_transaction({id:parseInt(id)});
        return {'message':'success',"info":res}
    }
    @Get('/:id')
    @UseGuards(AuthGuard('jwt'))
    async get_detail_transaction(@Request() req,  @Param('id') idTx: string,) : Promise<any>{
        const userData: UserJWT = req.user
        const resTx = await this.transactionService.find_transaction({id:idTx})
        if(resTx == null){
            return {'detail':resTx}
        }
        
        const resCat = await this.categoryService.find_multi([{userId:userData.userId, canDelete:true}, {canDelete:false}])
        return {'data':resTx, 'category':resCat};
    }
    

}
