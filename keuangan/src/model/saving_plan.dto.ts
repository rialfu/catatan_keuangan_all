import { IsBoolean, IsDateString, IsIn, IsNotEmpty, IsNumber, IsOptional, IsPositive, IsString, MaxLength } from "class-validator";
import { IsInDateReminder } from "src/validations/is_in_date_reminder";
import { IsInTypeReminder } from "src/validations/is_in_type_reminder";


export class CreateSavingPlanDTO{
    @IsString()
    @IsNotEmpty()
    @MaxLength(100)
    name: string;
    
    @IsIn(['monthly', 'weekly', 'daily'], {'message':'Type Reminder must choose monthly, weekly or daily'})
    type_reminder: string;

    @IsInDateReminder()
    date_reminder: string


    @IsDateString()
    @IsNotEmpty()
    target_date: string;

    @IsPositive({'message':'Target Money must more than zero'})
    @IsNotEmpty()
    target_money: number;

    @IsNotEmpty()
    @IsBoolean()
    notification: boolean;
}

export class UpdateSavingPlanDTO{

    @IsNotEmpty()
    id: string;

    @IsOptional()
    @IsString({'message':'Name is must string'})
    @MaxLength(100.,{message:'Name has max 100 characters'})
    name?: string;
    
    @IsOptional()
    @IsIn(['monthly', 'weekly', 'daily'],{'message':'Type Reminder must choose monthly, weekly or daily'})
    @IsOptional()
    @IsInTypeReminder()
    type_reminder?: string;

    @IsInDateReminder()
    date_reminder?: string


    @IsOptional()
    @IsDateString()
    target_date?: string;

    @IsOptional()
    @IsPositive({'message':'Target Money must more than zero'})
    target_money?: number;
    
    @IsOptional()
    @IsBoolean()
    notification?: boolean;
    // tar:number;
}

export class CreateSavingPlanCheckoutDTO{
    @IsNotEmpty()
    @IsPositive({'message':'money must more than zero'})
    money: number;

    @IsDateString()
    @IsNotEmpty()
    date_checkout: string;

    @IsNotEmpty()
    @IsString()
    id_saving_plan:string
}