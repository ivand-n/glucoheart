import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/themes/app_theme.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final String initials;
  final bool showEditButton;
  final VoidCallback? onEditTap;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.size = 100,
    required this.initials,
    this.showEditButton = false,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Animate(
          effects: [
            ScaleEffect(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.easeOutBack,
            ),
            FadeEffect(
              begin: 0,
              end: 1,
              duration: 400.ms,
            ),
          ],
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
              gradient: AppGradients.primaryGradient,
              boxShadow: [AppShadows.medium],
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: imageUrl != null && imageUrl!.isNotEmpty ? ClipRRect(
              borderRadius: BorderRadius.circular(size / 2),
              child: Image.network(
                imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildInitials(),
              ),
            )
                : _buildInitials(),
          ),
        ),
        if (showEditButton)
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onEditTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [AppShadows.small],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
