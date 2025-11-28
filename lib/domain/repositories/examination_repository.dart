import '../entities/examination.dart';

abstract class ExaminationRepository {
  Future<List<Examination>> getAllExaminations();
  Future<Examination> getExaminationById(String id);
  Future<Examination> addExamination(Examination examination);
  Future<Examination> updateExamination(Examination examination); // ⬅️ tambah
  Future<bool> deleteExamination(String id);
}
