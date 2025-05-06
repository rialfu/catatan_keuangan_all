import { UserJWT } from "src/model/user_jwt.dto";
import { REQUEST_CONTEXT } from "./InjectUserIntercept";
import { ValidationArguments } from "class-validator";

export type Nullable<T> = T | null;


export interface ExtendedValidationArguments extends ValidationArguments {
  object: {
    [REQUEST_CONTEXT]: {
      user:  UserJWT; // IUser is my interface for User class
    };
  };
}