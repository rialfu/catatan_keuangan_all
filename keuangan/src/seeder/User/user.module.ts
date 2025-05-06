import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { User } from "src/model/user.entity";
import { UserSeederService } from "./user.service";
import { Role } from "src/model/role.entity";

@Module({
    imports: [TypeOrmModule.forFeature([User, Role])],
    providers: [UserSeederService],
    exports: [UserSeederService],
  })
export class UserSeederModule {}