import { Controller, Get, Post, Request, Delete, Put, UseGuards, Param, Logger, Body, Res, HttpException, HttpCode, Query, UsePipes, UseInterceptors, HttpStatus } from '@nestjs/common';
import { TransactionService } from './transaction.service';
import { AuthGuard } from '@nestjs/passport';
import { CategoryService } from 'src/category/category.service';
import { User } from 'src/model/user.entity';
import {Response}  from 'express'
import { UserJWT } from 'src/model/user_jwt.dto';
import { CreateTransactionDTO, TransactionGet, UpdateTransactionDTO } from 'src/transaction/dto/transaction.dto';
import { Category } from 'src/model/category.entity';
import { InjectUserToBody } from 'src/config/apply_decorator';
import { SkipThrottle } from '@nestjs/throttler';
import { Transaction } from './entities/transaction.entity';
import { Readable } from 'stream';
import { get_first_day_month_from_date, get_first_day_month_string_from_date, get_first_day_month_string_from_string, isStringDate, isStringDateYYYYMMDD } from 'src/config/support_date';

@SkipThrottle()
@Controller('transaction')
export class TransactionController {
    constructor(
        private readonly transactionService: TransactionService,
        private readonly categoryService: CategoryService, 
        
    ) {}
    
    @Get('/test')
    async get_test(){
        
    }
    @Get('/')
    @UseGuards(AuthGuard('jwt'))
    async get_list_all_transaction(@Request() req, @Query('date') filter_date: string) : Promise<any>{
        // console.log(req);
        // const regex = /^d{4}-\d{2}-\d{2}/g
        // const regex = new RegExp(/^\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]{1})$/)
        filter_date = (filter_date ?? '').replace(/\'/g,'')
        if(isStringDateYYYYMMDD(filter_date) === false){
            filter_date = get_first_day_month_string_from_date(new Date())
        }
        const data = { tanggal_transaksi: filter_date}
        // console.log(data);
        const result = await this.transactionService.get_all_transaction(req.user.userId, data)
        console.log(result);
        return {'data':result};
    }
    
    @Get('/download')
    @UseGuards(AuthGuard('jwt'))
    async download_file(@Request() req, @Res() res: Response,  @Query('date') filter_date?: string, @Query('start') start_date?: string, @Query('end') end_date?: string){
        const userData: UserJWT = req.user
        
        if(end_date == null){
            res.status(HttpStatus.BAD_REQUEST).send({'message':'Please fill End of Date'});
            return;
        }
        if(start_date == null){
            res.status(HttpStatus.BAD_REQUEST).send({'message':'Please fill Start of Date'});
            return;
        }
        if(isStringDate(start_date) == false){
            res.status(HttpStatus.BAD_REQUEST).send({'message':'Please fill Start of Date'});
            return;
        }
        if(isStringDate(end_date) == false){
            res.status(HttpStatus.BAD_REQUEST).send({'message':'Please fill End of Date'});
            return;
        }
        let sd =  new Date(start_date)
        let ed = new Date(end_date);
        const originalDay = ed.getDate();
        const originalMonth = ed.getMonth();
        const originalYear = ed.getFullYear();

        const lastDayOfOriginalMonth = new Date(originalYear, originalMonth + 1, 0).getDate();
        const isOriginalDateLastDay = originalDay === lastDayOfOriginalMonth;
        const monthsToSubtract = 1;
        const newDate = new Date(ed);
        newDate.setMonth(originalMonth - monthsToSubtract);
        if(originalMonth == sd.getMonth() && originalYear == sd.getFullYear()){

        }else{
            if (isOriginalDateLastDay) {
                const newMonth = newDate.getMonth();
                const newYear = newDate.getFullYear();
                const lastDayOfNewMonth = new Date(newYear, newMonth + 1, 0).getDate();
                newDate.setDate(lastDayOfNewMonth);
            } else {
                const expectedNewMonth = (originalMonth - monthsToSubtract + 12) % 12;
                if (newDate.getMonth() !== expectedNewMonth) {// jika perhitungan perbedaan jumlah misal 28 feb 31 maret gk bs dikurang 1 bulan harus disesuaikan
                    const newMonth = newDate.getMonth(); // Ini akan menjadi bulan yang "salah" (misal Maret)
                    const newYear = newDate.getFullYear();
                    const lastDayOfCorrectNewMonth = new Date(newYear, newMonth, 0).getDate(); 
                    newDate.setDate(lastDayOfCorrectNewMonth);
                }
            }
            if(sd < newDate){
                res.status(HttpStatus.BAD_REQUEST).send({'message':'Please maximum '+monthsToSubtract+' month'});
                return;
                // throw new HttpException({'message':'Please maximum 3 month'}, HttpStatus.BAD_REQUEST);
            }
        }
        
        // console.log('d')
        //jika melebihi 3bulan     
        
        try{
            
            const csvStream : Readable = await this.transactionService.stream_load_data(sd, ed, userData.userId);
            res.setHeader('Content-Type', 'text/csv; charset=utf-8');
            res.setHeader('Content-Disposition', 'attachment; filename="data_export_'+sd.toISOString().split('T')[0]+'_'+ed.toISOString().split('T')[0]+'.csv"');
            csvStream.pipe(res);
            // jika response selesai, tutup manual stream
            res.on('close', ()=>{
                if(!csvStream.destroyed){
                    csvStream.destroy()
                }
            })
            // res.on('')
            res.on('error', (err) => {
                // this.logger.error('Error writing to client response stream:', err.message, err.stack);
                if (!csvStream.destroyed) {
                    csvStream.destroy();
                }
                if (!res.headersSent) {
                    res.status(HttpStatus.INTERNAL_SERVER_ERROR).send('Error during file transfer.');
                }
            });
            //jika terjadi error pada stream, paksa end response
            csvStream.on('error', (err) => {
                // this.logger.error('Error from CSV stream (Controller):', err.message, err.stack);
                if (!res.headersSent) {
                    res.status(HttpStatus.INTERNAL_SERVER_ERROR).send('Error generating CSV data.');
                } else {
                    res.end();
                }
            });
        }catch(err){
            if(!res.headersSent){
                res.status(HttpStatus.INTERNAL_SERVER_ERROR).send({message:err})
            }else{
                res.end()
            }
        }
  
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
        // console.log({data:body});
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
