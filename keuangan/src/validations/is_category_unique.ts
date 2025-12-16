import {  Injectable } from '@nestjs/common';
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
import { Raw } from 'typeorm';

interface IsCategoryExistsOptions {
    isNeed: boolean;
}

@ValidatorConstraint({ name: 'CategoryUnique', async: false })
@Injectable()
export class CategoryUniqueValidation implements ValidatorConstraintInterface {
    constructor(private catService: CategoryService) {}

    async validate(value: any, args: ExtendedValidationArguments): Promise<boolean>  {
        console.log(value)
        let paramCustom  = args.constraints[0]
        let isNeed : boolean = true
        if(paramCustom != undefined && paramCustom['isNeed'] != undefined){
            isNeed = paramCustom['isNeed']
        }
        // console.log(isNeed)
        let userId : string | null | number= null;
        const context = args?.object[REQUEST_CONTEXT];
        if(context != null){
            userId = context.user.userId
        }
        // return false;
        return this.catService.find(
            {
                'category_name':Raw(alias => `lower(${alias}) =  lower(:search)`, {search: value}),
                // 'user'
            },
            {
                user:true
            }
        ).then((data)=>{
            if(data == null) return true;
            if(data.canDelete ==  false) return false;
            if(data.canDelete && data.user.id == userId) return false;            
            return true;
        });
    }
    defaultMessage(validationArguments?: ValidationArguments): string {
        // return custom field message
        const field: string = validationArguments?.property ?? 'Category'
        return `${field} must unique`
    }
}

// Register The Decorator
export function IsCategoryUnique(
    options?:IsCategoryExistsOptions,
    validationOptions?: ValidationOptions,
) {
    return function (object: any, propertyName: string) {
        registerDecorator({
            name: 'CategoryUnique',
            target: object.constructor,
            propertyName: propertyName,
            constraints: [options],
            options: validationOptions,
            validator: CategoryUniqueValidation,
        });
    };
}