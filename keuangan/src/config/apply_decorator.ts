import { applyDecorators, UseInterceptors, UsePipes } from "@nestjs/common";
import { InjectUserInterceptor } from "./InjectUserIntercept";

export function InjectUserToQuery() {
  return applyDecorators(InjectUserTo('query'));
}

export function InjectUserToBody() {
  return applyDecorators(InjectUserTo('body'));
}

export function InjectUserToParam() {
  return applyDecorators(InjectUserTo('params'));
}

export function InjectUserTo(context: 'query' | 'body' | 'params') {
  return applyDecorators(UseInterceptors(new InjectUserInterceptor(context)));
}