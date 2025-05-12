import { IsEmail, IsNotEmpty, IsString,MinLength, MaxLength } from "class-validator";

export class CreateUserDTO{
    @IsString()
    @IsNotEmpty()
    @MaxLength(64)
    name: string;

    @IsString()
    @IsNotEmpty()
    @IsEmail()
    email: string;
      
    @IsString()
    @IsNotEmpty()
    @MinLength(8)
    @MaxLength(20)
    password: string;

}
