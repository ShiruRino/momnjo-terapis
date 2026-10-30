import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/api/api_exception.dart';
import '../../state/app_state.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/feedback_banner.dart';
import '../../widgets/custom_bottom_sheets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _namaLengkapController;
  late TextEditingController _nicknameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  String? _emailError;
  String? _phoneError;
  bool _isLoading = false;

  late String _initialNama;
  late String _initialNickname;
  late String _initialEmail;
  late String _initialPhone;
  late String _initialAddress;

  @override
  void initState() {
    super.initState();
    final user = AppState.instance.user;
    _initialNama = user.namaLengkap;
    _initialNickname = user.nickname;
    _initialEmail = user.email;
    _initialPhone = user.noTelp;
    _initialAddress = user.address;

    _namaLengkapController = TextEditingController(text: _initialNama);
    _nicknameController = TextEditingController(text: _initialNickname);
    _emailController = TextEditingController(text: _initialEmail);
    _phoneController = TextEditingController(text: _initialPhone);
    _addressController = TextEditingController(text: _initialAddress);
  }

  bool get _hasChanges {
    return _namaLengkapController.text.trim() != _initialNama ||
        _nicknameController.text.trim() != _initialNickname ||
        _emailController.text.trim() != _initialEmail ||
        _phoneController.text.trim() != _initialPhone ||
        _addressController.text.trim() != _initialAddress;
  }

  void _handleSave() async {
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    setState(() {
      _emailError = null;
      _phoneError = null;
    });

    // Validation per API v4 & mockup
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _emailError = 'Format email tidak valid.');
      return;
    }

    final phoneRegex = RegExp(r'^[0-9]+$');
    if (!phoneRegex.hasMatch(phone)) {
      setState(() => _phoneError = 'Nomor telepon hanya boleh berisi angka.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AppState.instance.updateProfile(
        namaLengkap: _namaLengkapController.text.trim(),
        nickname: _nicknameController.text.trim(),
        email: email,
        noTelp: phone,
        address: _addressController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _initialNama = _namaLengkapController.text.trim();
          _initialNickname = _nicknameController.text.trim();
          _initialEmail = email;
          _initialPhone = phone;
          _initialAddress = _addressController.text.trim();
        });
        await CustomBottomSheets.showEditProfileSuccessSheet(context);
        if (mounted) Navigator.pop(context);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (e.message.toLowerCase().contains('email')) {
            _emailError = e.message;
          } else if (e.message.toLowerCase().contains('telepon') || e.message.toLowerCase().contains('telp')) {
            _phoneError = e.message;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.message), backgroundColor: AppColors.feedbackDanger),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: AppColors.feedbackDanger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AppState.instance.user;

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: const AppHeader(
        title: 'Edit Profil',
        subtitle: 'Perbarui informasi pribadi Anda',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.brand100,
                    child: const Icon(Icons.person, color: AppColors.brand500, size: 36),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.namaLengkap, style: AppTypography.h2.copyWith(fontSize: 16)),
                        const SizedBox(height: 2),
                        Text(user.position, style: AppTypography.caption),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.storefront_outlined, size: 14, color: AppColors.brand500),
                            const SizedBox(width: 4),
                            Text(
                              user.namaGerai,
                              style: AppTypography.captionBold.copyWith(color: AppColors.brand500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card: Informasi Pribadi (Editable per API v4)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.badge_outlined, size: 18, color: AppColors.brand500),
                      const SizedBox(width: 8),
                      Text('Informasi Pribadi', style: AppTypography.supportBold.copyWith(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Nama Lengkap',
                    controller: _namaLengkapController,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Nama Panggilan',
                    controller: _nicknameController,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined, size: 18, color: AppColors.inkMuted),
                    errorMessage: _emailError,
                    onChanged: (_) => setState(() => _emailError = null),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Nomor Telepon',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_outlined, size: 18, color: AppColors.inkMuted),
                    errorMessage: _phoneError,
                    onChanged: (_) => setState(() => _phoneError = null),
                  ),
                  const SizedBox(height: 12),
                  // Alamat editable (added per API v4 revision!)
                  AppTextField(
                    label: 'Alamat',
                    controller: _addressController,
                    maxLines: 2,
                    maxLength: 200,
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card: Informasi Akun (Readonly)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lock_outline, size: 18, color: AppColors.brand500),
                      const SizedBox(width: 8),
                      Text(
                        'Informasi Akun (Tidak dapat diubah)',
                        style: AppTypography.supportBold.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Username',
                    initialValue: user.username,
                    isReadOnly: true,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Gerai',
                    initialValue: user.namaGerai,
                    isReadOnly: true,
                  ),
                  const SizedBox(height: 10),
                  const FeedbackBanner(
                    message: 'Username dan gerai tidak dapat diubah melalui aplikasi.',
                    type: FeedbackBannerType.info,
                    margin: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 422 Prevention Callout if no changes made
            if (!_hasChanges) ...[
              const FeedbackBanner(
                message: 'Belum ada perubahan. Lakukan perubahan pada data untuk mengaktifkan tombol simpan.',
                type: FeedbackBannerType.info,
              ),
            ],

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
                    text: 'Simpan Perubahan',
                    isLoading: _isLoading,
                    onPressed: _hasChanges ? _handleSave : null,
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

