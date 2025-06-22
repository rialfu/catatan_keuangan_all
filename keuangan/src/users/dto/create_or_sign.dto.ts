import { IsNotEmpty, IsString } from "class-validator";

export class CreateOrSignInDTO{
    @IsString()
    @IsNotEmpty()    
    token:string
}