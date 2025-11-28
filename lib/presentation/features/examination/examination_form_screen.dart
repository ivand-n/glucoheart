import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/themes/app_theme.dart';
import '../../../domain/entities/examination.dart';
import 'widgets/examination_form.dart';

class ExaminationFormScreen extends ConsumerWidget {
  final Examination? initial; // null => Tambah, !null => Edit
  const ExaminationFormScreen({super.key, this.initial});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editing = initial != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Edit Pemeriksaan' : 'Tambah Pemeriksaan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Isi data pemeriksaan dengan benar. Bidang tekanan darah wajib diisi.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ExaminationForm(
              initial: initial,
              onSuccess: (result) {
                Navigator.pop(context, result); // ⬅️ bawa data balik ke caller
              },
            ),
          ],
        ),
      ),
    );
  }
}
