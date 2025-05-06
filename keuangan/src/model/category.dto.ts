import { IsNotEmpty, IsNumber, IsString } from "class-validator";
import { Entity } from "typeorm";

export class CreateCategoryDTO{
    @IsString()
    @IsNotEmpty()
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