import 'package:flutter/material.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../domain/entities/examination.dart';

class ExaminationHistoryCard extends StatelessWidget {
  final Examination examination;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ExaminationHistoryCard({
    super.key,
    required this.examination,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    examination.formattedDate,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      onPressed: onDelete,
                      splashRadius: 20,
                      tooltip: 'Hapus',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.favorite,
                'Tekanan Darah',
                '${examination.bloodPressure} mmHg',
                _getBloodPressureStatus(examination.systolic, examination.diastolic),
              ),
              if (examination.bloodGlucoseFasting != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.water_drop_outlined,
                  'Gula Darah Puasa',
                  '${examination.bloodGlucoseFasting} mg/dL',
                  _getGdpStatus(examination.bloodGlucoseFasting!),
                ),
              ],
              if (examination.bloodGlucoseRandom != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.water_drop_outlined,
                  'Gula Darah Sewaktu',
                  '${examination.bloodGlucoseRandom} mg/dL',
                  _getGdsStatus(examination.bloodGlucoseRandom!),
                ),
              ],
              if (examination.hba1c != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.percent,
                  'HbA1c',
                  '${examination.hba1c}%',
                  _getHba1cStatus(examination.hba1c!),
                ),
              ],
              if (examination.notes != null && examination.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.note_alt_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          examination.notes!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      IconData icon, String label, String value, _HealthStatus status) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        _buildStatusChip(status),
      ],
    );
  }

  Widget _buildStatusChip(_HealthStatus status) {
    Color color;
    String text;

    switch (status) {
      case _HealthStatus.normal:
        color = AppColors.success;
        text = 'Normal';
        break;
      case _HealthStatus.warning:
        color = AppColors.warning;
        text = 'Waspada';
        break;
      case _HealthStatus.danger:
        color = AppColors.error;
        text = 'Perhatian';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  _HealthStatus _getBloodPressureStatus(int systolic, int diastolic) {
    if (systolic >= 140 || diastolic >= 90) {
      return _HealthStatus.danger;
    } else if (systolic >= 120 || diastolic >= 80) {
      return _HealthStatus.warning;
    } else {
      return _HealthStatus.normal;
    }
  }

  _HealthStatus _getGdpStatus(double value) {
    if (value > 125) {
      return _HealthStatus.danger;
    } else if (value >= 100) {
      return _HealthStatus.warning;
    } else {
      return _HealthStatus.normal;
    }
  }

  _HealthStatus _getGdsStatus(double value) {
    if (value > 200) {
      return _HealthStatus.danger;
    } else if (value >= 140) {
      return _HealthStatus.warning;
    } else {
      return _HealthStatus.normal;
    }
  }

  _HealthStatus _getHba1cStatus(double value) {
    if (value > 6.4) {
      return _HealthStatus.danger;
    } else if (value >= 5.7) {
      return _HealthStatus.warning;
    } else {
      return _HealthStatus.normal;
    }
  }
}

enum _HealthStatus {
  normal,
  warning,
  danger,
}