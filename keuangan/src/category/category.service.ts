import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Category } from 'src/model/category.entity';
import { Transaction } from 'src/transaction/entities/transaction.entity';
import { DataSource, getManager, Repository } from 'typeorm';

@Injectable()
export class CategoryService {
    constructor(
        @InjectRepository(Category)
        // @InjectRepository(Category)
        
        private readonly categoryRepo: Repository<Category>,
        private dataSource : DataSource,
    ) { }

    find(data: any, relations: any): Promise<Category| null>{
        // return this.categoryRepo.find()
        return this.categoryRepo.findOne({
            where:data,
            relations
        });
    }
    find_multi(data: any):Promise<Category[]>{
        return this.categoryRepo.find(data)
    }
    create_category(data: Category): Promise<Category>{
        return this.categoryRepo.save(data)
    }
    update_category(data: Category, id: number):Promise<any>{
        return this.categoryRepo.update({id}, data)
    }
    delete_category(data: any){
        return this.categoryRepo.delete(data)
    }
    find_and_count_relation(id: string, search:{[key: string]: any}):Promise<any>{
        let query = this.categoryRepo.createQueryBuilder('c');
        query = query.select(['c.id', 'category_name', 'canDelete','count(t.id) as count_t'])
        .leftJoin(Transaction, 't', 'c.id=t.categoryId').where('c.id = :id',{id});
        if(search['user_id'] != undefined){
            query = query.andWhere('c.userId = :userId',{userId:search['user_id']})
        }
        query = query.groupBy('c.id').addGroupBy('category_name').addGroupBy('canDelete')
        return query.getRawOne();
    
    }
    find_all_and_count_relation(search:{[key: string]: any}):Promise<any>{
        // let query = this.dataSource.createQueryBuilder()
        // .select(['tab1.id as id', 'tab1.category_name as category_name', 'case when tab1.canDelete = false then false when tab1.canDelete = true and tab1.count_t > 0 then false else true end canDelete',
        //     'case when tab1.canDelete = false then false else true end canUpdate'
        // ])
        // return query.addFrom((sq)=>{
        //     let subquery = sq.select(['c.id as id', 'category_name', 'canDelete', 'count(t.id) as count_t'])
        //     .from(Category, 'c')
        //     .leftJoin(Transaction, 't', 'c.id=t.categoryId')
        //     subquery= subquery.where('canDelete=false')
        //     if(search['user_id'] != undefined){
        //         subquery = subquery.orWhere('c.userId = :userId',{userId:search['user_id']})
        //     }
        //     return subquery.groupBy('c.id').addGroupBy('category_name').addGroupBy('canDelete')
        // }, 'tab1').getRawMany()

        let query = this.categoryRepo.createQueryBuilder('c')
        query.select(['c.id as id',' c.category_name as category_name', 
            'c.canDelete as canUpdate',
            'case when c.canDelete =  false then false when c.canDelete = true and count(t.id) > 0 then false else true end canDelete',
            
        ]) 
        query = query.leftJoin(Transaction, 't', 'c.id=t.categoryId')
        query = query.where('canDelete=false')
        if(search['user_id'] != undefined){
            query = query.orWhere('c.userId = :userId',{userId:search['user_id']})
        }
        query = query.groupBy('c.id').addGroupBy('category_name').addGroupBy('canDelete');
        return query.getRawMany()
    
    }
}
