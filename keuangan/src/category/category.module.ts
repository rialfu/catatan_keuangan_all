import { Module } from '@nestjs/common';
import { CategoryService } from './category.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Category } from 'src/model/category.entity';
import { CategoryController } from './category.controller';

@Module({
  imports:[TypeOrmModule.forFeature([Category]),],
  providers: [CategoryService,],
  exports:[CategoryService],
  controllers: [CategoryController],
})
// @Module({
//   imports:[
//     TypeOrmModule.forFeature([Transaction]),
//     CategoryModule,
//   ],
//   providers: [TransactionService],
//   controllers: [TransactionController]
// })
export class CategoryModule {}
