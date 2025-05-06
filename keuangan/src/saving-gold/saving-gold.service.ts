import { Injectable } from '@nestjs/common';
import { CreateSavingGoldDto } from './dto/create-saving-gold.dto';
import { UpdateSavingGoldDto } from './dto/update-saving-gold.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { SavingGoldOwner } from './entities/saving-gold-owner.entity';
import { Repository } from 'typeorm';
import { SavingGold } from './entities/saving-gold.entity';

@Injectable()
export class SavingGoldService {
  constructor(
    @InjectRepository(SavingGoldOwner)
    private readonly savingOwnerRepo: Repository<SavingGoldOwner>,
    @InjectRepository(SavingGold)
    private readonly asvingRepo: Repository<SavingGold>,){

  }
  create(createSavingGoldDto: CreateSavingGoldDto) {
    return 'This action adds a new savingGold';
  }

  findAll(search:{[key: string]: any}): Promise<SavingGold[]> {
    return this.asvingRepo.find({
      // where:{user:{id:'d'}}
      where:search
    })
  }

  findOne(id: number) {
    return `This action returns a #${id} savingGold`;
  }

  update(id: number, updateSavingGoldDto: UpdateSavingGoldDto) {
    return `This action updates a #${id} savingGold`;
  }

  remove(id: number) {
    return `This action removes a #${id} savingGold`;
  }
}
