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
import { SavingPlanService } from 'src/saving-plan/saving-plan.service';

interface IsInDateReminderOptions {
    isNeed: boolean;
}

@ValidatorConstraint({ name: 'CustomDateReminder', async: true })
@Injectable()
export class DateReminderValidation implements ValidatorConstraintInterface {
     constructor(private service:  SavingPlanService) {}
    
    async validate(value: any, args: ExtendedValidationArguments): Promise<boolean>  {
        
        let type_reminder :string | null = args['object']['type_reminder'] ?? null;
        if(type_reminder ==null && (value == undefined || value == null)) return true;
        if(type_reminder == 'daily') return true;

        try {
            const res = await this.service.get_data_with_search_single({'id':args['object']['id']})
            if(type_reminder == null  && args['object']['id'] != undefined){
                console.log('date')
                if(res == null) return false;
                type_reminder = res.type_reminder
            }
            if(value == undefined || value == null){
                value = res?.date_reminder
            }
            
            if(type_reminder == 'monthly'){
                console.log('date_reminder')
                if(isInt(value)== false) return false
                const data: number = Number(value)
                console.log('date_reminder')
                if(data < 1 || data > 31) return false;
            }else if(type_reminder == 'weekly'){
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