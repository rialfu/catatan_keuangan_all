import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Role } from 'src/model/role.entity';
import { Repository } from 'typeorm';

@Injectable()
export class RolesService {
    constructor(
        @InjectRepository(Role)
        private readonly roles: Repository<Role> 
    ) { }

    findRole(role_name: string): Promise<Role | null>{
        return this.roles.findOneBy({role_name})
    }


}
