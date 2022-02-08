import { Controller, Get, Patch, Query } from '@nestjs/common';
import { ClinicalAnnotation } from './clinical_annotation.entity';
import { ClinicalAnnotationService } from './clinical_annotation.service';

@Controller('clinical_annotations')
export class ClinicalAnnotationsController {
  constructor(private clinicalAnnotationsService: ClinicalAnnotationService) {}

  @Patch('sync')
  syncData() {
    return this.clinicalAnnotationsService.syncAnnotations();
  }

  @Get()
  async findAll(@Query('id') medicationId: number): Promise<void> {
    return this.clinicalAnnotationsService.findAll(medicationId);
  }
}
