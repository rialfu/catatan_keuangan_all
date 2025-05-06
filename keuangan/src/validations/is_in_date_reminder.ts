import { ExecutionContext, Injectable } from '@nestjs/common';
import {
  ValidatorConstraint,
  ValidatorConstraintInterface,
  ValidationOptions,
  registerDecorator,
  ValidationArguments,
} from 'class-validator';
import { CategoryService } from '../category/category.service';
import { ExtendedValidationArguments } from 'src/config/lib';
import { REQUEST_CONTEXT } from 'src/config/InjectUserIntercept';

interface IsInDateReminderOptions {
    isNeed: boolean;
}

@ValidatorConstraint({ name: 'CustomTypeReminder', async: true })
@Injectable()
export class DateReminderValidation implements ValidatorConstraintInterface {
    constructor() {}
    
    async validate(value: any, args: ExtendedValidationArguments): Promise<boolean>  {
        if(args['object']['type_reminder'] == 'daily' || args['object']['type_reminder'] == undefined || args['object']['type_reminder'] == null) return true
        if(typeof value != 'string') return false;
        
        try {
            if(args['object']['type_reminder'] == 'monthly'){
                if(isInt(value)== false) return false
                const data: number = Number(value)
                if(data < 1 || data > 31) return false;
            }else if(args['object']['type_reminder'] == 'weekly'){
                if(value != 'monday' && value != 'tuesday' && value != 'wednesday' && value != 'thursday' && value != 'friday' && value != 'saturday' && value != 'sunday' ) return false;
            }
        }catch(err) {
            return false;
        }
        return true;
        
        
    }
    defaultMessage(validationArguments?: ValidationArguments): string {
        // return custom field message
        const field: string = validationArguments?.property ?? ''
        // console.log(field)
        return `${field} is not suitable`
    }
//   defaultMessage() {
//     return `category doesn't exists in system`;
//   }
}
function isInt(n) {
    return n % 1 === 0;
}
// Register The Decorator
export function IsInDateReminder(
    options?:IsInDateReminderOptions,
    validationOptions?: ValidationOptions,
) {
    return function (object: any, propertyName: string) {
        registerDecorator({
            name: 'DateReminder',
            target: object.constructor,
            propertyName: propertyName,
            constraints: [options],
            options: validationOptions,
            validator: DateReminderValidation,
        });
    };
}