import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppAnimations {
  // Animasi untuk kartu fitur
  static List<Effect<dynamic>> get cardHoverEffects => [
    ScaleEffect(
      begin: const Offset(1, 1),
      end: const Offset(1.03, 1.03),
      duration: 250.ms,
      curve: Curves.easeOutQuad,
    ),
    ElevationEffect(
      begin: 2,
      end: 6,
      duration: 250.ms,
      curve: Curves.easeOutQuad,
    ),
  ];

  // Animasi untuk transisi halaman
  static Widget pageTransition({
    required Widget child,
    required AnimationController controller,
  }) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
        ),
        child: child,
      ),
    );
  }

  // Animasi untuk loading
  static List<Effect<dynamic>> get shimmerEffect => [
    ShimmerEffect(
      duration: 1500.ms,
      color: Colors.white.withOpacity(0.5),
      size: 1.0,
    ),
  ];

  // Animasi untuk teks
  static List<Effect<dynamic>> get textRevealEffect => [
    FadeEffect(
      begin: 0,
      end: 1,
      duration: 500.ms,
      curve: Curves.easeOut,
    ),
    SlideEffect(
      begin: const Offset(0, 20),
      end: const Offset(0, 0),
      duration: 500.ms,
      curve: Curves.easeOut,
    ),
  ];
}