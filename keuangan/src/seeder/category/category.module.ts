import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { CategorySeederService } from "./category.service";
import { Category } from "src/model/category.entity";

@Module({
    imports: [TypeOrmModule.forFeature([Category])],
    providers: [CategorySeederService],
    exports: [CategorySeederService],
  })
export class CategorySeederModule {}