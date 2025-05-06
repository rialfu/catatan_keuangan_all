import { Module } from '@nestjs/common';
import { SavingGoldService } from './saving-gold.service';
import { SavingGoldController } from './saving-gold.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SavingGold } from './entities/saving-gold.entity';
import { SavingGoldOwner } from './entities/saving-gold-owner.entity';

@Module({
  imports:[TypeOrmModule.forFeature([SavingGold, SavingGoldOwner]),],
  controllers: [SavingGoldController],
  providers: [SavingGoldService],
})
export class SavingGoldModule {}
