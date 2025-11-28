import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/examination.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../data/repositories/examination_repository_impl.dart';
import 'auth_provider.dart';

// ApiClient diikat ke provider agar lifecycle-nya jelas
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// Repository BUKAN singleton
final examinationRepositoryProvider = Provider<ExaminationRepositoryImpl>((ref) {
  final client = ref.watch(apiClientProvider);
  return ExaminationRepositoryImpl(client);
});

// Future list simple (ikut auth; autoDispose)
final examinationsProvider = FutureProvider.autoDispose<List<Examination>>((ref) async {
  // kalau user berubah/null, provider ini akan re-build
  final userId = ref.watch(authProvider.select((s) => s.user?.id));
  if (userId == null) return [];
  final repo = ref.watch(examinationRepositoryProvider);
  return repo.getAllExaminations();
});

class ExaminationNotifier extends StateNotifier<AsyncValue<List<Examination>>> {
  final ExaminationRepositoryImpl _repository;
  ExaminationNotifier(this._repository) : super(const AsyncLoading()) {
    loadExaminations();
  }

  Future<void> loadExaminations() async {
    state = const AsyncLoading();
    try {
      final data = await _repository.getAllExaminations();
      state = AsyncData(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<Examination> addExamination(Examination e) async {
    try {
      final created = await _repository.addExamination(e);
      final cur = state.value ?? <Examination>[];
      state = AsyncData([created, ...cur]);
      return created;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<Examination> updateExamination(Examination e) async {
    try {
      final updated = await _repository.updateExamination(e);
      final list = (state.value ?? <Examination>[])
          .map((x) => x.id == updated.id ? updated : x)
          .toList();
      state = AsyncData(list);
      return updated;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> deleteExamination(String id) async {
    try {
      await _repository.deleteExamination(id);
      final list = (state.value ?? <Examination>[]).where((x) => x.id != id).toList();
      state = AsyncData(list);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

// Provider StateNotifier autoDispose & ikut auth (userId) supaya reset saat login/logout
final examinationNotifierProvider =
StateNotifierProvider.autoDispose<ExaminationNotifier, AsyncValue<List<Examination>>>(
      (ref) {
    // tambahkan dependency ke auth; jika user berganti, provider di-recreate
    ref.watch(authProvider.select((s) => s.user?.id));
    final repo = ref.watch(examinationRepositoryProvider);
    return ExaminationNotifier(repo);
  },
);
