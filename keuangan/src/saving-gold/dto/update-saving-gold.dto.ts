import { PartialType } from '@nestjs/mapped-types';
import { CreateSavingGoldDto } from './create-saving-gold.dto';

export class UpdateSavingGoldDto extends PartialType(CreateSavingGoldDto) {}
