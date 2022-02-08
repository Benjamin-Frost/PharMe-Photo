import { Injectable, NotFoundException } from '@nestjs/common';
import { Medication } from './medications.entity';
import { RxNormMapping } from './rxnormmappings.entity';
import { Ingredient } from './ingredients.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as fs from 'fs';
import * as path from 'path';
import * as os from 'os';
import * as https from 'https';
import { parseStringPromise } from 'xml2js';
import { downloadAndUnzip } from '../common/utils/download-unzip';

@Injectable()
export class MedicationsService {
  constructor(
    @InjectRepository(RxNormMapping)
    private rxNormMappingRepository: Repository<RxNormMapping>,
    @InjectRepository(Medication)
    private medicationRepository: Repository<Medication>,
    @InjectRepository(Ingredient)
    private ingredientRepository: Repository<Ingredient>,
  ) {}

  async findOne(id: number): Promise<Medication> {
    return this.medicationRepository.findOne(id, {
      relations: ['ingredients'],
    });
  }

  async findSetId(setId: string): Promise<Medication> {
    const mappings = await this.rxNormMappingRepository.find({
      where: {
        setid: setId,
      },
      relations: ['medication'],
    });

    if (!mappings.length) {
      throw new NotFoundException('Id could not be found in RxNormMappings!');
    }

    if (mappings[0].medication) {
      const medication = await this.medicationRepository.findOne(
        mappings[0].medication.id,
        {
          relations: ['ingredients'],
        },
      );

      return medication;
    }

    const url = `https://dailymed.nlm.nih.gov/dailymed/services/v2/spls/${setId}.xml`;

    const chunk = await new Promise((resolve, reject) => {
      https
        .get(url, (res) => {
          const data = [];
          res.on('data', (chunk) => {
            data.push(chunk);
          });

          res.on('end', () => {
            resolve(Buffer.concat(data));
          });
        })
        .on('error', (error) => {
          reject(error);
        });
    });

    const result = await parseStringPromise(chunk);

    const medication = new Medication();

    const manufacturedProduct =
      result.document.component[0].structuredBody[0].component[0].section[0]
        .subject[0].manufacturedProduct[0].manufacturedProduct[0];

    medication.name = manufacturedProduct.name[0];
    medication.manufacturer =
      result.document.author[0].assignedEntity[0].representedOrganization[0].name[0];
    medication.agents =
      manufacturedProduct.asEntityWithGeneric[0].genericMedicine[0].name[0];

    const quantity = manufacturedProduct.asContent[0].quantity[0];

    medication.numeratorQuantity = parseInt(quantity.numerator[0]['$'].value);
    medication.numeratorUnit = quantity.numerator[0]['$'].unit;

    medication.denominatorQuantity = parseInt(
      quantity.denominator[0]['$'].value,
    );
    medication.denominatorUnit = quantity.denominator[0]['$'].unit;

    const ingredients: Ingredient[] = [];

    if (manufacturedProduct.ingredient) {
      for (const xmlIngredient of manufacturedProduct.ingredient) {
        const ingredient = new Ingredient();

        if (xmlIngredient.quantity) {
          ingredient.numeratorQuantity = parseInt(
            xmlIngredient.quantity[0].numerator[0]['$'].value,
          );
          ingredient.numeratorUnit =
            xmlIngredient.quantity[0].numerator[0]['$'].unit;

          ingredient.denominatorQuantity =
            xmlIngredient.quantity[0].denominator[0]['$'].value;
          ingredient.denominatorUnit =
            xmlIngredient.quantity[0].denominator[0]['$'].unit;
        }

        ingredient.name = xmlIngredient.ingredientSubstance[0].name[0];

        ingredients.push(ingredient);
      }
    }

    medication.ingredients = ingredients;

    const rxNormMappings = await this.rxNormMappingRepository.find({
      where: {
        setid: setId,
      },
    });

    medication.rxNormMappings = rxNormMappings;

    return await this.medicationRepository.save(medication);
  }

  async removeMedication(id: number): Promise<void> {
    this.medicationRepository.delete(id);
  }
}
