import { Injectable } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { InjectRepository } from '@nestjs/typeorm';
import { SavingPlan } from 'src/model/saving_plan.entity';
import { SavingPlanCheckout } from 'src/model/saving_plan_checkout_entity';
import { User } from 'src/model/user.entity';
import { Brackets, DeleteResult, Repository } from 'typeorm';

@Injectable()
export class SavingPlanService {
    constructor(
        @InjectRepository(SavingPlan)
        private readonly savingPlanRepo: Repository<SavingPlan>,
        @InjectRepository(SavingPlanCheckout)
        private readonly savingPlanCheckoutRepo: Repository<SavingPlanCheckout>,
        
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
                target_date:'ASC'
            }
        })
    }
    get_data_with_search_single(search:{[key: string]: any}) :Promise<SavingPlan | null>{
        return this.savingPlanRepo.findOne({
            where:search,
            
        })
    }
    get_data_with_search_single_and_user(search:{[key: string]: any}) :Promise<SavingPlan | null>{
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
            // where:search,
            where:{
                savingPlan:{
                    id:'',
                    user:{
                        id:''
                    }
                }
            },
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
    // CRO
    // @Cron( ' * * * * *')
    async handleCron() {
        const date = new Date()
        let tanggal = date.toISOString().split('T')[0]
        let defaultValueforSum : string = 'IFNULL(sub.total, 0)'
        if(process.env.TYPE_DB == 'mssql'){
            defaultValueforSum = 'ISNULL(sub.total,0)'
        }
        let queryWhere1 = '( (last_day(:today)= :today and date_reminder >= day(:today) ) or day(:today) = date_reminder)'
        if(process.env.TYPE_DB == 'mssql'){
            queryWhere1 = '( (EOMONTH(:today)= :today and date_reminder >= day(:today) ) or day(:today) = date_reminder)'
        }

        let query = this.savingPlanRepo.createQueryBuilder('sp')
        .leftJoin(sub=>{
            return sub.select(['savingPlanId','sum(money) as total']).from(SavingPlanCheckout,'spc')
            .groupBy('spc.savingPlanId')
        },'sub','sub.savingPlanId=sp.id')
        .innerJoin(User,'u','sp.userId=u.id')
        .addSelect(`(sp.target_money - ${defaultValueforSum}) as remain`)
        
        .addSelect(`${defaultValueforSum} as sub_total`)
        .addSelect('u.name as name')
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
        const data= await query.getRawMany()
        console.log(data)
        console.log(`called 45s ${date.toISOString()}`);
        // 'select * from saving_plan as sp left join saving_plan_checkout as spco on spco.savingPlanId = sp.id and spco.id = 
        // (select id from saving_plan_checkout where saving_plan_checkout.savingPlanId = sp.id order by saving_plan_checkout.date desc limit 1)'
    }
    save_checkout(data: SavingPlanCheckout): Promise<SavingPlanCheckout>{
        return this.savingPlanCheckoutRepo.save(data);
    }

}
