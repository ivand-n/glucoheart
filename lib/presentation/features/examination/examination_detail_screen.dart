import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glucoheart_flutter/presentation/features/examination/examination_form_screen.dart';
import '../../../config/themes/app_theme.dart';
import '../../../domain/entities/examination.dart';
import '../../providers/examination_provider.dart';
import 'widgets/health_trend_chart.dart';

class ExaminationDetailScreen extends ConsumerStatefulWidget {
  final Examination examination;
  const ExaminationDetailScreen({super.key, required this.examination});

  @override
  ConsumerState<ExaminationDetailScreen> createState() => _ExaminationDetailScreenState();
}

class _ExaminationDetailScreenState extends ConsumerState<ExaminationDetailScreen> {
  late Examination _exam;

  @override
  void initState() {
    super.initState();
    _exam = widget.examination;
  }

  Future<void> _openEdit() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ExaminationFormScreen(initial: _exam)),
    );

    if (result is Examination) {
      // Terima object terbaru dari form -> update tampilan tanpa reload
      setState(() => _exam = result);
    } else {
      // Fallback: ambil data terbaru dari backend (jaga-jaga kalau form tidak mengembalikan result)
      try {
        final repo = ref.read(examinationRepositoryProvider);
        final fresh = await repo.getExaminationById(_exam.id);
        if (mounted) setState(() => _exam = fresh);
      } catch (_) {
        // abaikan error supaya UI tetap jalan
      }
    }

    // Refresh sumber data global untuk halaman lain (History/Chart)
    ref.read(examinationNotifierProvider.notifier).loadExaminations();
    ref.refresh(examinationsProvider);
  }

  Future<void> _confirmDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data'),
        content: const Text('Apakah Anda yakin ingin menghapus data pemeriksaan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('BATAL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('HAPUS'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await ref.read(examinationNotifierProvider.notifier).deleteExamination(_exam.id);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get all examinations for chart (dipertahankan seperti versi lama)
    final examinationsAsync = ref.watch(examinationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pemeriksaan'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: _openEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _confirmDelete,
            tooltip: 'Hapus Data',
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Data Pemeriksaan'),
                      const SizedBox(height: 16),

                      // Tanggal
                      _buildDataRow('Tanggal', _exam.formattedDate),
                      const Divider(height: 24),

                      // Blood Pressure
                      _buildDataRow(
                        'Tekanan Darah',
                        '${_exam.bloodPressure} mmHg',
                        showStatus: true,
                        status: _getStatusText(_exam.systolic, _exam.diastolic),
                        statusColor: _getStatusColor(_exam.systolic, _exam.diastolic),
                      ),

                      if (_exam.bloodGlucoseFasting != null) ...[
                        const Divider(height: 24),
                        _buildDataRow(
                          'Gula Darah Puasa (GDP)',
                          '${_exam.bloodGlucoseFasting} mg/dL',
                          showStatus: true,
                          status: _getGdpStatusText(_exam.bloodGlucoseFasting!),
                          statusColor: _getGdpStatusColor(_exam.bloodGlucoseFasting!),
                          normalRange: '70-100 mg/dL',
                        ),
                      ],

                      if (_exam.bloodGlucoseRandom != null) ...[
                        const Divider(height: 24),
                        _buildDataRow(
                          'Gula Darah Sewaktu (GDS)',
                          '${_exam.bloodGlucoseRandom} mg/dL',
                          showStatus: true,
                          status: _getGdsStatusText(_exam.bloodGlucoseRandom!),
                          statusColor: _getGdsStatusColor(_exam.bloodGlucoseRandom!),
                          normalRange: '70-140 mg/dL',
                        ),
                      ],

                      if (_exam.bloodGlucosePostprandial != null) ...[
                        const Divider(height: 24),
                        _buildDataRow(
                          'Gula Darah 2 Jam PP',
                          '${_exam.bloodGlucosePostprandial} mg/dL',
                          showStatus: true,
                          status: _getGd2jppStatusText(_exam.bloodGlucosePostprandial!),
                          statusColor: _getGd2jppStatusColor(_exam.bloodGlucosePostprandial!),
                          normalRange: '<140 mg/dL',
                        ),
                      ],

                      if (_exam.hba1c != null) ...[
                        const Divider(height: 24),
                        _buildDataRow(
                          'HbA1c',
                          '${_exam.hba1c}%',
                          showStatus: true,
                          status: _getHba1cStatusText(_exam.hba1c!),
                          statusColor: _getHba1cStatusColor(_exam.hba1c!),
                          normalRange: '4-5.6%',
                        ),
                      ],

                      if (_exam.hemoglobin != null) ...[
                        const Divider(height: 24),
                        _buildDataRow(
                          'Hemoglobin (Hb)',
                          '${_exam.hemoglobin} g/dL',
                          showStatus: false,
                          normalRange: 'Pria: 13.5-17.5 g/dL\nWanita: 12-15.5 g/dL',
                        ),
                      ],

                      if (_exam.notes != null && _exam.notes!.isNotEmpty) ...[
                        const Divider(height: 24),
                        const Text(
                          'Catatan:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.scaffoldBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _exam.notes!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Charts (dipertahankan)
            examinationsAsync.when(
              data: (examinations) {
                if (examinations.isNotEmpty) {
                  return HealthTrendChart(
                    examinations: examinations,
                    title: 'Tren Pemeriksaan',
                  );
                } else {
                  return const Center(
                    child: Text('Tidak ada data untuk ditampilkan'),
                  );
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text('Error: ${err.toString()}'),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'Pemeriksaan ${_exam.formattedDate}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _exam.dateTime.toString().substring(0, 10),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _exam.dateTime.toString().substring(11, 16),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Icon(
          Icons.medical_services_outlined,
          size: 18,
          color: AppColors.primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDataRow(
      String label,
      String value, {
        bool showStatus = false,
        String? status,
        Color? statusColor,
        String? normalRange,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (showStatus && status != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor!.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ],
        ),

        if (normalRange != null) ...[
          const SizedBox(height: 4),
          Text(
            'Nilai normal: $normalRange',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  // Status helpers
  String _getStatusText(int systolic, int diastolic) {
    if (systolic >= 140 || diastolic >= 90) {
      return 'Hipertensi';
    } else if (systolic >= 120 || diastolic >= 80) {
      return 'Prehipertensi';
    } else {
      return 'Normal';
    }
  }

  Color _getStatusColor(int systolic, int diastolic) {
    if (systolic >= 140 || diastolic >= 90) {
      return AppColors.error;
    } else if (systolic >= 120 || diastolic >= 80) {
      return AppColors.warning;
    } else {
      return AppColors.success;
    }
  }

  String _getGdpStatusText(double value) {
    if (value > 125) {
      return 'Tinggi';
    } else if (value >= 100) {
      return 'Prediabetes';
    } else {
      return 'Normal';
    }
  }

  Color _getGdpStatusColor(double value) {
    if (value > 125) {
      return AppColors.error;
    } else if (value >= 100) {
      return AppColors.warning;
    } else {
      return AppColors.success;
    }
  }

  String _getGdsStatusText(double value) {
    if (value > 200) {
      return 'Tinggi';
    } else if (value >= 140) {
      return 'Waspada';
    } else {
      return 'Normal';
    }
  }

  Color _getGdsStatusColor(double value) {
    if (value > 200) {
      return AppColors.error;
    } else if (value >= 140) {
      return AppColors.warning;
    } else {
      return AppColors.success;
    }
  }

  String _getGd2jppStatusText(double value) {
    if (value > 200) {
      return 'Tinggi';
    } else if (value >= 140) {
      return 'Waspada';
    } else {
      return 'Normal';
    }
  }

  Color _getGd2jppStatusColor(double value) {
    if (value > 200) {
      return AppColors.error;
    } else if (value >= 140) {
      return AppColors.warning;
    } else {
      return AppColors.success;
    }
  }

  String _getHba1cStatusText(double value) {
    if (value > 6.4) {
      return 'Diabetes';
    } else if (value >= 5.7) {
      return 'Prediabetes';
    } else {
      return 'Normal';
    }
  }

  Color _getHba1cStatusColor(double value) {
    if (value > 6.4) {
      return AppColors.error;
    } else if (value >= 5.7) {
      return AppColors.warning;
    } else {
      return AppColors.success;
    }
  }
}
