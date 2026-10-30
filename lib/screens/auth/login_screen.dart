import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/feedback_banner.dart';
import '../../widgets/custom_dialogs.dart';
import '../../state/app_state.dart';
import '../shell/main_navigation_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController(text: 'siti.therapis');
  final TextEditingController _passwordController = TextEditingController(text: 'password123');

  String? _usernameError;
  String? _passwordError;
  String? _globalErrorBanner;
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() {
      _usernameError = null;
      _passwordError = null;
      _globalErrorBanner = null;
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 400));

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Check empty validation (HTTP 422 simulation)
    if (username.isEmpty && password.isEmpty) {
      setState(() {
        _isLoading = false;
        _usernameError = 'Username wajib diisi';
        _passwordError = 'Password wajib diisi';
        _globalErrorBanner = 'Username dan password wajib diisi';
      });
      return;
    } else if (username.isEmpty) {
      setState(() {
        _isLoading = false;
        _usernameError = 'Username wajib diisi';
      });
      return;
    } else if (password.isEmpty) {
      setState(() {
        _isLoading = false;
        _passwordError = 'Password wajib diisi';
      });
      return;
    }

    // Check simulated credentials
    if (username == 'blocked') {
      setState(() => _isLoading = false);
      _triggerBlockedAccountModal();
      return;
    } else if (password == 'wrong') {
      setState(() {
        _isLoading = false;
        _passwordController.clear();
        _globalErrorBanner = 'Username atau password salah';
      });
      return;
    }

    setState(() => _isLoading = false);
    AppState.instance.login(username: username, password: password);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationShell()),
      );
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

              // Global Error Banner (401 / 422)
              if (_globalErrorBanner != null) ...[
                FeedbackBanner(
                  message: _globalErrorBanner!,
                  type: FeedbackBannerType.danger,
                  onDismiss: () => setState(() => _globalErrorBanner = null),
                ),
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
              const SizedBox(height: 20),

              // Quick State Presets for testing
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Simulator Status Respons Backend:',
                      style: AppTypography.captionBold.copyWith(color: AppColors.inkMuted),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        ActionChip(
                          label: const Text('Normal (200)', style: TextStyle(fontSize: 11)),
                          backgroundColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              _usernameController.text = 'siti.therapis';
                              _passwordController.text = 'password123';
                              _usernameError = null;
                              _passwordError = null;
                              _globalErrorBanner = null;
                            });
                          },
                        ),
                        ActionChip(
                          label: const Text('Empty Form (422)', style: TextStyle(fontSize: 11)),
                          backgroundColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              _usernameController.clear();
                              _passwordController.clear();
                              _usernameError = 'Username wajib diisi';
                              _passwordError = 'Password wajib diisi';
                              _globalErrorBanner = 'Username dan password wajib diisi';
                            });
                          },
                        ),
                        ActionChip(
                          label: const Text('Wrong Creds (401)', style: TextStyle(fontSize: 11)),
                          backgroundColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              _passwordController.clear();
                              _usernameError = null;
                              _passwordError = null;
                              _globalErrorBanner = 'Username atau password salah';
                            });
                          },
                        ),
                        ActionChip(
                          label: const Text('Blocked (403)', style: TextStyle(fontSize: 11)),
                          backgroundColor: Colors.white,
                          onPressed: _triggerBlockedAccountModal,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

