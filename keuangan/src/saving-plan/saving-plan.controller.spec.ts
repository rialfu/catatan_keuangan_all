import { Test, TestingModule } from '@nestjs/testing';
import { SavingPlanController } from './saving-plan.controller';

describe('SavingPlanController', () => {
  let controller: SavingPlanController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [SavingPlanController],
    }).compile();

    controller = module.get<SavingPlanController>(SavingPlanController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
