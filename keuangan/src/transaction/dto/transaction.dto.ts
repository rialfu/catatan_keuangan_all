import { IsDateString,  IsIn, IsNotEmpty, IsNumber, IsOptional, IsString, MaxLength, IsNumberString, Validate, } from "class-validator";
import { CategoryExistsValidation, IsCategoryExist } from "src/validations/category_exists";
import { IsTranExist } from "src/validations/transaction_exists";

export class CreateTransactionDTO{
    @IsString()
    @IsNotEmpty()
    name: string;
    
    @IsString() @MaxLength(300) @IsOptional()
    detail?: string;

    @IsNumber()
    @IsNotEmpty()
    harga: number;

    @IsIn(['debit','credit'])
    @IsNotEmpty()
    debcre: string;

    @IsNumber()
    @IsNotEmpty()
    @IsCategoryExist()
    category: number;

    @IsDateString()
    @IsNotEmpty()
    tanggal_transaksi: string;


}


export class UpdateTransactionDTO {
    @IsNotEmpty()
    @IsNumberString()
    @IsTranExist()
    id: string;

    @IsOptional()
    @IsString()
    name?: string;
    
    @IsOptional()
    @IsString() @MaxLength(300) 
    detail?: string | null;

    @IsOptional()
    @IsNumber()
    harga?: number;

    @IsOptional()
    @IsIn(['debit','credit'])
    debcre?: string;

    @IsNumber()
    @IsOptional()
    @IsCategoryExist({isNeed:false})
    category?: number;

    @IsDateString()
    @IsOptional()
    tanggal_transaksi?: string;
}

export class TransactionGet{
    id: string
    name: string;
    
    detail?: string;

    harga: number;

    debcre: string;

    category: number;

    tanggal_transaksi: string;
}
