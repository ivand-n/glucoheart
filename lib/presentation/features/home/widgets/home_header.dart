import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glucoheart_flutter/utils/url_utils.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../core/utils/app_animations.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final String profilePicture;
  final VoidCallback onNotificationTap;
  final VoidCallback onSearchTap;
  final VoidCallback onProfileTap;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.onNotificationTap,
    required this.onSearchTap,
    required this.onProfileTap,
    required this.profilePicture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [AppShadows.medium],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: onProfileTap,
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppBorderRadius.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            boxShadow: [AppShadows.small],
                          ),
                          child: CircleAvatar(
                            radius: 42,
                            backgroundColor: AppColors.primaryLight,
                            backgroundImage: (profilePicture.isNotEmpty) ? NetworkImage(UrlUtils.full(profilePicture)) : null,
                            child: (profilePicture.isEmpty)
                                ? const Icon(Icons.person_rounded, color: AppColors.primaryColor, size: 40)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Animate(
                              effects: AppAnimations.textRevealEffect,
                              child: const Text(
                                'Selamat datang,',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Animate(
                              effects: [
                                ...AppAnimations.textRevealEffect,
                                ScaleEffect(
                                  begin: const Offset(0.9, 0.9),
                                  end: const Offset(1, 1),
                                  delay: 200.ms,
                                  duration: 400.ms,
                                  curve: Curves.easeOut,
                                ),
                              ],
                              child: Text(
                                userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Animate(
                effects: [
                  FadeEffect(
                    begin: 0,
                    end: 1,
                    duration: 600.ms,
                    delay: 300.ms,
                    curve: Curves.easeOut,
                  ),
                  SlideEffect(
                    begin: const Offset(0, 20),
                    end: const Offset(0, 0),
                    duration: 600.ms,
                    delay: 300.ms,
                    curve: Curves.easeOut,
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: onSearchTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Cari informasi kesehatan...',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onTap,
    int? badge,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            onPressed: onTap,
            splashRadius: 24,
          ),
        ),
        if (badge != null && badge > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                badge.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}