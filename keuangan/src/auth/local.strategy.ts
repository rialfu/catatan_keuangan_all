import { Strategy } from 'passport-local';
import { PassportStrategy } from '@nestjs/passport';
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { AuthService } from './auth.service';
import { Logger } from '@nestjs/common';

@Injectable()
export class LocalStrategy extends PassportStrategy(Strategy) {
  constructor(private authService: AuthService) {
    super({ usernameField: "email"});
  }

  async validate(username: string, password: string): Promise<any> {
    Logger.log('validate')
    const user = await this.authService.validateUser(username, password);
    // Logger.log(user)
    if (!user) {
      console.log('error')
      throw new UnauthorizedException();
    }
    return user;
  }
}