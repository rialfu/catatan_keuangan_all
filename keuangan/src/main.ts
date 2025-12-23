import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { useContainer, ValidationError } from 'class-validator';

declare const module: any;

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.useGlobalPipes(new ValidationPipe(
    {
      transform:true, 
      // exceptionFactory:(validationErrors: ValidationError[] = []) => {
      //   console.log(validationErrors)
  
      // }
    }
  ));
  app.enableCors({
    origin:'*',
    methods:["GET", "POST", "PUT", "DELETE","OPTIONS", "PATCH"],
    allowedHeaders: ['Origin', 'X-Requested-With', 'Content-Type', 'Accept', 'Authorization'],
  })
  // await app.startAllMicroservices()
  useContainer(app.select(AppModule), { fallbackOnErrors: true });
  await app.listen(process.env.PORT ?? 3000);

  if (module.hot) {
    module.hot.accept();
    module.hot.dispose(() => app.close());
  }
}
bootstrap();
