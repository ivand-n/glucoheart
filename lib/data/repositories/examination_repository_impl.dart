import '../../domain/entities/examination.dart';
import '../../domain/repositories/examination_repository.dart';
import '../datasources/remote/api_client.dart';
import '../datasources/remote/examination_api.dart';

class ExaminationRepositoryImpl implements ExaminationRepository {
  final ExaminationApi _api;
  ExaminationRepositoryImpl(ApiClient client) : _api = ExaminationApi(client);

  Examination _fromApi(Map<String, dynamic> m) {
    DateTime _parseDate() {
      final s = (m['dateTime'] ?? m['createdAt'] ?? m['updatedAt'])?.toString();
      return s != null ? (DateTime.tryParse(s) ?? DateTime.now()) : DateTime.now();
    }

    double? _d(String k) {
      final v = m[k];
      return v == null ? null : (v is num ? v.toDouble() : double.tryParse(v.toString()));
    }

    return Examination(
      id: (m['id'] ?? m['healthMetricId'] ?? '').toString(),
      bloodGlucoseRandom: _d('bloodGlucoseRandom'),
      bloodGlucoseFasting: _d('bloodGlucoseFasting'),
      hba1c: _d('hba1c'),
      hemoglobin: _d('hemoglobin'),
      bloodGlucosePostprandial: _d('bloodGlucosePostprandial'),
      bloodPressure: (m['bloodPressure'] ?? '').toString(),
      dateTime: _parseDate(),
      notes: m['notes']?.toString(),
    );
  }

  Map<String, dynamic> _toCreate(Examination e) => {
    if (e.bloodGlucoseRandom != null) 'bloodGlucoseRandom': e.bloodGlucoseRandom,
    if (e.bloodGlucoseFasting != null) 'bloodGlucoseFasting': e.bloodGlucoseFasting,
    if (e.hba1c != null) 'hba1c': e.hba1c,
    if (e.hemoglobin != null) 'hemoglobin': e.hemoglobin,
    if (e.bloodGlucosePostprandial != null) 'bloodGlucosePostprandial': e.bloodGlucosePostprandial,
    'bloodPressure': e.bloodPressure,
    'dateTime': e.dateTime.toIso8601String(),
    if (e.notes != null && e.notes!.isNotEmpty) 'notes': e.notes,
  };

  Map<String, dynamic> _toUpdate(Examination e) => {
    if (e.bloodGlucoseRandom != null) 'bloodGlucoseRandom': e.bloodGlucoseRandom,
    if (e.bloodGlucoseFasting != null) 'bloodGlucoseFasting': e.bloodGlucoseFasting,
    if (e.hba1c != null) 'hba1c': e.hba1c,
    if (e.hemoglobin != null) 'hemoglobin': e.hemoglobin,
    if (e.bloodGlucosePostprandial != null) 'bloodGlucosePostprandial': e.bloodGlucosePostprandial,
    if (e.bloodPressure.isNotEmpty) 'bloodPressure': e.bloodPressure,
    'dateTime': e.dateTime.toIso8601String(),
    'notes': e.notes, // null => hapus catatan
  };

  @override
  Future<List<Examination>> getAllExaminations() async {
    final list = await _api.listMine();
    return list.map(_fromApi).toList();
  }

  @override
  Future<Examination> getExaminationById(String id) async {
    final m = await _api.getById(id);
    return _fromApi(m);
  }

  @override
  Future<Examination> addExamination(Examination examination) async {
    final created = await _api.create(_toCreate(examination));
    return _fromApi(created);
  }

  @override
  Future<Examination> updateExamination(Examination examination) async {
    final updated = await _api.update(examination.id, _toUpdate(examination));
    return _fromApi(updated);
  }

  @override
  Future<bool> deleteExamination(String id) async {
    await _api.delete(id);
    return true;
  }
}
