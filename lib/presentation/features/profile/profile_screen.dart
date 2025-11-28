import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glucoheart_flutter/presentation/features/profile/change_password_screen.dart';
import 'package:glucoheart_flutter/presentation/features/profile/edit_profile_screen.dart';
import 'package:glucoheart_flutter/presentation/providers/examination_provider.dart';
import 'package:glucoheart_flutter/utils/url_utils.dart';
import '../../../config/routes/app_router.dart';
import '../../../config/themes/app_theme.dart';
import '../../../domain/entities/user.dart';
import '../../common/confirm_dialog.dart';
import '../../common/profile_action_button.dart';
import '../../common/profile_info_row.dart';
import '../../common/user_avatar.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : _buildProfileContent(context, ref, user),
    );
  }

  Widget _buildProfileContent(BuildContext context, WidgetRef ref, User user) {
    final size = MediaQuery.of(context).size;

    // Get user initials
    final parts = (user.name).trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    String initials;
    if (parts.isEmpty) {
      initials = 'U';
    } else if (parts.length == 1) {
      initials = parts.first[0].toUpperCase();
    } else {
      initials = (parts[0][0] + parts[1][0]).toUpperCase();
    }
    final nameInitials = initials;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with gradient background
          _buildProfileHeader(context, user, nameInitials),

          // Profile information and actions
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personal information section
                Animate(
                  effects: [
                    FadeEffect(
                      duration: 300.ms,
                      delay: 100.ms,
                    ),
                    SlideEffect(
                      begin: const Offset(0, 20),
                      end: const Offset(0, 0),
                      duration: 400.ms,
                      delay: 100.ms,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_rounded,
                          size: 20,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Informasi Personal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Info rows
                ProfileInfoRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Nama Lengkap',
                  value: user.name,
                ),
                ProfileInfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: user.email,
                ),

                const SizedBox(height: 24),

                // Account actions section
                Animate(
                  effects: [
                    FadeEffect(
                      duration: 300.ms,
                      delay: 150.ms,
                    ),
                    SlideEffect(
                      begin: const Offset(0, 20),
                      end: const Offset(0, 0),
                      duration: 400.ms,
                      delay: 150.ms,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.settings_rounded,
                          size: 20,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pengaturan Akun',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ProfileActionButton(
                  label: 'Edit Profil',
                  icon: Icons.edit_rounded,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                  },
                  type: ProfileActionType.primary,
                ),
                const SizedBox(height: 12),
                ProfileActionButton(
                  label: 'Ganti Password',
                  icon: Icons.lock_reset_rounded,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                    );
                  },
                  type: ProfileActionType.secondary, // tampil beda dari danger & primary
                ),
                const SizedBox(height: 12),
                ProfileActionButton(
                  label: 'Keluar',
                  icon: Icons.logout_rounded,
                  onTap: () => _handleLogout(context, ref),
                  type: ProfileActionType.danger,
                ),
                const SizedBox(height: 24),
                // App version
                Center(
                  child: Text(
                    'GlucoHeart v1.0.0',
                    style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, User user, String nameInitials) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      child: Column(
        children: [
          // User Avatar
          UserAvatar(
            imageUrl: UrlUtils.full(user.profilePicture),
            initials: nameInitials,
            size: 120,
            showEditButton: true,
            onEditTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
          const SizedBox(height: 16),

          // User Name
          Animate(
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
            child: Text(
              user.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 8),

          // User Email
          Animate(
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
            child: Text(
              user.email,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          // Membership Status
          Animate(
            effects: [
              FadeEffect(
                duration: 400.ms,
                delay: 400.ms,
              ),
              SlideEffect(
                begin: const Offset(0, 20),
                end: const Offset(0, 0),
                duration: 400.ms,
                delay: 400.ms,
                curve: Curves.easeOutCubic,
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_rounded,
                    size: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Pengguna Aktif',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final result = await ConfirmDialog.show(
      context: context,
      title: 'Keluar dari Aplikasi',
      message: 'Apakah Anda yakin ingin keluar dari GlucoHeart?',
      cancelText: 'Batal',
      confirmText: 'Keluar',
      icon: Icons.logout_rounded,
      isDanger: true,
    );

    if (result == true) {
      await ref.read(authProvider.notifier).logout();

      ref.invalidate(examinationNotifierProvider);
      ref.invalidate(examinationsProvider);

      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.login,
              (route) => false,
        );
      }
    }
  }

  int min(int a, int b) => a < b ? a : b;
}