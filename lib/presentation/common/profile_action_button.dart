import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/themes/app_theme.dart';

enum ProfileActionType { primary, secondary, danger }

class ProfileActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final ProfileActionType type;

  const ProfileActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.type = ProfileActionType.primary,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Color textColor;
    final Color iconColor;

    switch (type) {
      case ProfileActionType.primary:
        backgroundColor = AppColors.primaryColor;
        textColor = Colors.white;
        iconColor = Colors.white;
        break;
      case ProfileActionType.secondary:
        backgroundColor = AppColors.secondaryLight;
        textColor = AppColors.secondaryColor;
        iconColor = AppColors.secondaryColor;
        break;
      case ProfileActionType.danger:
        backgroundColor = AppColors.errorLight;
        textColor = AppColors.error;
        iconColor = AppColors.error;
        break;
    }

    return Animate(
      effects: [
        FadeEffect(
          duration: 400.ms,
          delay: 300.ms,
        ),
        SlideEffect(
          begin: const Offset(0, 20),
          end: const Offset(0, 0),
          duration: 400.ms,
          delay: 300.ms,
          curve: Curves.easeOutCubic,
        ),
      ],
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppBorderRadius.medium,
          child: Ink(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: AppBorderRadius.medium,
              boxShadow: [AppShadows.small],
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: iconColor.withOpacity(0.7),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}