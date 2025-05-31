import { IsEmail, IsNotEmpty, IsString, Min, MinLength } from "class-validator";

export class SendEmailDTO{
    @IsString()
    @IsNotEmpty()
    @IsEmail()
    email: string;
}
export class ResetPasswordDTO{
    @IsString()
    @IsNotEmpty()
    @IsEmail()
    email: string;

    @IsString()
    @IsNotEmpty()
    @MinLength(8)
    password: string;
    
    @IsString()
    @IsNotEmpty()
    code: string;
}