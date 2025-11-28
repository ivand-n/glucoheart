import 'package:intl/intl.dart';

class Examination {
  final String id;
  final double? bloodGlucoseRandom; // GDS (mg/dL)
  final double? bloodGlucoseFasting; // GDP (mg/dL)
  final double? hba1c; // HbA1c (%)
  final double? hemoglobin; // Hb (g/dL)
  final double? bloodGlucosePostprandial; // Gula darah 2 jam setelah makan (mg/dL)
  final String bloodPressure; // Tekanan darah (mmHg) - format: "120/80"
  final DateTime dateTime;
  final String? notes;

  Examination({
    required this.id,
    this.bloodGlucoseRandom,
    this.bloodGlucoseFasting,
    this.hba1c,
    this.hemoglobin,
    this.bloodGlucosePostprandial,
    required this.bloodPressure,
    required this.dateTime,
    this.notes,
  });

  // Helper untuk format tanggal yang konsisten
  String get formattedDate => DateFormat('dd MMM yyyy, HH:mm').format(dateTime);

  // Helper untuk mendapatkan sistole dan diastole dari blood pressure
  int get systolic => int.parse(bloodPressure.split('/')[0]);
  int get diastolic => int.parse(bloodPressure.split('/')[1]);

  // Deskripsi untuk tampilan singkat
  String get summary {
    List<String> details = [];

    if (bloodGlucoseFasting != null) {
      details.add('GDP: $bloodGlucoseFasting mg/dL');
    }
    if (bloodGlucoseRandom != null) {
      details.add('GDS: $bloodGlucoseRandom mg/dL');
    }
    details.add('TD: $bloodPressure mmHg');

    return details.join(', ');
  }

  // Factory constructor dari map/json
  factory Examination.fromJson(Map<String, dynamic> json) {
    return Examination(
      id: json['id'],
      bloodGlucoseRandom: json['bloodGlucoseRandom'],
      bloodGlucoseFasting: json['bloodGlucoseFasting'],
      hba1c: json['hba1c'],
      hemoglobin: json['hemoglobin'],
      bloodGlucosePostprandial: json['bloodGlucosePostprandial'],
      bloodPressure: json['bloodPressure'],
      dateTime: DateTime.parse(json['dateTime']),
      notes: json['notes'],
    );
  }

  // Konversi ke map/json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bloodGlucoseRandom': bloodGlucoseRandom,
      'bloodGlucoseFasting': bloodGlucoseFasting,
      'hba1c': hba1c,
      'hemoglobin': hemoglobin,
      'bloodGlucosePostprandial': bloodGlucosePostprandial,
      'bloodPressure': bloodPressure,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes,
    };
  }
}