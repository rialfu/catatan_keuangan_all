import { Test, TestingModule } from '@nestjs/testing';
import { SavingGoldService } from './saving-gold.service';

describe('SavingGoldService', () => {
  let service: SavingGoldService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [SavingGoldService],
    }).compile();

    service = module.get<SavingGoldService>(SavingGoldService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
