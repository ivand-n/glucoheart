// lib/presentation/features/profile/edit_profile_screen.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glucoheart_flutter/config/routes/app_router.dart';
import 'package:glucoheart_flutter/utils/url_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:glucoheart_flutter/presentation/providers/auth_provider.dart';
import 'package:glucoheart_flutter/presentation/providers/users_provider.dart';
import '../../../config/themes/app_theme.dart';
import '../../../data/datasources/remote/api_client.dart';
import '../../../domain/entities/user.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _profileUrlCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null) {
      _firstNameCtrl.text = user.firstName ?? '';
      _lastNameCtrl.text = user.lastName ?? '';
      _profileUrlCtrl.text = user.profilePicture ?? '';
      _emailCtrl.text = user.email;
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _profileUrlCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(editProfileProvider.notifier).save(
      firstName: _firstNameCtrl.text.trim().isEmpty ? null : _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim().isEmpty ? null : _lastNameCtrl.text.trim(),
      profilePicture: _profileUrlCtrl.text.trim().isEmpty ? null : _profileUrlCtrl.text.trim(),
      // email: _emailCtrl.text.trim(),
    );
    if (!mounted) return;
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    } else {
      // tidak ada halaman di belakang—hindari stack kosong
      AppRouter.navigatorKey.currentState
          ?.pushReplacementNamed(AppRouter.home);
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final picker = ImagePicker();
      final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 92);
      if (x == null) return;

      final file = File(x.path);
      final size = await file.length();
      // backend limit 3MB
      if (size > 3 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maksimal ukuran 3MB'), behavior: SnackBarBehavior.floating),
        );
        return;
      }

      setState(() => _uploadingAvatar = true);

      final dio = ApiClient().dio; // token & baseUrl di-handle ApiClient
      final form = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          file.path,
          filename: p.basename(file.path),
        ),
      });

      final res = await dio.post('/users/me/avatar', data: form);
      final String? newUrl = res.data?['profilePicture'];

      if (newUrl == null || newUrl.isEmpty) {
        throw Exception('Respons server tidak berisi URL avatar');
      }

      // Update auth state + field URL biar preview ikut berubah
      final current = ref.read(authProvider).user!;
      final updated = User(
        id: current.id,
        email: current.email,
        firstName: current.firstName,
        lastName: current.lastName,
        profilePicture: newUrl,
        role: current.role,
        createdAt: current.createdAt,
      );
      ref.read(authProvider.notifier).setUser(updated);
      _profileUrlCtrl.text = newUrl;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil diunggah'), behavior: SnackBarBehavior.floating),
      );
      setState(() {}); // refresh preview
    } on DioException catch (e) {
      final msg = e.response?.data is Map && (e.response!.data['message'] != null)
          ? e.response!.data['message'].toString()
          : (e.message ?? 'Gagal mengunggah avatar');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _deleteAvatar() async {
    try {
      setState(() => _uploadingAvatar = true);
      final dio = ApiClient().dio;
      await dio.delete('/users/me/avatar');

      final current = ref.read(authProvider).user!;
      final updated = User(
        id: current.id,
        email: current.email,
        firstName: current.firstName,
        lastName: current.lastName,
        profilePicture: null,
        role: current.role,
        createdAt: current.createdAt,
      );
      ref.read(authProvider.notifier).setUser(updated);
      _profileUrlCtrl.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil dihapus'), behavior: SnackBarBehavior.floating),
      );
      setState(() {});
    } on DioException catch (e) {
      final msg = e.response?.data is Map && (e.response!.data['message'] != null)
          ? e.response!.data['message'].toString()
          : (e.message ?? 'Gagal menghapus avatar');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(editProfileProvider).isSaving;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.medium),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _AvatarPreview(
                    urlCtrl: _profileUrlCtrl,
                    uploading: _uploadingAvatar,
                    onChangePhoto: _pickAndUploadAvatar,
                    onDeletePhoto: _deleteAvatar,
                  ),
                  const SizedBox(height: 16),
                  // Field URL tetap ada agar kompatibel & fleksibel
                  TextFormField(
                    controller: _profileUrlCtrl,
                    decoration: const InputDecoration(
                      labelText: 'URL Foto Profil',
                      hintText: 'https://contoh.com/foto.jpg',
                    ),
                    keyboardType: TextInputType.url,
                    // Jika diubah manual, preview ikut update (ValueListenable di _AvatarPreview)
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _firstNameCtrl,
                    decoration: const InputDecoration(labelText: 'Nama Depan'),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) {
                      if (v != null && v.length > 100) return 'Kepanjangan';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _lastNameCtrl,
                    decoration: const InputDecoration(labelText: 'Nama Belakang'),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) {
                      if (v != null && v.length > 100) return 'Kepanjangan';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    readOnly: true,
                    validator: (v) => (v == null || v.isEmpty) ? 'Email tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: (saving)
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.save_rounded),
                      label: Text(saving ? 'Menyimpan...' : 'Simpan'),
                      onPressed: saving ? null : _save,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  final TextEditingController urlCtrl;
  final bool uploading;
  final VoidCallback onChangePhoto;
  final VoidCallback onDeletePhoto;

  const _AvatarPreview({
    required this.urlCtrl,
    required this.uploading,
    required this.onChangePhoto,
    required this.onDeletePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: urlCtrl,
          builder: (_, value, __) {
            final url = value.text.trim();
            return Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: (url.isNotEmpty) ? NetworkImage(UrlUtils.full(url)) : null,
                  child: (url.isEmpty)
                      ? const Icon(Icons.person_rounded, color: AppColors.primaryColor, size: 40)
                      : null,
                ),
                if (uploading)
                  const SizedBox(
                    width: 84,
                    height: 84,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: uploading ? null : onChangePhoto,
              icon: const Icon(Icons.photo_library_rounded),
              label: const Text('Ganti Foto'),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: uploading ? null : onDeletePhoto,
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Hapus'),
            ),
          ],
        )
      ],
    );
  }
}
