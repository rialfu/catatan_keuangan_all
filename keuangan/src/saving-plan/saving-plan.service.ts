import { Injectable } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { InjectRepository, InjectDataSource, InjectEntityManager } from '@nestjs/typeorm';
import { SavingPlan } from 'src/model/saving_plan.entity';
import { SavingPlanCheckout } from 'src/model/saving_plan_checkout_entity';
import { User } from 'src/model/user.entity';
import { UserToken } from 'src/model/user_token.entity';
import { Brackets, DeleteResult, Repository, DataSource, EntityManager } from 'typeorm';

@Injectable()
export class SavingPlanService {
    constructor(
        @InjectRepository(SavingPlan)
        private readonly savingPlanRepo: Repository<SavingPlan>,
        @InjectRepository(SavingPlanCheckout)
        private readonly savingPlanCheckoutRepo: Repository<SavingPlanCheckout>,
        @InjectDataSource() private dataSource: DataSource
        
    ) { 
    }

    async get_data(): Promise<any>{
        // const subQuery = this.savingPlanCheckoutRepo.createQueryBuilder('sub_spc')
        //     .select(['id'])
        //     .where('sub_spc.savingPlanId = sp.id')
        //     .orderBy('sub_spc.date','DESC').limit(1).getQuery()
        // console.log(subQuery)
        // const data =await this.savingPlanRepo.createQueryBuilder('sp')
        //     .select(['sp.id as id','name','target_money', 'spc.date as lastStore'])
        //     .leftJoin(SavingPlanCheckout, 'spc',`spc.savingPlanId=sp.id and spc.id = (${subQuery})`)
        //     .getRawMany()
        // console.log(data)
        // const data =await this.savingPlanRepo.createQueryBuilder('sp')
        // .leftJoin(SavingPlanCheckout, 'spc','spc.savingPlanId = sp.id' )
        // .select('*')
        // .getRawMany()

        // e WEEKDAY() instead of DAYOFWEEK()
        let defaultValueforSum : string = 'IFNULL(sub.total, 0)'
        if(process.env.TYPE_DB == 'mssql'){
            defaultValueforSum = 'ISNULL(sub.total,0)'
        }
        this.savingPlanRepo.createQueryBuilder('sp').where('sp.notification := :notif',{'notif':true})
        
        // let queryWhere :string = 'date_reminder = ( case when type_reminder=\'monthly\' then day(:today) '
        // queryWhere = queryWhere + 'when type_reminder = \'weekly\' then (WEEKDAY(:today) + 1) end)'

        let queryWhere1 = '( (last_day(:today)= :today and date_reminder >= day(:today) ) or day(:today) = date_reminder)'
        if(process.env.TYPE_DB == 'mssql'){
            queryWhere1 = '( (EOMONTH(:today)= :today and date_reminder >= day(:today) ) or day(:today) = date_reminder)'
        }
        let tanggal = '2025-05-30'
        let query = this.savingPlanRepo.createQueryBuilder('sp')
        .leftJoin(sub=>{
            return sub.select(['savingPlanId','sum(money) as total']).from(SavingPlanCheckout,'spc')
            .groupBy('spc.savingPlanId')
        },'sub','sub.savingPlanId=sp.id')
        .addSelect(`(sp.target_money - ${defaultValueforSum}) as remain`)
        
        .addSelect(`${defaultValueforSum} as sub_total`)
        .where('sp.notification = :notif',{notif:true})
        .andWhere(new Brackets((qb1)=>{
            qb1.where('type_reminder = \'daily\'')
            .orWhere(new Brackets((qb2)=>{
                qb2.where('type_reminder = \'weekly\'')
                qb2.andWhere('date_reminder = (WEEKDAY(:today) + 1)',{today:tanggal})
            }))
            .orWhere(new Brackets((qb3)=>{
                qb3.where('type_reminder = \'monthly\'')
                .andWhere(queryWhere1,{today:tanggal} )
            }))
        }))
        // .having('remain > 0')
        // .leftJoinAndSelect('sp.checkout','spc')
        // .select(['sp.id','spc.money','spc.date'])
        const data= query.getRawMany() 
        // console.log(data)
        // return new Promise(function(resolve, reject){
        //     resolve(true)
        // })
        return data
        // .leftJoin()
        
    }
    get_data_with_search(search:{[key: string]: any}, relations:{[key: string]: any}) :Promise<SavingPlan[]>{
        return this.savingPlanRepo.find({
            where:search,
            relations:relations,
            order:{
                target_date:'ASC',
                checkout:{
                    date_checkout:'DESC'
                }
            }
        })
    }
    get_data_with_search_single(search:{[key: string]: any}) :Promise<SavingPlan | null>{
        return this.savingPlanRepo.findOne({
            where:search,
            
        })
    }
    get_single_data_with_custom(search:{[key: string]: any}) : Promise<any>{
        console.log(search)
        let defaultValueforSum : string = 'IFNULL(sub.total, 0)'
        if(process.env.TYPE_DB == 'mssql'){
            defaultValueforSum = 'ISNULL(sub.total,0)'
        }
        let query = this.savingPlanRepo.createQueryBuilder('sp')
        query.innerJoin(User, 'u', 'u.id=sp.userId')
        .leftJoin(sub=>{
            return sub.select(['savingPlanId','sum(money) as total']).from(SavingPlanCheckout,'spc')
            .groupBy('spc.savingPlanId')
        },'sub','sub.savingPlanId=sp.id')
        .addSelect(`${defaultValueforSum} as store_money`)
        .addSelect(`(sp.target_money <= ${defaultValueforSum}) as isAchiveTarget`)
        .where('u.id = :user', { user : search['userId'] })
        .andWhere('sp.id = :id', { id : search['id'] })
        return query.getRawOne()
    }
    get_data_with_search_single_and_user_checkout(search:{[key: string]: any}) :Promise<SavingPlan | null>{
        return this.savingPlanRepo.findOne({
            where:search,
            relations:{
                user:true
            },
            select:{
                id:true,
                name:true,
                type_reminder: true,
                date_reminder:true,
                target_date: true,
                target_money: true,
                notification:true,
                user:{
                    id:true
                },
                checkout:{
                    money:true
                }
            },
            order:{
                target_date:'ASC'
            }
        })
    }
    create(data: SavingPlan): Promise<SavingPlan>{
        return this.savingPlanRepo.save(data)
    }
    update(data: Partial<SavingPlan>, id: string){
        return this.savingPlanRepo.update({id}, data)
    }
    delete(search:{[key: string]: any}): Promise<DeleteResult>{
        return this.savingPlanRepo.delete(search)
    }

    get_data_checkout_with_search(search:{[key: string]: any}) :Promise<SavingPlanCheckout[]>{
        return this.savingPlanCheckoutRepo.find({
            where:search,
            // where:{
            //     savingPlan:{
            //         id:'',
            //         user:{
            //             id:''
            //         }
            //     }
            // },
            order:{
                date_checkout:'desc'
            },
            
        })
    }
    get_data_checkout_with_search_single(search:{[key: string]: any}, relation:{[key: string]: any}) :Promise<SavingPlanCheckout | null>{
        return this.savingPlanCheckoutRepo.findOne({
            relations:relation,
            where:search,
        })
    }
    create_checkout(data: SavingPlanCheckout): Promise<SavingPlanCheckout>{
        return this.savingPlanCheckoutRepo.save(data)
    }
    update_checkout(data: Partial<SavingPlanCheckout>, id: number){
        return this.savingPlanCheckoutRepo.update({id}, data)
    }
    delete_checkout(search:{[key: string]: any}): Promise<DeleteResult>{
        return this.savingPlanCheckoutRepo.delete(search)
    }
    async process_create_checkout(data: Partial<SavingPlanCheckout>, id_saving_plan: string, id_user: string) : Promise<{[key: string]: any}>{
        const queryRunner = this.dataSource.createQueryRunner();
        await queryRunner.connect();
        await queryRunner.startTransaction();
        try{
            let defaultValueforSum : string = 'IFNULL(sub.total, 0)'
            if(process.env.TYPE_DB == 'mssql'){
                defaultValueforSum = 'ISNULL(sub.total,0)'
            }
            let query = queryRunner.manager.createQueryBuilder(SavingPlan, 'sp')
            query = query.innerJoin(User, 'u', 'u.id=sp.userId')
            .leftJoin(sub=>{
                let query1 = sub.select(['savingPlanId','sum(money) as total'])
                query1 = query1.from(SavingPlanCheckout,'spc')
                return query1.groupBy('spc.savingPlanId')
                // return sub.select(['savingPlanId','sum(money) as total']).from(SavingPlanCheckout,'spc')
                // .groupBy('spc.savingPlanId')
            },'sub','sub.savingPlanId=sp.id')
            query = query.addSelect(`sp.target_money - ${defaultValueforSum} as remain`)
                .where('u.id = :user', { user : id_user })
                .andWhere('sp.id = :id', { id : id_saving_plan })
            const tx = await query.getRawOne()
            if(tx == null){
                await queryRunner.release()
                return new Promise((resolve)=> resolve({'result':false, 'message':'please use another saving plan before checkout', 'code':422}))
            }
            if(tx['remain'] <= 0){
                await queryRunner.release()
                return new Promise((resolve)=> resolve({'result':false, 'message':'Your savings have exceeded the target.', 'code':403}))
            }
            let sp : SavingPlan = new SavingPlan()
            sp.id = id_saving_plan
            data.savingPlan = sp
            
            const result = await queryRunner.manager.insert(SavingPlanCheckout, data);
            if(tx['remain'] - (data?.money ?? 0) <= 0){
                let sp1 : Partial<SavingPlan> = new SavingPlan()
                sp1.notification = false;
                await queryRunner.manager.update(SavingPlan, {id:id_saving_plan}, sp1)   
            }
            await queryRunner.commitTransaction()
            await queryRunner.release()
            return new Promise((resolve)=> resolve({'result':true, 'data':result}))
        }catch(err){
            console.log(err)
            await queryRunner.rollbackTransaction();
            await queryRunner.release()
            return new Promise((resolve)=> resolve({'result':false, 'message':'server error', 'code':500}))
        }
    }
    // CRO
    // @Cron( ' * * * * *')
    async getDataForNotification() {
        const date = new Date()
        let tanggal = date.toISOString().split('T')[0]
        console.log(tanggal);
        let defaultValueforSum : string = 'IFNULL(sub.total, 0)'
        if(process.env.TYPE_DB == 'mssql'){
            defaultValueforSum = 'ISNULL(sub.total,0)'
        }
        let queryWhere1 = '( (last_day(:today)= :today and date_reminder >= day(:today) ) or day(:today) = date_reminder)'
        if(process.env.TYPE_DB == 'mssql'){
            queryWhere1 = '( (EOMONTH(:today)= :today and date_reminder >= day(:today) ) or day(:today) = date_reminder)'
        }
        let queryWhere2 = 'LOWER(date_reminder) = LOWER(DAYNAME(:today))'
        if(process.env.TYPE_DB == 'mssql'){
            queryWhere2 = 'LOWER(date_reminder) = LOWER(DATENAME(WEEKDAY, :today ))'
        }

        let query = this.savingPlanRepo.createQueryBuilder('sp')
        .leftJoin(sub=>{
            return sub.select(['savingPlanId','sum(money) as total']).from(SavingPlanCheckout,'spc')
            .groupBy('spc.savingPlanId')
        },'sub','sub.savingPlanId=sp.id')
        .innerJoin(User,'u','sp.userId=u.id')
        .leftJoin(UserToken, 'ut', 'u.id = ut.userId')
        .addSelect(`(sp.target_money - ${defaultValueforSum}) as remain`)
        .addSelect(`${defaultValueforSum} as sub_total`)
        .addSelect('u.name as name')
        .addSelect('ut.fcm_token as token')
        .where('sp.notification = :notif',{notif:true})
        .andWhere(new Brackets((qb1)=>{
            qb1.where('type_reminder = \'daily\'')
            .orWhere(new Brackets((qb2)=>{
                qb2.where('type_reminder = \'weekly\'')
                qb2.andWhere(queryWhere2, {today:tanggal})
                // qb2.andWhere('date_reminder = (WEEKDAY(:today) + 1)',{today:tanggal})
            }))
            .orWhere(new Brackets((qb3)=>{
                qb3.where('type_reminder = \'monthly\'')
                .andWhere(queryWhere1,{today:tanggal} )
            }))
        }))
        .andWhere(`(sp.target_money - ${defaultValueforSum}) > 0`)
        return query.getRawMany()
        // console.log(data)
        // console.log(`called 45s ${date.toISOString()}`);
        // 'select * from saving_plan as sp left join saving_plan_checkout as spco on spco.savingPlanId = sp.id and spco.id = 
        // (select id from saving_plan_checkout where saving_plan_checkout.savingPlanId = sp.id order by saving_plan_checkout.date desc limit 1)'
    }
    // select sp.id, target_money, date_reminder,type_reminder,notification,  sum(spc.money) from saving_plan as sp left join saving_plan_checkout as spc on sp.id =spc.savingPlanId group by sp.id, target_money, date_reminder, type_reminder, notification
    save_checkout(data: SavingPlanCheckout): Promise<SavingPlanCheckout>{
        return this.savingPlanCheckoutRepo.save(data);
    }

}
