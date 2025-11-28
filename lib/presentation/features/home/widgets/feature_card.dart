import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../core/utils/app_animations.dart';

class FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? svgIconPath;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.svgIconPath,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(
          curve: Curves.easeOut,
          duration: 400.ms,
          delay: 100.ms,
        ),
        SlideEffect(
          curve: Curves.easeOut,
          duration: 400.ms,
          delay: 100.ms,
          begin: const Offset(0, 30),
          end: const Offset(0, 0),
        ),
      ],
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppBorderRadius.medium,
          boxShadow: [AppShadows.small],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppBorderRadius.medium,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppBorderRadius.medium,
            child: Ink(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: AppBorderRadius.medium,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Custom icon with circular background
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: AppBorderRadius.circle,
                      ),
                      child: svgIconPath != null
                          ? SvgPicture.asset(
                        svgIconPath!,
                        height: 24,
                        width: 24,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      )
                          : Icon(
                        icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ).animate(
            onPlay: (controller) => controller.repeat(reverse: true),
            autoPlay: false,
          ),
        ),
      ),
    );
  }
}