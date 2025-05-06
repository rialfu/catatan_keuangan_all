import { Module } from "@nestjs/common";
import { ConfigModule } from "@nestjs/config";
import { TypeOrmModule } from "@nestjs/typeorm";
import { Category } from "src/model/category.entity";
import { Role } from "src/model/role.entity";
import { SavingPlan } from "src/model/saving_plan.entity";
import { SavingPlanCheckout } from "src/model/saving_plan_checkout_entity";
// import { Transaction } from "src/model/transaction.entity";

import { User } from "src/model/user.entity";
import { Transaction } from "src/transaction/entities/transaction.entity";

@Module({
    imports: [
        ConfigModule.forRoot(),
        TypeOrmModule.forRoot({
            type: 'mysql',
            host: process.env.HOST_DB || 'localhost' ,
            port:  parseInt(process.env.PORT_DB || '3306'),
            username: process.env.USERNAME_DB || 'root',
            password: process.env.PASS_DB || '',
            database: process.env.DB || 'test_nest',
             entities: [User, Role, Transaction, Category, SavingPlan, SavingPlanCheckout],
            synchronize: true,
        })
    ],
  })
  export class ProviderModule {}