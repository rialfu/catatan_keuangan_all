import { IsNotEmpty, IsNumber, IsString } from "class-validator";
import { IsCategoryUnique } from "src/validations/is_category_unique";
import { Entity } from "typeorm";

export class CreateCategoryDTO{
    @IsString()
    @IsNotEmpty()
    @IsCategoryUnique()
    category_name: string;
}
export class UpdateCategoryDTO{
    @IsString()
    @IsNotEmpty()
    category_name: string;

    @IsNotEmpty()
    @IsNumber()
    id: number;
}