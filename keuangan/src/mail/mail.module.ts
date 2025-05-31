import { Module } from '@nestjs/common';
import { MailService } from './mail.service';
import { MailerModule } from '@nestjs-modules/mailer';
import { ConfigModule } from '@nestjs/config';

@Module({
  imports:[
    ConfigModule.forRoot(),
    MailerModule.forRoot({
      transport:{
        host:process.env.smtp_host || 'smtp.gmail.com',
        
        ...(process.env.smtp_auth == '1'? {auth:{
          user: process.env.smtp_user || '',
          pass: process.env.smtp_pass || "",
        }}:{})
        // ...(process.env.smtp_auth ==undefined|| process.env.smtp_auth == null ? {
        //   auth:{
        //     user: process.env.smtp_user || '',
        //     pass: "fvrp upqj idpd svck",
        //   }
        // }: {})
        
      },
      defaults: {
        from: 'noreply@rialfu.com',
      },
    })
  ],
  providers: [MailService],
  exports:[MailService]
})
export class MailModule {}
