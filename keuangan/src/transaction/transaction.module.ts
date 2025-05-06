import { Module } from '@nestjs/common';
import { TransactionService } from './transaction.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TransactionController } from './transaction.controller';
import { CategoryModule } from 'src/category/category.module';
import { CategoryExistsValidation } from 'src/validations/category_exists';
import { TransactionExistsValidation } from 'src/validations/transaction_exists';
import { Transaction } from './entities/transaction.entity';

@Module({
  imports:[
    TypeOrmModule.forFeature([Transaction]),
    CategoryModule,
  ],
  providers: [TransactionService, CategoryExistsValidation, TransactionExistsValidation],
  controllers: [TransactionController]
})
export class TransactionModule {}
