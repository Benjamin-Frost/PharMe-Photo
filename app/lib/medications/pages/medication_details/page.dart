import 'dart:async';
import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MedicationDetailsPage extends StatefulWidget {
  const MedicationDetailsPage({@pathParam required this.id}) : super();

  final String id;

  @override
  State<MedicationDetailsPage> createState() => _MedicationDetailsPageState();
}

Future<Medication> fetchMedication(String setId) async {
  final response = await http
      .get(Uri.http('localhost:3000', '/medications', {'set_id': setId}));

  if (response.statusCode == 200) {
    return Medication.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load medication');
  }
}

class Medication {
  const Medication({
    required this.name,
    required this.manufacturer,
    required this.agents,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    final medication = Medication(
      name: json['name'],
      manufacturer: json['manufacturer'],
      agents: (json['agents'] as String)
          .split(',')
          .map((agent) => agent.trim())
          .toList(),
    );

    medication.fetchClinicalAnnotations();

    return medication;
  }

  Future<void> fetchClinicalAnnotations() async {
    final responses = await Future.wait(agents.map((agent) =>
        http.get(Uri.https('api.pharmgkb.org', '/v1/data/clinicalAnnotation', {
          'relatedChemicals.name': agent.toLowerCase(),
        }))));

    for (final response in responses) {
      final body = jsonDecode(response.body);
      final annotations = (body['data'] as List<dynamic>).where((annotation) {
        final genes = annotation['location']['genes'] as List<dynamic>;
        final relatedGenes = genes.map((gene) => gene['symbol'] as String);

        return relatedGenes.contains('CYP2C9');
      });

      print(annotations.toString());

      for (final annotation in annotations) {
        final allelePhenotype = annotation['allelePhenotypes'].firstWhere(
          (allelePhenotype) => allelePhenotype['allele'] == '*1',
        );

        if (allelePhenotype == null) {
          continue;
        }

        print(allelePhenotype['phenotype']);
      }
    }
  }

  final String name;
  final String manufacturer;
  final List<String> agents;
}

class _MedicationDetailsPageState extends State<MedicationDetailsPage> {
  late Future<Medication> futureMedication;

  @override
  void initState() {
    super.initState();

    futureMedication = fetchMedication(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<Medication>(
        future: futureMedication,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(snapshot.data!.name),
                Text(snapshot.data!.manufacturer),
                Text(snapshot.data!.agents.toString()),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }

          // By default, show a loading spinner.
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
