import { MailerService } from '@nestjs-modules/mailer';
import { Injectable } from '@nestjs/common';

@Injectable()
export class MailService {
    constructor(private readonly mailerService: MailerService) {}
    public example(email: string, code:string): void {
      this.mailerService.sendMail({
        to: email,
        subject: 'Code for Reset Password', // Subject line
        // text: 'This is code for reset:'+code+, // plaintext body
        html: 'This is code for reset : <b>'+code+'</b>', // HTML body content
      })
      .then(() => {

      })
      .catch((err) => {console.log(err)});
  }
}
