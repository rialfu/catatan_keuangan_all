import { NestFactory } from "@nestjs/core";
import { SeederModule } from "./seeder.module";
import { Logger } from "@nestjs/common";
import { Seeder } from "./seeder";
import { ConfigService } from "@nestjs/config";

async function bootstrap() {
    // const appContext = await NestFactory.createApplicationContext(SeederModule)
    // const configService =appContext.get(ConfigService)

  NestFactory.createApplicationContext(SeederModule)
    .then(appContext => {
      const logger = appContext.get(Logger);
      const seeder = appContext.get(Seeder);
      seeder
        .seed()
        .then(() => {
          logger.debug('Seeding complete!');
        })
        .catch(error => {
          logger.error('Seeding failed!');
          throw error;
        })
        .finally(() => appContext.close());
  })
  .catch(error => {
    throw error;
  });
}
bootstrap();