import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/themes/app_theme.dart';

class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isPrivate;
  final bool obscureText;

  const ProfileInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isPrivate = false,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(
          duration: 400.ms,
          delay: 200.ms,
        ),
        SlideEffect(
          begin: const Offset(0, 20),
          end: const Offset(0, 0),
          duration: 400.ms,
          delay: 200.ms,
          curve: Curves.easeOutCubic,
        ),
      ],
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppBorderRadius.medium,
          boxShadow: [AppShadows.small],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: AppBorderRadius.small,
              ),
              child: Icon(
                icon,
                color: AppColors.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    obscureText ? '••••••••••' : value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (isPrivate)
              Icon(
                Icons.visibility_off,
                color: AppColors.textSecondary.withOpacity(0.5),
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}