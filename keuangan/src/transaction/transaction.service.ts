import { Injectable, InternalServerErrorException, Logger } from '@nestjs/common';
import { InjectDataSource, InjectRepository } from '@nestjs/typeorm';
import { Category } from 'src/model/category.entity';

import { User } from 'src/model/user.entity';
import { stringify } from 'csv-stringify'
// import { User } from 'src/model/user.entity';
import { Between, DataSource, LessThan, LessThanOrEqual, MoreThanOrEqual, QueryRunner, Repository,  } from 'typeorm';
import { Transaction } from './entities/transaction.entity';
import { PassThrough, Readable } from 'stream';
import { get_first_day_month_string_from_string, get_last_day_month_string_from_string } from 'src/config/support_date';

@Injectable()
export class TransactionService {
    constructor(
        @InjectRepository(Transaction)
        private readonly transactionRepo: Repository<Transaction>,
        @InjectDataSource() private dataSource: DataSource,
        
    ) { 
    }

    
    get_all_transaction(user_id: string, search:{[key: string]: any}): Promise<any[]> {
        
        let defaultFormat :string = `DATE_FORMAT(t.tanggal_transaksi,\'%Y-%m-%d\') as tanggal_transaksi`
       
        if(process.env.TYPE_DB == 'mssql'){
            defaultFormat = `convert(varchar, t.tanggal, 23)`
        }
        let query = this.transactionRepo.createQueryBuilder('t')
        .select([
            't.id as id', 
            't.name as name', 
            't.detail as detail', 
            't.harga as harga', 
            't.debcre as debcre', 
            defaultFormat , 
            'c.category_name as category', 
            'c.id as category_id', 't.userId'
        ])
        .leftJoin(Category, 'c','c.id=t.categoryId')
        .innerJoin(User, 'u', 'u.id=t.userId')
        .where('t.userId = :userId',{userId:user_id})

        if (search['tanggal_transaksi']!=undefined){
            query = query.andWhere('tanggal_transaksi >= :start and tanggal_transaksi <= :end',{
                start: get_first_day_month_string_from_string(search['tanggal_transaksi']),
                end: get_last_day_month_string_from_string(search['tanggal_transaksi'])
            })
            // let str_split = search['tanggal_transaksi'].split('-');
            // query = query.andWhere('tanggal_transaksi >= :tanggal and tanggal_transaksi <= :tanggal_1', {tanggal:str_split[0]+'-'+str_split[1]+'-'+'01', tanggal_1:str_split[0]+'-'+str_split[1]+'-'+this.last_day(search['tanggal_transaksi'])})
            
        }
        if(search['start'] != undefined && search['end'] != undefined){
            query = query.where('t.tanggal_transaksi >= :tanggal_transaksi', {tanggal_transaksi:search['start']})
            query = query.andWhere('tanggal_transaksi <= :tanggal_transaksi', {tanggal_transaksi:search['end']})
            delete search['start']
            delete search['end']
        }
        const data = query.orderBy('t.tanggal_transaksi', 'ASC') .getRawMany();
        return data;
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
    async stream_load_data(start_date:Date, end_date:Date, userId: string | number | null) {
        const queryRunner = this.dataSource.createQueryRunner()
        await queryRunner.connect()
        let columns = {
            name: 'name',
            detail: 'detail',
            ie:'Income/Expense',
            amount:'Amount',
            category:'Category',
            tanggal:'Date'
        }
        const stream = new PassThrough({objectMode:true})
        const stringifier = stringify({ header: true, columns:columns });
        stringifier.pipe(stream)
        let abortProcess = false;
        stream.on('close', () => {
            // this.logger.warn('CSV stream closed prematurely. Aborting database fetch loop.');
            abortProcess = true;
            // stringifier.end();
        });
        stream.on('error', (err) => {
            // this.logger.error('Error in CSV stream (UsersService):', err.message);
            abortProcess = true; // Abort proses jika ada error pada stream CSV
            // stringifier.end();
        });
        let batch_size = 100;
        (async () => {
            let offset = 0;
            let hasMoreData = true;
            let isFirstBatch = true; // Untuk menentukan kapan header CSV perlu ditulis

            try {
                while (hasMoreData && !abortProcess) {
                    
                    let query = this.transactionRepo.createQueryBuilder('t')
                    .select([
                        't.name as name',
                        'detail',
                        'case when debcre = \'debit\' then \'Income\' else \'Expense\' end as ie',
                        'harga as amount',
                        'c.category_name as category',
                        'DATE_FORMAT(tanggal_transaksi, \'%Y-%m-%d\') as tanggal'
                    ])
                    .leftJoin(Category, 'c', 'c.id = t.categoryId')
                    .where('tanggal_transaksi >= :start_date',{start_date:start_date.toISOString().split('T')[0]})
                    .andWhere('tanggal_transaksi <= :end_date',{end_date:end_date.toISOString().split('T')[0]})
                    if(userId != null){
                        query = query.andWhere('t.userId = :userId',{userId})
                    }
                    const data = await query
                    .orderBy({
                        'tanggal_transaksi':'DESC',
                        't.id':'ASC',
                    })
                    .limit(batch_size)
                    .offset(offset)
                    .getRawMany()
                    
                    // console.log(data)
                    
                    if (data.length > 0) {
                        // if(isFirstBatch){
                        //     isFirstBatch = false;
                        //     stringifier.write(data)
                        // }else{
                        //     stringifier.options.header = false;
                        //     stringifier.write(data)
                        // }
                        for(let i=0; i<data.length;i++){
                            stringifier.write(data[i])
                            if(isFirstBatch){
                                isFirstBatch = false;
                                stringifier.options.header = false;
                            }
                        }
                        offset += data.length;
                        hasMoreData = data.length === batch_size; // Jika jumlah data kurang dari BATCH_SIZE, berarti sudah habis
                    } else {
                        hasMoreData = false; // Tidak ada lagi data
                    }
                }
                stringifier.end();
                stream.end()
            } catch (error) {
                //trigger stream error juga
                stringifier.emit('error', error); // Propagasi error ke 
                
                stringifier.end(); // Akhiri stringifier dengan error
            }
        })();
        return stream;
        
    }
    private async checkProcessStatus(processId: number): Promise<boolean> {
        const queryRunner = this.dataSource.createQueryRunner();
        await queryRunner.connect()
        // const processRecord = await queryRunner.manager.findOne(Process, {
        // where: { id: processId },
        // select: ['status']
        // });

        // if (!processRecord) {
        //     throw new NotFoundException(`Process with ID ${processId} not found.`);
        // }
        return Promise.apply((resolve)=>{
            resolve(true)
        })
        // return processRecord.status;
  }
}
