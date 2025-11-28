import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../config/themes/app_theme.dart';

class HealthMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final bool isNormal;
  final IconData icon;
  final String? trend;
  final double? trendValue;

  const HealthMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.isNormal,
    required this.icon,
    this.trend,
    this.trendValue,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = isNormal ? AppColors.success : AppColors.error;
    final Color backgroundColor = isNormal ? AppColors.successLight : AppColors.errorLight;

    return Animate(
      effects: [
        FadeEffect(
          curve: Curves.easeOut,
          duration: 400.ms,
          delay: 200.ms,
        ),
        ScaleEffect(
          curve: Curves.easeOut,
          duration: 400.ms,
          delay: 200.ms,
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
        ),
      ],
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppBorderRadius.medium,
          boxShadow: [AppShadows.small],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppBorderRadius.circle,
                  ),
                  child: Icon(
                    icon,
                    color: primaryColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: 12,
                      color: primaryColor.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isNormal ? AppColors.success.withOpacity(0.2) : AppColors.error.withOpacity(0.2),
                    borderRadius: AppBorderRadius.small,
                  ),
                  child: Text(
                    isNormal ? 'Normal' : 'Perhatian!',
                    style: TextStyle(
                      fontSize: 11,
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (trend != null) _buildTrendIndicator(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendIndicator() {
    if (trend == null || trendValue == null) return const SizedBox();

    final bool isUp = trend == 'up';
    final Color trendColor = isUp ? AppColors.error : AppColors.success;
    final IconData trendIcon = isUp ? Icons.arrow_upward : Icons.arrow_downward;

    return Row(
      children: [
        Icon(
          trendIcon,
          color: trendColor,
          size: 14,
        ),
        const SizedBox(width: 2),
        Text(
          '${trendValue!.abs().toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 12,
            color: trendColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}