import { Module } from '@nestjs/common';
import { UsersService } from './users.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from 'src/model/user.entity';
import { UserToken } from 'src/model/user_token.entity';

@Module({
  imports:[TypeOrmModule.forFeature([User, UserToken])],
  providers: [UsersService],
  exports:[UsersService]
})
export class UsersModule {}
