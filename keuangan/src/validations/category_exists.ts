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

interface IsCategoryExistsOptions {
    isNeed: boolean;
}

@ValidatorConstraint({ name: 'CategoryExists', async: false })
@Injectable()
export class CategoryExistsValidation implements ValidatorConstraintInterface {
    constructor(private catService: CategoryService) {}

    async validate(value: number, args: ExtendedValidationArguments): Promise<boolean>  {
        // console.log(args.object);
        // console.log('custom')
        // const request = args.object['request'];
        let paramCustom  = args.constraints[0]
        let isNeed : boolean = true
        if(paramCustom != undefined && paramCustom['isNeed'] != undefined){
            isNeed = paramCustom['isNeed']
        }
        // console.log(isNeed)
        let userId : string = ''
        const context = args?.object[REQUEST_CONTEXT];
        if(context != null){
            userId = context.user.userId
        }
        
        return this.catService.find({'id':value},{user:true}).then((data)=>{
            // if(isNeed == false) return true
            if(data == null) return false
            if(userId != ''){
                if(data.canDelete && data.user.id != userId) return false
            }
            return true;
        });
    }
    defaultMessage(validationArguments?: ValidationArguments): string {
        // return custom field message
        const field: string = validationArguments?.property ?? ''
        // console.log(field)
        return `${field} isn't exist in system`
    }
//   defaultMessage() {
//     return `category doesn't exists in system`;
//   }
}

// Register The Decorator
export function IsCategoryExist(
    options?:IsCategoryExistsOptions,
    validationOptions?: ValidationOptions,
) {
    return function (object: any, propertyName: string) {
        registerDecorator({
        name: 'CategoryExists',
        target: object.constructor,
        propertyName: propertyName,
        constraints: [options],
        options: validationOptions,
        validator: CategoryExistsValidation,
        });
    };
}