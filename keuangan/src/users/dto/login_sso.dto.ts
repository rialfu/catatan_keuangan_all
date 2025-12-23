import { IsNotEmpty, IsOptional, IsString, MaxLength, MinLength } from "class-validator";

export class LogInSSODTO{
    @IsString()
    @IsNotEmpty()    
    token:string

    // @IsOptional()
    // @IsString()
    // @MaxLength(64)
    // name: string;
    
    // @IsOptional()
    // @IsString()
    // @MinLength(8)
    // @MaxLength(20)
    // password: string;
}