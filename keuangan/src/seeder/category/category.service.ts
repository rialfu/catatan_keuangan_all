import { Injectable, Logger } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { InsertResult, Repository } from "typeorm";
import { category } from "./data";
import { Category } from "src/model/category.entity";

@Injectable()
export class CategorySeederService {
  /**
   * Create an instance of class.
   *
   * @constructs
   *
   * @param {Repository<Category>} categoryRepository
   */
  constructor(
    @InjectRepository(Category)
    private readonly categoryRepository: Repository<Category>,
  ) {}
  /**
   * Seed all languages.
   *
   * @function
   */
  create(): Promise<InsertResult> {
    Logger.log('seeder category create')
    const result = this.categoryRepository.createQueryBuilder().insert().into(Category).values(category).execute()
    return result
  }
}