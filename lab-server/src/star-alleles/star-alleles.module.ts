import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { S3Module } from '../s3/s3.module';
import { User } from '../user/entities/user.entity';
import { StarAllelesController } from './star-alleles.controller';
import { StarAllelesService } from './star-alleles.service';

@Module({
    controllers: [StarAllelesController],
    imports: [TypeOrmModule.forFeature([User]), S3Module],
    providers: [StarAllelesService],
})
export class StarAllelesModule {}
