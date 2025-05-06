import { Injectable, Logger } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { User } from "src/model/user.entity";
import { InsertResult, Repository } from "typeorm";
import { users } from "./data";
import { Role } from "src/model/role.entity";

@Injectable()
export class UserSeederService {
  /**
   * Create an instance of class.
   *
   * @constructs
   *
   * @param {Repository<User>} userRepository
   */
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Role)
    private readonly roleRepository: Repository<Role>,
  ) {}
  /**
   * Seed all languages.
   *
   * @function
   */
  async create(): Promise<InsertResult> {
    // const AppDataSource = new DataSource({
    //     type: "mysql",
    //     host: service,
    //     port: 3306,
    //     username: "test",
    //     password: "test",
    //     database: "test",
    // })
    Logger.log('seeder create')
    // const res =await this.userRepository.find()
    // await this.roleRepository.createQueryBuilder().insert().into(Role).values([{'role_name':'admin'}, {'role_name':'user'}]).execute()
    // console.log(res)
    const result = this.userRepository.createQueryBuilder().insert().into(User).values(users).execute()
    return result
    
  }
}