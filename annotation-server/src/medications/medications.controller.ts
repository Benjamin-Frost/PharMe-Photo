import { Controller, Get, Param, Delete, Query } from '@nestjs/common';
import { Medication } from './medications.entity';
import { MedicationsService } from './medications.service';

@Controller('medications')
export class MedicationsController {
  constructor(private medicationsService: MedicationsService) {}

  @Get(':id')
  async findOne(@Param('id') id: number): Promise<Medication> {
    return this.medicationsService.findOne(id);
  }

  @Get()
  async findAll(@Query('set_id') id: string): Promise<Medication> {
    return this.medicationsService.findSetId(id);
  }

  @Delete(':id')
  remove(@Param('id') id: number) {
    return this.medicationsService.removeMedication(id);
  }
}
