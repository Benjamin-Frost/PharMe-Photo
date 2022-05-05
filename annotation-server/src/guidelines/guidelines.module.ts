import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { GenePhenotypesModule } from '../gene-phenotypes/gene-phenotypes.module';
import { MedicationsModule } from '../medications/medications.module';
import { Guideline } from './guideline.entity';
import { GuidelinesController } from './guidelines.controller';
import { GuidelinesService } from './guidelines.service';

@Module({
    imports: [
        TypeOrmModule.forFeature([Guideline]),
        MedicationsModule,
        GenePhenotypesModule,
    ],
    controllers: [GuidelinesController],
    providers: [GuidelinesService],
})
export class GuidelinesModule {}
