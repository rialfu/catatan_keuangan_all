import { Logger, Module } from "@nestjs/common";
import { ProviderModule } from "./providers/provider";
import { Seeder } from "./seeder";
import { UserSeederModule } from "./User/user.module";
import { ConfigModule } from "@nestjs/config";
import { CategorySeederModule } from "./category/category.module";

@Module({
    imports: [
        ConfigModule.forRoot(),
        ProviderModule, UserSeederModule,  CategorySeederModule
    ],
    providers: [Logger, Seeder],
})
export class SeederModule {}