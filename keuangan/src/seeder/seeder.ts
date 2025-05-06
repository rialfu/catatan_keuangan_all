import { Injectable, Logger } from "@nestjs/common";
import { UserSeederService } from "./User/user.service";
import { CategorySeederService } from "./category/category.service";

@Injectable()
export class Seeder {
constructor(
    private readonly logger: Logger,
    private readonly userSeederService: UserSeederService,
    private readonly categorySeederService: CategorySeederService,
) {}
    async seed() {
        await this.user()
        await this.category()
    }
    async user() {
        // this.log
        const res= await this.userSeederService.create()
        this.logger.log('user seeder')
        this.logger.log(res.identifiers)
    }
    async category(){
        const res = await this.categorySeederService.create()
        this.logger.log('category seeder')
        this.logger.log(res.identifiers)
    }
}