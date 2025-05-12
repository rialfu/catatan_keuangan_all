import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { User } from './model/user.entity';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { Role } from './model/role.entity';
import { RolesModule } from './roles/roles.module';
import { TransactionModule } from './transaction/transaction.module';
import { Category } from './model/category.entity';
import { CategoryModule } from './category/category.module';
import { ThrottlerGuard, ThrottlerModule, ThrottlerStorageService } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';
import { CustomThrottlerGuard } from './config/CustomThrottle';
import { SavingPlan } from './model/saving_plan.entity';
import { ScheduleModule } from '@nestjs/schedule';
import { SavingPlanModule } from './saving-plan/saving-plan.module';
import { SavingPlanCheckout } from './model/saving_plan_checkout_entity';
import { SavingGoldModule } from './saving-gold/saving-gold.module';
import { Transaction } from './transaction/entities/transaction.entity';
import { SavingGoldOwner } from './saving-gold/entities/saving-gold-owner.entity';
import { SavingGold } from './saving-gold/entities/saving-gold.entity';
import * as admin from "firebase-admin";
import { UserToken } from './model/user_token.entity';


@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal:true,
    }),
    TypeOrmModule.forRoot({
      // timezone:'',
      type:  (process.env.TYPE_DB ?? 'mysql' as any),
      host: process.env.HOST_DB ,
      port:  parseInt(process.env.PORT_DB || '3306'),
      username: process.env.USERNAME_DB,
      password: process.env.PASS_DB,
      database: process.env.DB,
      // supportBigNumbers:true,
      bigNumberStrings:false,
      
      entities: [User, Role, Transaction, Category, SavingPlan, SavingPlanCheckout, SavingGoldOwner, SavingGold, UserToken,],
      synchronize: true,
    }),
    ThrottlerModule.forRoot({
      throttlers: [
        {
          ttl:1000,
          limit:1,
        }
      ],
    }),
    ScheduleModule.forRoot(),
    AuthModule, UsersModule, RolesModule, TransactionModule, CategoryModule, SavingPlanModule, SavingGoldModule,  
    // RolesModule
  ],
 
  controllers: [AppController],
  providers: [AppService, {
    provide: APP_GUARD,
    useClass: CustomThrottlerGuard
  },ThrottlerStorageService],
})
export class AppModule {
  constructor(){
    // admin.initializeApp({
    //   credential:admin.credential.cert({
    //     projectId: process.env.FIREBASE_PROJECT_ID,
    //     clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    //     privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, "\n"),
    //   })
    // })
  }
}
