import { Injectable } from '@nestjs/common';
import { User } from '../model/user.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, UpdateResult } from 'typeorm';
import { UserToken } from 'src/model/user_token.entity';


@Injectable()
export class UsersService {
    constructor(
        @InjectRepository(User)
        private readonly users: Repository<User>,
        @InjectRepository(UserToken)
        private readonly userTokens: Repository<UserToken>,
      ) { }
    findOne(email: string): Promise<User | null> {
        return this.users.findOneBy({email})
    }
    get_token_exist(token: string): Promise<UserToken | null>{
        return this.userTokens.findOneBy({fcm_token:token});
    }
    update_token_user(data: Partial<UserToken>, id: string) :Promise<UpdateResult>{
        return this.userTokens.update({user:{id}}, data);
    }
    insert_token_user(data: Partial<UserToken>){
        return this.userTokens.save(data)
    }
    create(user: Partial<User>): Promise<User>{
        const data = this.users.create(user)
        return this.users.save(data)
    } 
}