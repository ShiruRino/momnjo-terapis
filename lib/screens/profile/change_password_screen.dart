import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/api/api_exception.dart';
import '../../state/app_state.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/feedback_banner.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _oldPasswordError;
  bool _isLoading = false;

  bool get _isLengthValid => _newPasswordController.text.length >= 6;
  bool get _isMatchValid =>
      _confirmPasswordController.text.isNotEmpty &&
      _confirmPasswordController.text == _newPasswordController.text;

  void _handleSubmit() async {
    setState(() {
      _oldPasswordError = null;
    });

    final oldPass = _oldPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (oldPass.isEmpty) {
      setState(() => _oldPasswordError = 'Password lama wajib diisi.');
      return;
    }

    if (newPass.length < 6) return;
    if (confirmPass != newPass) return;

    setState(() => _isLoading = true);
    try {
      await AppState.instance.updateProfile(
        passwordLama: oldPass,
        passwordBaru: newPass,
      );
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password berhasil diperbarui.'),
            backgroundColor: AppColors.feedbackSuccess,
          ),
        );
        Navigator.pop(context);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _oldPasswordError = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengganti password: $e'),
            backgroundColor: AppColors.feedbackDanger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: const AppHeader(
        title: 'Ganti Password',
        subtitle: 'Perbarui kata sandi untuk menjaga keamanan akun Anda',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Padlock Graphic
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF0F4),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.brand100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_rounded, color: AppColors.brand500, size: 28),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Password Lama
            AppTextField(
              label: 'Password Lama',
              hintText: 'Masukkan kata sandi lama',
              controller: _oldPasswordController,
              isPassword: true,
              prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.inkMuted),
              errorMessage: _oldPasswordError,
              onChanged: (_) => setState(() => _oldPasswordError = null),
            ),
            const SizedBox(height: 16),

            // Password Baru
            AppTextField(
              label: 'Password Baru',
              hintText: 'Minimal 6 karakter',
              controller: _newPasswordController,
              isPassword: true,
              prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.inkMuted),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 6),
            if (_newPasswordController.text.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    _isLengthValid ? Icons.check_circle : Icons.cancel,
                    size: 14,
                    color: _isLengthValid ? AppColors.feedbackSuccess : AppColors.feedbackDanger,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isLengthValid ? 'Minimal 6 karakter.' : 'Password baru minimal 6 karakter.',
                    style: AppTypography.caption.copyWith(
                      color: _isLengthValid ? AppColors.feedbackSuccess : AppColors.feedbackDanger,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),

            // Konfirmasi Password Baru
            AppTextField(
              label: 'Konfirmasi Password Baru',
              hintText: 'Ulangi kata sandi baru',
              controller: _confirmPasswordController,
              isPassword: true,
              prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.inkMuted),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 6),
            if (_confirmPasswordController.text.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    _isMatchValid ? Icons.check_circle : Icons.cancel,
                    size: 14,
                    color: _isMatchValid ? AppColors.feedbackSuccess : AppColors.feedbackDanger,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isMatchValid ? 'Password sudah sesuai.' : 'Konfirmasi password tidak sesuai.',
                    style: AppTypography.caption.copyWith(
                      color: _isMatchValid ? AppColors.feedbackSuccess : AppColors.feedbackDanger,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),

            // Info callout
            const FeedbackBanner(
              message: 'Gunakan kata sandi yang kuat dan jangan bagikan kepada orang lain.',
              type: FeedbackBannerType.info,
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Batal',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'Perbarui Password',
                    isLoading: _isLoading,
                    onPressed: (_isLengthValid && _isMatchValid) ? _handleSubmit : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

