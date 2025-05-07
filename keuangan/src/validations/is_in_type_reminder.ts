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

interface IsInTypeReminderOptions {
    isNeed: boolean;
}

@ValidatorConstraint({ name: 'CustomTypeReminder', async: true })
@Injectable()
export class TypeReminderValidation implements ValidatorConstraintInterface {
     constructor(private service:  SavingPlanService) {}
    
    async validate(value: any, args: ExtendedValidationArguments): Promise<boolean>  {
        let date_reminder :string | null = args['object']['date_reminder'] ?? null;
        if(date_reminder == null && value !=undefined ) return true;

        if(value == 'daily') return true;
        
        try {
            if((date_reminder == undefined || date_reminder == null ) && args['object']['id'] != undefined){
               const res = await this.service.get_data_with_search_single({'id':args['object']['id']})
               if(res == null) return false;
               date_reminder = res.date_reminder ?? null;
            //    if((res.date_reminder ==null || res.date_reminder == undefined ) && value != 'daily') return false;
            //    if(res.date_reminder =='monday' || res.date_reminder =='tuesday' || res.date_reminder =='wednesday' || res.date_reminder =='thursday' || res.date_reminder =='friday' || res.date_reminder =='saturday' || res.date_reminder =='sunday'){
            //         if(value != 'weekly' ) return false;
            //         // return true;
            //    }
            //    if(isInt(res.date_reminder) && value != 'monthly') return false;
            //    return true;
               
            }
            
            if(isInt(date_reminder) && value =='monthly' ) return true;
            if(( date_reminder =='monday' || date_reminder =='tuesday' || date_reminder =='wednesday' || date_reminder =='thursday' || date_reminder =='friday' || date_reminder =='saturday' || date_reminder =='sunday') && value=='weekly') {
                return true;
            }
        }catch(err) {
            return false;
        }
        return false;
        
        
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
export function IsInTypeReminder(
    options?:IsInTypeReminderOptions,
    validationOptions?: ValidationOptions,
) {
    return function (object: any, propertyName: string) {
        registerDecorator({
            name: 'TypeReminder',
            target: object.constructor,
            propertyName: propertyName,
            constraints: [options],
            options: validationOptions,
            validator: TypeReminderValidation,
        });
    };
}