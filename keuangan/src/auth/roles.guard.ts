import { Injectable, CanActivate, ExecutionContext, Logger } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { RoleType } from 'src/model/role.entity';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

    canActivate(context: ExecutionContext): boolean {
        
        const requiredRoles = this.reflector.getAllAndOverride<RoleType[]>('roles', [
            context.getHandler(),
            context.getClass(),
        ]);
        if (!requiredRoles) {
            return true;
        }

        const { user } = context.switchToHttp().getRequest();
        Logger.log('rolesguard'+JSON.stringify(user)+'\n'+requiredRoles)
        return requiredRoles.some((role) => user?.roles?.includes(role));
    }
}