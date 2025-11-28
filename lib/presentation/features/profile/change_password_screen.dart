import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/themes/app_theme.dart';
import '../../providers/users_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(changePasswordProvider.notifier).submit(
      currentPassword: _currentCtrl.text,
      newPassword: _newCtrl.text,
    );
    if (!mounted) return;
    final state = ref.read(changePasswordProvider);
    if (ok && state.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil diganti'), behavior: SnackBarBehavior.floating),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error ?? 'Gagal mengganti password'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitting = ref.watch(changePasswordProvider).isSubmitting;

    return Scaffold(
      appBar: AppBar(title: const Text('Ganti Password')),
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
                  // current
                  TextFormField(
                    controller: _currentCtrl,
                    decoration: InputDecoration(
                      labelText: 'Password Saat Ini',
                      suffixIcon: IconButton(
                        icon: Icon(_obscureCurrent ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                      ),
                    ),
                    obscureText: _obscureCurrent,
                    validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),

                  // new
                  TextFormField(
                    controller: _newCtrl,
                    decoration: InputDecoration(
                      labelText: 'Password Baru',
                      helperText: 'Min. 8 karakter, kombinasi huruf besar/kecil, angka & simbol',
                      suffixIcon: IconButton(
                        icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureNew = !_obscureNew),
                      ),
                    ),
                    obscureText: _obscureNew,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Wajib diisi';
                      if (v.length < 8) return 'Minimal 8 karakter';
                      final hasLower = RegExp(r'[a-z]').hasMatch(v);
                      final hasUpper = RegExp(r'[A-Z]').hasMatch(v);
                      final hasDigit = RegExp(r'\d').hasMatch(v);
                      final hasSymbol = RegExp(r'[^A-Za-z0-9]').hasMatch(v);
                      if (!(hasLower && hasUpper && hasDigit && hasSymbol)) {
                        return 'Harus ada huruf kecil, huruf besar, angka, & simbol';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // confirm
                  TextFormField(
                    controller: _confirmCtrl,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password Baru',
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    obscureText: _obscureConfirm,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Wajib diisi';
                      if (v != _newCtrl.text) return 'Tidak sama dengan password baru';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: submitting
                          ? const SizedBox(
                          width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.lock_reset_rounded),
                      label: Text(submitting ? 'Memproses...' : 'Ganti Password'),
                      onPressed: submitting ? null : _submit,
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
