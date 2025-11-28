import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'package:glucoheart_flutter/presentation/features/discussion/discussion_list_screen.dart';
import 'package:glucoheart_flutter/presentation/features/nurse/nurse_home_screen.dart';
import 'package:glucoheart_flutter/presentation/features/splash/splash_screen.dart';
import 'package:glucoheart_flutter/presentation/features/auth/login_screen.dart';
import 'package:glucoheart_flutter/presentation/features/auth/register_screen.dart';
import 'package:glucoheart_flutter/presentation/features/home/home_screen.dart';
import 'package:glucoheart_flutter/presentation/providers/auth_provider.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String discussionRooms = '/discussion/rooms';
  static const String nurseHome = '/nurse/home';

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final _log = Logger();

  // Pastikan tiap route diberi 'settings' agar nama route terdeteksi
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(settings: settings, builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(settings: settings, builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(settings: settings, builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(settings: settings, builder: (_) => const HomeScreen());
      case discussionRooms:
        return MaterialPageRoute(settings: settings, builder: (_) => const DiscussionListScreen());
      case nurseHome:
        return MaterialPageRoute(settings: settings, builder: (_) => const NurseHomeScreen());
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  static Widget authWrapper(Widget child) => _AuthGate(child: child);
}

/// Gate idempoten: selalu cek currentRoute vs desiredTarget, lalu force navigate jika beda.
class _AuthGate extends ConsumerWidget {
  final Widget child;
  const _AuthGate({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authProvider, (prev, next) {
      final nav = AppRouter.navigatorKey.currentState;
      if (nav == null) return;

      // Tentukan target berdasarkan status & role
      String? desiredTarget;
      if (next.status == AuthStatus.initial) {
        desiredTarget = null; // tetap di route sekarang (umumnya Splash)
      } else if (next.status == AuthStatus.unauthenticated) {
        desiredTarget = AppRouter.login;
      } else if (next.status == AuthStatus.authenticated) {
        final role = (next.user?.role ?? '').trim().toUpperCase();
        if (role.isEmpty) {
          // role belum siap → jangan redirect dulu
          AppRouter._log.d('auth: authenticated but role not ready yet — wait');
          return;
        }
        desiredTarget = (role == 'NURSE') ? AppRouter.nurseHome : AppRouter.home;
      }

      // Ambil nama route saat ini
      final currentContext = AppRouter.navigatorKey.currentContext;
      final currentRouteName = currentContext != null
          ? ModalRoute.of(currentContext)?.settings.name
          : null;

      AppRouter._log.i('auth: status=${next.status}, role=${next.user?.role}, '
          'current=$currentRouteName, desired=$desiredTarget');

      // Jika tidak ada target (initial), biarkan.
      if (desiredTarget == null) return;

      // Jika sudah di target, tidak perlu navigate.
      if (currentRouteName == desiredTarget) {
        AppRouter._log.d('auth: already at $desiredTarget — skip');
        return;
      }

      // Force navigate ke target (idempoten karena setelah pindah current==desired)
      nav.pushNamedAndRemoveUntil(desiredTarget, (route) => false);
    });

    return child; // jangan pernah ganti Navigator
  }
}
