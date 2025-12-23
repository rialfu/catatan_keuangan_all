import { IsNotEmpty, IsOptional, IsString, MaxLength, MinLength } from "class-validator";

export class RegisterSSODTO{
    @IsString()
    @IsNotEmpty()    
    token:string

    @IsNotEmpty()
    @IsString()
    @MaxLength(64)
    name: string;
    
    @IsNotEmpty()
    @IsString()
    @MinLength(8)
    @MaxLength(20)
    password: string;
}