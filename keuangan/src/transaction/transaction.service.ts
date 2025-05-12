import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Category } from 'src/model/category.entity';

import { User } from 'src/model/user.entity';
// import { User } from 'src/model/user.entity';
import { Between, Repository,  } from 'typeorm';
import { Transaction } from './entities/transaction.entity';

@Injectable()
export class TransactionService {
    constructor(
        @InjectRepository(Transaction)
        private readonly transactionRepo: Repository<Transaction>,
        
    ) { 
    }

    async get_all_transaction_custom(search: any=null):  Promise<any[]>{
        let query= this.transactionRepo.createQueryBuilder('t')
        .select(['t.*','category_name as category'])
        // .select(['t',]).from(Transaction,'transaction as t')
        .innerJoin(Category, 'c','c.id = t.categoryId')
        .where('t.userId = :userId',{ userId:'a858bd9b-7c44-45cf-ac2e-ab0acfa9ef23' })
        if (search?.tanggal_transaksi != undefined){
            const newDate = new Date(search['tanggal_transaksi'])
            const lastDay = new Date(newDate.getFullYear(), newDate.getMonth()+1, 0)
            query = query.where('tanggal_transaksi >= :tanggal_transaksi', {tanggal_transaksi:newDate.getFullYear()+'-'+(newDate.getMonth()+1)+'01'})
            query = query.where('tanggal_transaksi <= :tanggal_transaksi', {tanggal_transaksi:newDate.getFullYear()+'-'+(newDate.getMonth()+1)+lastDay.getDate()})
            search['tanggal_transaksi'] = Between(new Date(newDate.getFullYear(), newDate.getMonth(), 1),new Date(newDate.getFullYear(), newDate.getMonth() + 1, 0))
        }else{
           query = query.where('tanggal_transaksi >= :tanggal_transaksi', {tanggal_transaksi:'2025-01-01'})
           .where('tanggal_transaksi <= :tanggal_transaksi', {tanggal_transaksi:'2025-01-31'}) 
        }
        
        let data = await query
        .getRawMany()
        Logger.log(data)
        return new Promise(function(resolve, reject){
            return resolve([]);
        });
    }
    last_day(tgl){
        let str_split = tgl.split('-')
        let month = parseInt(str_split[1])
        // console.log(month, )
        if([1,3,5,7,8,10,12].includes(month)){
            return '31'
        }else if([4,6,9,11].includes(month)){
            return '30'
        }else if(parseInt(str_split[0]) % 4 === 0 && month === 2){
            return '29'
        }else{
            return '28'
        }
    }
    get_all_transaction(user_id: string, search:{[key: string]: any}): Promise<any[]> {
        // if (search['tanggal_transaksi']!=undefined){
        //     console.log(search);
        //     const newDate = new Date(search['tanggal_transaksi'])
        //     let str_split = search['tanggal_transaksi'].split('-');
        //     search['tanggal_transaksi'] =Between(
        //         str_split[0]+'-'+str_split[1]+'-'+'01', str_split[0]+'-'+str_split[1]+'-'+this.last_day(search['tanggal_transaksi'])
        //     );
            
        // }
        // if(search['start'] != undefined && search['end'] != undefined){
        //     search['tanggal_transaksi'] = Between(search['start'], search['end'])
        //     delete search['start']
        //     delete search['end']
        // }
        // console.log(user_id)
        let defaultFormat :string = `DATE_FORMAT(t.tanggal_transaksi,\'%Y-%m-%d\') as tanggal_transaksi`
        // defaultFormat = 't.tanggal_transaksi as tanggal_transaksi'
        if(process.env.TYPE_DB == 'mssql'){
            defaultFormat = `convert(varchar, t.tanggal, 23)`
        }
        let query = this.transactionRepo.createQueryBuilder('t')
        .select(['t.id as id', 't.name as name', 't.detail as detail', 't.harga as harga', 't.debcre as debcre', defaultFormat , 'c.category_name as category', 'c.id as category_id', 't.userId'])
        .leftJoin(Category, 'c','c.id=t.categoryId')
        .innerJoin(User, 'u', 'u.id=t.userId')
        .where('t.userId = :userId',{userId:user_id})

        if (search['tanggal_transaksi']!=undefined){
            let str_split = search['tanggal_transaksi'].split('-');
            query = query.andWhere('tanggal_transaksi >= :tanggal and tanggal_transaksi <= :tanggal_1', {tanggal:str_split[0]+'-'+str_split[1]+'-'+'01', tanggal_1:str_split[0]+'-'+str_split[1]+'-'+this.last_day(search['tanggal_transaksi'])})
            
        }
        if(search['start'] != undefined && search['end'] != undefined){
            query = query.where('t.tanggal_transaksi >= :tanggal_transaksi', {tanggal_transaksi:search['start']})
            query = query.andWhere('tanggal_transaksi <= :tanggal_transaksi', {tanggal_transaksi:search['end']})
            delete search['start']
            delete search['end']
        }
        const data = query.orderBy('t.tanggal_transaksi', 'ASC') .getRawMany();
        return data;
        // return Promise.bind[];
        // return this.transactionRepo.findAndCount
        // return this.transactionRepo.find({
        //     where:{
        //         ...search,
        //         user: {
        //             id:user_id
        //         }
        //     },
        //     relations:{
        //         user:true,
        //         category:true,
        //     },
        //     order:{tanggal_transaksi:'desc'}
        // })
    }

    
    create_transaction(data: Transaction): Promise<Transaction>{
        return this.transactionRepo.save(data)
    }
    update_transaction(data: Partial<Transaction>, id: number){
        return this.transactionRepo.update({id}, data)
    }
    delete_transaction(data: any){
        
        return this.transactionRepo.delete(data)
    }
    find_transaction(data: any): Promise<Transaction | null>{
        
        return this.transactionRepo.findOne({
            where:data,
            relations:{
                user:true,
                category:true,
            }
        })
    }
    accumulation_save_month(data: any): Promise<any[]>{
        // this.transactionRepo.manager.query()
        let query= this.transactionRepo.createQueryBuilder('t')
            .select(['sum(harga) as total','debcre','category_name as category'])
            .innerJoin(Category, 'c','c.id = t.categoryId')
        if (data?.tanggal_transaksi != undefined){
            const newDate = new Date(data['tanggal_transaksi'])
            const lastDay = new Date(newDate.getFullYear(), newDate.getMonth()+1, 0)
            query = query.where('tanggal_transaksi >= :tanggal_transaksi', {tanggal_transaksi:newDate.getFullYear()+'-'+(newDate.getMonth()+1)+'01'})
            query = query.where('tanggal_transaksi <= :tanggal_transaksi', {tanggal_transaksi:newDate.getFullYear()+'-'+(newDate.getMonth()+1)+lastDay.getDate()})
        }
        
        const res = query.where('t.userId = :userId', {userId:data['userId']})
            .groupBy('t.debcre')
            .addGroupBy('t.category_id')
            .addGroupBy('c.category_name')
            .getRawMany()
        return res;
    }
    accumulation_based_month(data: any): Promise<any[]>{
        let query = this.transactionRepo.createQueryBuilder('t')
        .select(['sum(harga) as total',
            'DATE_FORMAT(tanggal_transaksi, "%Y-%m") as tanggal'
            , 'debcre'])
        .where('t.userId = :userId', {userId:data['userId']})
        if (data?.tanggal_transaksi != undefined){
            query = query.andWhere('YEAR(tanggal_transaksi) = :tanggal_transaksi', {tanggal_transaksi:data['tanggal_transaksi'].split('-')[0]})
        }
        const res = query
            .groupBy('t.debcre')
            .addGroupBy('DATE_FORMAT(tanggal_transaksi, "%Y-%m")')
            .getRawMany()
        return res;
    }
    accumulation_based_year(data: any): Promise<any[]> {
        let query= this.transactionRepo.createQueryBuilder('t')
        .select(['sum(harga) as total','debcre','YEAR(tanggal_transaksi) as year_t'])
        return query.where('t.userId = :userId', {userId:data['userId']})
            .groupBy('t.debcre')
            .addGroupBy('year(tanggal_transaksi)')
            .getRawMany();

    }
    // sample():any{
    //     create
    //     this.transactionRepo.st
    // }
}
