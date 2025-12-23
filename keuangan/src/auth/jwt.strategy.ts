import { ExtractJwt, Strategy } from 'passport-jwt';
import { PassportStrategy } from '@nestjs/passport';
import { ExecutionContext, Injectable, Logger, UnauthorizedException } from '@nestjs/common';
// import { JwtService } from '@nestjs/jwt';
// import { jwtConstants } from './constants';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
    constructor() {
        
        super({
            jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
            ignoreExpiration: false,
            // secretOrKey:'123456'
            secretOrKey: process.env.secret_jwt || '1234562',
            // usernameField:'email',
        });
    }
    async validate(payload: any) {
        
        return {
            userId: payload.sub,
            email: payload.email,
            roles: payload.roles,
        };
    }
}