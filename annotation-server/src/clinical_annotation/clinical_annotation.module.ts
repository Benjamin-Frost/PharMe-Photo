import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ClinicalAnnotationsController } from './clinical_annotation.controller';
import { ClinicalAnnotation } from './clinical_annotation.entity';
import { ClinicalAnnotationService } from './clinical_annotation.service';
import { MedicationsModule } from 'src/medications/medications.module';

@Module({
  imports: [
    HttpModule,
    TypeOrmModule.forFeature([ClinicalAnnotation]),
    MedicationsModule,
  ],
  providers: [ClinicalAnnotationService],
  controllers: [ClinicalAnnotationsController],
})
export class AnnotationsModule {}
