import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/themes/app_theme.dart';
import '../../../domain/entities/examination.dart';
import '../../providers/examination_provider.dart';
import 'examination_detail_screen.dart';
import 'examination_form_screen.dart';
import 'widgets/examination_history_card.dart';
import 'widgets/health_trend_chart.dart';

class ExaminationHistoryScreen extends ConsumerStatefulWidget {
  const ExaminationHistoryScreen({super.key});

  @override
  ConsumerState<ExaminationHistoryScreen> createState() => _ExaminationHistoryScreenState();
}

class _ExaminationHistoryScreenState extends ConsumerState<ExaminationHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final examinationsAsync = ref.watch(examinationNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pemeriksaan'),
        actions: [
          IconButton(
            onPressed: () => ref.read(examinationNotifierProvider.notifier).loadExaminations(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const ExaminationFormScreen()));
          if (mounted) ref.read(examinationNotifierProvider.notifier).loadExaminations();
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: examinationsAsync.when(
        data: (examinations) {
          if (examinations.isEmpty) return _empty();
          return _list(examinations);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _err(e.toString()),
      ),
    );
  }

  Widget _empty() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.medical_services_outlined, size: 64, color: AppColors.primaryColor),
          SizedBox(height: 16),
          Text('Belum Ada Data Pemeriksaan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Mulai catat data kesehatanmu untuk memantau tren.', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    ),
  );

  Widget _err(String m) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
        const SizedBox(height: 16),
        Text('Error: $m', style: const TextStyle(color: AppColors.error), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => ref.read(examinationNotifierProvider.notifier).loadExaminations(),
          child: const Text('Coba Lagi'),
        ),
      ],
    ),
  );

  Widget _list(List<Examination> examinations) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (examinations.length > 1) ...[
            HealthTrendChart(examinations: examinations, title: 'Tren Kesehatan'),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
          ],
          const Text('Riwayat Pemeriksaan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          ...examinations.map((e) => ExaminationHistoryCard(
            examination: e,
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => ExaminationDetailScreen(examination: e)))
                  .then((_) => ref.read(examinationNotifierProvider.notifier).loadExaminations());
            },
            onDelete: () => _confirmDelete(e),
          )),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Examination e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Data'),
        content: const Text('Apakah Anda yakin ingin menghapus data pemeriksaan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('BATAL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('HAPUS'),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await ref.read(examinationNotifierProvider.notifier).deleteExamination(e.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Data terhapus'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ));
        }
      } catch (err) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Gagal menghapus: $err'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ));
        }
      }
    }
  }
}
