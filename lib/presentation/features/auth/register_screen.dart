import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/routes/app_router.dart';
import '../../../config/themes/app_theme.dart';
import '../../common/app_button.dart';
import '../../common/app_text_field.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Email tidak valid';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != _passwordController.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      ref.read(authProvider.notifier).register(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Navigate to home if authenticated
    if (authState.status == AuthStatus.authenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(AppRouter.home);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Error message
                  if (authState.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        authState.errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Form fields
                  AppTextField(
                    label: 'Nama Depan',
                    hint: 'Masukkan nama depan Anda',
                    controller: _firstNameController,
                    validator: _nameValidator,
                    prefixIcon: const Icon(Icons.person_outline),
                    enabled: !authState.isLoading,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Nama Belakang',
                    hint: 'Masukkan nama belakang Anda',
                    controller: _lastNameController,
                    validator: _nameValidator,
                    prefixIcon: const Icon(Icons.person_outline),
                    enabled: !authState.isLoading,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Email',
                    hint: 'Masukkan email Anda',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _emailValidator,
                    prefixIcon: const Icon(Icons.email_outlined),
                    enabled: !authState.isLoading,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Password',
                    hint: 'Minimal 8 karakter',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: _passwordValidator,
                    prefixIcon: const Icon(Icons.lock_outline),
                    enabled: !authState.isLoading,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Konfirmasi Password',
                    hint: 'Masukkan password yang sama',
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    validator: _confirmPasswordValidator,
                    prefixIcon: const Icon(Icons.lock_outline),
                    enabled: !authState.isLoading,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Register button
                  AppButton(
                    text: 'Daftar',
                    onPressed: authState.isLoading ? () {} : _register,
                    isLoading: authState.isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah punya akun? ',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: authState.isLoading
                            ? () {}
                            : () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
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