import { ExecutionContext, HttpException, Injectable } from "@nestjs/common";
import { ThrottlerGuard, ThrottlerLimitDetail, ThrottlerRequest } from "@nestjs/throttler";

@Injectable()
export class CustomThrottlerGuard extends ThrottlerGuard {
    protected errorMessage: string = "Message Too many request, Please Wait";
  // Override the default tracking logic
//   @override
    // protected getTracker(req: Record<string, any>): Promise<string> {
    //     // console.log(req)
    //     return req.ip
    //     // Use the user's ID for tracking if authenticated, else use the IP
    //     // return req.user?.id || req.ip;
    // }
    // getKey(context: ExecutionContext): string {
    //     const request = context.switchToHttp().getRequest<Request>();
    //     return request.ip; // Misalnya menggunakan IP, bisa diubah sesuai kebutuhan
    // }
    
    
  // Customize the rate-limit based on user roles
//   protected getLimit(context: ExecutionContext): number {
//     const request = context.switchToHttp().getRequest();
//     const user = request.user;

//     if (user?.role === 'admin') {
//       return 10; // Admins can make 10 requests in the TTL window
//     } else {
//       return 5; // Regular users get 5 requests
//     }
//   }

//   // Set a global time-to-live of 60 seconds for all requests
//   protected getTTL(context: ExecutionContext): number {
//     return 60; 
//   }
    protected throwThrottlingException(context: ExecutionContext, throttlerLimitDetail: ThrottlerLimitDetail): Promise<void>{
        this.getErrorMessage(context, throttlerLimitDetail)
        throw new HttpException({'message':`Too many request, Please Wait ${throttlerLimitDetail.timeToExpire}s`, 'remaining':throttlerLimitDetail.timeToExpire}, 429);
    }
    protected getErrorMessage(context: ExecutionContext, throttlerLimitDetail: ThrottlerLimitDetail): Promise<string>{
        // console.log(throttlerLimitDetail)
        return new Promise(function(resolve, reject){
            resolve(`Too many request, Please Wait ${throttlerLimitDetail.timeToExpire}`)
        })
    }
}