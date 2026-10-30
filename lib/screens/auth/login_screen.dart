import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/feedback_banner.dart';
import '../../widgets/custom_dialogs.dart';
import '../../state/app_state.dart';
import '../../data/api/api_exception.dart';
import '../shell/main_navigation_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _usernameError;
  String? _passwordError;
  String? _globalErrorBanner;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() {
      _usernameError = null;
      _passwordError = null;
      _globalErrorBanner = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty && password.isEmpty) {
      setState(() {
        _usernameError = 'Username wajib diisi';
        _passwordError = 'Password wajib diisi';
        _globalErrorBanner = 'Username dan password wajib diisi';
      });
      return;
    } else if (username.isEmpty) {
      setState(() {
        _usernameError = 'Username wajib diisi';
      });
      return;
    } else if (password.isEmpty) {
      setState(() {
        _passwordError = 'Password wajib diisi';
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AppState.instance.login(username: username, password: password);
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationShell()),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (e.statusCode == 403 || e.message.toLowerCase().contains('blokir')) {
            _triggerBlockedAccountModal();
          } else if (e.statusCode == 401) {
            _passwordController.clear();
            _globalErrorBanner = e.message;
          } else {
            _globalErrorBanner = e.message;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _globalErrorBanner = 'Terjadi kesalahan jaringan. Silakan coba lagi.';
        });
      }
    }
  }

  void _triggerBlockedAccountModal() {
    CustomDialogs.showBlockedAccountDialog(
      context,
      branchList: const [
        'Momnjo Dharmawangsa',
        'Momnjo Gading Serpong',
        'Momnjo Green Lake',
        'Momnjo Kelapa Gading',
      ],
      onContactAdmin: (branch) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Membuka WhatsApp Admin $branch...'),
            backgroundColor: AppColors.brand500,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              // Brand Logo / Header
              Text(
                'momnjo',
                style: AppTypography.display.copyWith(
                  color: AppColors.brand500,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Terapi Profesional untuk Kehidupan yang Lebih Baik',
                style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Illustration Card (Mom & therapist aesthetic)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF0F3), Color(0xFFFFFAFA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFE0E8)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF7DFE8),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.spa_rounded, color: AppColors.brand500, size: 44),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Merawat\nSetiap Langkah Menjadi Ibu ❤️',
                      textAlign: TextAlign.center,
                      style: AppTypography.h2.copyWith(
                        fontSize: 16,
                        color: AppColors.brand700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Title Card
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selamat Datang', style: AppTypography.h1),
                    const SizedBox(height: 4),
                    Text(
                      'Masuk ke akun terapis Anda',
                      style: AppTypography.support.copyWith(color: AppColors.inkMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Global Error Banner (401 / 422 / 500)
              if (_globalErrorBanner != null) ...[
                FeedbackBanner(
                  message: _globalErrorBanner!,
                  type: FeedbackBannerType.danger,
                  onDismiss: () => setState(() => _globalErrorBanner = null),
                ),
                const SizedBox(height: 14),
              ],

              // Form fields
              AppTextField(
                label: 'Username',
                hintText: 'Masukkan username',
                controller: _usernameController,
                prefixIcon: const Icon(Icons.person_outline, size: 20, color: AppColors.inkMuted),
                errorMessage: _usernameError,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Password',
                hintText: 'Masukkan kata sandi',
                controller: _passwordController,
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppColors.inkMuted),
                errorMessage: _passwordError,
              ),
              const SizedBox(height: 24),

              // Submit Button
              AppButton(
                text: 'Masuk',
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
