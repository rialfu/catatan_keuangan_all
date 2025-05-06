import { Test, TestingModule } from '@nestjs/testing';
import { SavingPlanService } from './saving-plan.service';

describe('SavingPlanService', () => {
  let service: SavingPlanService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [SavingPlanService],
    }).compile();

    service = module.get<SavingPlanService>(SavingPlanService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
