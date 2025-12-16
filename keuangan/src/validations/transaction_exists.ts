import { Injectable } from "@nestjs/common";
import { registerDecorator, ValidationArguments, ValidationOptions, ValidatorConstraint, ValidatorConstraintInterface } from "class-validator";
import { REQUEST_CONTEXT } from "src/config/InjectUserIntercept";
import { ExtendedValidationArguments } from "src/config/lib";
import { TransactionService } from "src/transaction/transaction.service";

@ValidatorConstraint({ name: 'TransactionExists', async: false })
@Injectable()
export class TransactionExistsValidation implements ValidatorConstraintInterface {
    constructor(private tranService:  TransactionService) {}

    async validate(value: number, args: ExtendedValidationArguments): Promise<boolean>  {
        
        let userId : number = -1;
        const context = args?.object[REQUEST_CONTEXT];
        if(context != null){
            userId = context.user.userId
        }
        return this.tranService.find_transaction({id:value}).then((data)=>{
            if(data == null) return false;
            if(userId != -1){
                if(data.user.id != userId) return false
            }
            return true
        });
    }
    defaultMessage(validationArguments?: ValidationArguments): string {
        
        // const field: string = validationArguments?.property ?? ''
        return `transaction isn't exist in system`
    }
}
export function IsTranExist(
    validationOptions?: ValidationOptions,
) {
    return function (object: any, propertyName: string) {
        registerDecorator({
            name: 'TransactionExists',
            target: object.constructor,
            propertyName: propertyName,
            options: validationOptions,
            validator: TransactionExistsValidation,
        });
    };
}