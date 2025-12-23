import { Injectable } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { JwtService } from '@nestjs/jwt';
import { User } from 'src/model/user.entity';

@Injectable()
export class AuthService {
    constructor(private usersService: UsersService, private jwtService: JwtService,) {}

    async validateUser(email: string, pass: string): Promise<any> {
        const user = await this.usersService.findOne(email);
        console.log(email, pass)
        if(user == null) return null;
        if (user.password === pass) {
            const { password, ...result } = user;
            return result;
        }
        return null;
    }
    async login(user: User) {
        // this.jwtService.signAsync()
        const payload = {
            email: user.email,
            sub: user.id,
            roles: user.role.role_name,
        };
        // this.usersService.findOne({'email'})
        var token =this.jwtService.sign(payload,)
        var refresh = this.jwtService.sign(payload, {secret: process.env.secret_refresh_jwt, expiresIn:'7d'})
        return {
            access_token: token,
            refesh_token: refresh,
            name:user.name,
            email:user.email,
        };
    }

}
