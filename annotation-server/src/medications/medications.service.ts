import { spawn } from 'child_process';
import * as fs from 'fs';
import * as os from 'os';
import * as path from 'path';

import { HttpService } from '@nestjs/axios';
import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import * as JSONStream from 'JSONStream';
import { Repository } from 'typeorm';

import { Drug } from './interfaces/drugbank.interface';
import { GeneVariant } from './interfaces/geneVariant.interface';
import { PGxFinding } from './interfaces/pgxFinding.interface';
import { Medication } from './medication.entity';
import { getClinicalAnnotations } from './pharmgkb';

@Injectable()
export class MedicationsService {
    private readonly logger = new Logger(MedicationsService.name);

    constructor(
        private configService: ConfigService,
        @InjectRepository(Medication)
        private medicationRepository: Repository<Medication>,
        private httpService: HttpService,
    ) {}

    async clearAllMedicationData(): Promise<void> {
        await this.medicationRepository.delete({});
    }

    async fetchAllMedications(): Promise<void> {
        await this.clearAllMedicationData();
        const jsonPath = await this.getJSONfromZip();
        this.logger.log('Extracting medications from JSON ...');
        const drugs = await this.getDataFromJSON(jsonPath);
        this.logger.log('Writing to database ...');
        const medications = drugs.map((drug) => Medication.fromDrug(drug));
        const savedMedications = await this.medicationRepository.save(
            medications,
        );
        this.logger.log(
            `Successfully saved ${savedMedications.length} medications!`,
        );
    }

    getJSONfromZip(): Promise<string> {
        const jsonPath = path.join(os.tmpdir(), 'drugbank-data.json');
        const proc = spawn(
            path.join(__dirname, './scripts/zipped-xml-to-json'),
            [
                this.configService.get<string>('DRUGBANK_ZIP'),
                this.configService.get<string>('DRUGBANK_XML'),
                jsonPath,
            ],
        );
        proc.on('error', (error) => {
            this.logger.error(error);
        });
        proc.stdout.on('data', (data: string) => {
            this.logger.log(data);
        });
        proc.stderr.on('data', (data: string) => {
            this.logger.error(data);
        });
        return new Promise((resolve, reject) => {
            proc.on('exit', (code) => {
                if (code === 0) resolve(jsonPath);
                else reject(`Subprocess exited with ${code}.`);
            });
        });
    }

    getDataFromJSON(path: string): Promise<Drug[]> {
        const jsonStream = fs
            .createReadStream(path)
            .pipe(JSONStream.parse('drugbank.drug.*'));
        const drugs: Array<Drug> = [];
        const clearLine = () => {
            process.stdout.write(`\r${String.fromCharCode(27)}[0J`);
        };
        jsonStream.on('data', (drug: Drug) => {
            if (!(drugs.length % 50)) {
                clearLine();
                process.stdout.write(`${drugs.length} drugs parsed ...`);
            }
            drugs.push(drug);
        });
        return new Promise<Drug[]>((resolve, reject) => {
            jsonStream.on('error', () => {
                clearLine();
                reject();
            });
            jsonStream.on('end', () => {
                clearLine();
                resolve(drugs);
            });
        });
    }

    async findAll(): Promise<Medication[]> {
        return await this.medicationRepository.find({
            select: ['id', 'name', 'description', 'synonyms'],
        });
    }

    async ensureRelatedGenes(medicationId: number): Promise<void> {
        const medication = await this.medicationRepository.findOne({
            where: { id: medicationId },
        });
        if (!medication.relatedGenes) {
            const clinicalAnnotations = await getClinicalAnnotations(
                this.httpService,
                medication.pharmgkbId,
            );
            medication.relatedGenes = clinicalAnnotations.flatMap(
                (clinicalAnnotation) =>
                    clinicalAnnotation.location.genes.map(
                        (gene) => gene.symbol,
                    ),
            );
            await this.medicationRepository.update(medication.id, {
                relatedGenes: medication.relatedGenes,
            });
        }
    }

    async findOne(id: number): Promise<Medication> {
        await this.ensureRelatedGenes(id);
        return await this.medicationRepository.findOne({
            where: { id },
            select: ['id', 'name', 'description', 'synonyms', 'relatedGenes'],
        });
    }

    async getAnnotations(
        id: number,
        geneVariants: Array<GeneVariant>,
    ): Promise<PGxFinding[]> {
        const { pharmgkbId } = await this.medicationRepository.findOne({
            where: { id },
        });
        const clinicalAnnotations = await getClinicalAnnotations(
            this.httpService,
            pharmgkbId,
        );
        const findings: Array<PGxFinding> = [];
        for (const annotation of clinicalAnnotations) {
            if (annotation.location.genes.length !== 1) continue;
            const geneVariant = geneVariants.find(
                ({ gene }) => gene === annotation.location.genes[0].symbol,
            );
            if (!geneVariant) continue;
            for (const phenotype of annotation.allelePhenotypes) {
                if (
                    phenotype.allele === geneVariant.variant1 ||
                    phenotype.allele === geneVariant.variant2
                ) {
                    const finding: PGxFinding = {
                        gene: geneVariant.gene,
                        description: phenotype.phenotype,
                    };
                    findings.push(finding);
                }
            }
        }

        return findings;
    }
}
