import { Module } from '@nestjs/common';
import { SavingPlanService } from './saving-plan.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SavingPlan } from 'src/model/saving_plan.entity';
import { SavingPlanController } from './saving-plan.controller';
import { SavingPlanCheckout } from 'src/model/saving_plan_checkout_entity';
import { ConfigModule } from '@nestjs/config';
import { DateReminderValidation } from 'src/validations/is_in_date_reminder';

@Module({
  imports:[TypeOrmModule.forFeature([SavingPlan, SavingPlanCheckout]),ConfigModule.forRoot()],
  providers: [SavingPlanService, DateReminderValidation],
  controllers: [SavingPlanController]
})
export class SavingPlanModule {}
