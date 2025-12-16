import { Injectable } from '@nestjs/common';
import { User } from '../model/user.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, UpdateResult } from 'typeorm';
import { UserToken } from 'src/model/user_token.entity';
import { CodeReset } from './entities/code_reset.entity';


@Injectable()
export class UsersService {
    constructor(
        @InjectRepository(User)
        private readonly users: Repository<User>,
        @InjectRepository(UserToken)
        private readonly userTokens: Repository<UserToken>,
        @InjectRepository(CodeReset)
        private readonly codeReset: Repository<CodeReset>,
      ) { }
    findOne(email: string): Promise<User | null> {
        return this.users.findOneBy({email})
    }
    findOneById(id: number){
        return this.users.findOneBy({id});
    }
    get_token_exist(token: string): Promise<UserToken | null>{
        return this.userTokens.findOneBy({fcm_token:token});
    }
    get_user_token(id: number): Promise<UserToken | null>{
        return this.userTokens.findOneBy({user:{id}})
    }
    update_token_user(data: Partial<UserToken>, id: number) :Promise<UpdateResult>{
        return this.userTokens.update({id}, data);
    }
    insert_token_user(data: Partial<UserToken>){
        return this.userTokens.save(data)
    }
    create(user: Partial<User>): Promise<User>{
        const data = this.users.create(user)
        return this.users.save(data)
    }
    update_user(data:Partial<User>, id:number){
        return this.users.update({id}, data);
    }
    find_code_reset_from_user(email : string) : Promise<User | null>{
       
        return this.users.findOne({
            relations:{
                code_reset:true
            },
            where:{
                email
            }

        })
        
        
    }
    
    save_code_reset(cr: Partial<CodeReset>):Promise<CodeReset>{
        const data =this.codeReset.create(cr)
        return this.codeReset.save(data);
    }
    update_code_reset(cr: Partial<CodeReset>, id:number):Promise<UpdateResult>{
        return this.codeReset.update({id}, cr);
    }
}