import { ExtractJwt, Strategy } from 'passport-jwt';
import { PassportStrategy } from '@nestjs/passport';
import { ExecutionContext, Injectable, Logger, UnauthorizedException } from '@nestjs/common';
// import { JwtService } from '@nestjs/jwt';
// import { jwtConstants } from './constants';

@Injectable()
export class RefreshStrategy extends PassportStrategy(Strategy, 'jwt-refresh') {
    constructor() {
        
        super({
            jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
            ignoreExpiration: false,
            secretOrKey: process.env.secret_refresh_jwt || '1234561',
            // usernameField:'email',
        });
    }
    async validate(payload: any) {
        console.log('refresh')
        // return payload
        return {
            userId: payload.sub,
            email: payload.email,
            roles: payload.roles,
        };
    }
}