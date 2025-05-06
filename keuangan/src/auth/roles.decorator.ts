import { SetMetadata } from '@nestjs/common';
import { RoleType } from 'src/model/role.entity'; 

export const HasRoles = (...roles: RoleType[]) => SetMetadata('roles', roles);