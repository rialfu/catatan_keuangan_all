import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { UsersModule } from 'src/users/users.module';
import { PassportModule } from '@nestjs/passport';
import { LocalStrategy } from './local.strategy';
import { JwtModule } from '@nestjs/jwt';
import { JwtStrategy } from './jwt.strategy';
import { ConfigModule } from '@nestjs/config';
import { RefreshStrategy } from './refresh.strategy';

@Module({
  imports: [UsersModule, PassportModule, 
    ConfigModule.forRoot(),
    JwtModule.register({
      // secret:'123456',
      secret:process.env.secret_jwt || '123456',
      global:true,
      signOptions : {expiresIn : '1d'}
    })
  ],
  providers: [AuthService, LocalStrategy, JwtStrategy,RefreshStrategy, ],
  exports: [AuthService]
})
export class AuthModule {}
