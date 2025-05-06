import { Test, TestingModule } from '@nestjs/testing';
import { SavingGoldController } from './saving-gold.controller';
import { SavingGoldService } from './saving-gold.service';

describe('SavingGoldController', () => {
  let controller: SavingGoldController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [SavingGoldController],
      providers: [SavingGoldService],
    }).compile();

    controller = module.get<SavingGoldController>(SavingGoldController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
