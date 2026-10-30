import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/utils/formatters.dart';
import 'app_button.dart';
import 'app_text_field.dart';

class CustomBottomSheets {
  /// Check-in confirmation modal
  static Future<bool?> showCheckInSheet(BuildContext context, {
    required String branchName,
    required String address,
    required VoidCallback onConfirm,
  }) {
    final noteController = TextEditingController();
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Konfirmasi Check In', style: AppTypography.h2),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.inkMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              Text(
                'Pastikan lokasi dan waktu sudah sesuai sebelum melakukan check in.',
                style: AppTypography.support.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 16),
              // Lokasi Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: AppColors.brand500, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(branchName, style: AppTypography.supportBold),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.feedbackSuccessBg,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'Lokasi Sesuai',
                                  style: AppTypography.captionBold.copyWith(
                                    color: AppColors.feedbackSuccess,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(address, style: AppTypography.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Waktu Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: AppColors.brand500, size: 24),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Waktu Check In', style: AppTypography.caption),
                        const SizedBox(height: 2),
                        Text(
                          Formatters.formatDateTime(DateTime.now()),
                          style: AppTypography.supportBold,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Catatan (Opsional)',
                hintText: 'Tambahkan catatan jika ada...',
                controller: noteController,
                maxLines: 2,
                maxLength: 200,
              ),
              const SizedBox(height: 20),
              AppButton(
                text: 'Konfirmasi Check In',
                onPressed: () {
                  Navigator.pop(ctx, true);
                  onConfirm();
                },
              ),
              const SizedBox(height: 10),
              AppButton(
                text: 'Batal',
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.pop(ctx, false),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Selesaikan Treatment modal
  static Future<bool?> showFinishTreatmentSheet(BuildContext context, {
    required String customerName,
    required String treatmentName,
    required bool isOnsite,
    required int totalDurationSeconds,
    required VoidCallback onConfirm,
  }) {
    final noteController = TextEditingController();
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Selesaikan Treatment', style: AppTypography.h2),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.inkMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              Text(
                'Pastikan treatment telah selesai dilakukan dengan baik sebelum mengonfirmasi.',
                style: AppTypography.support.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 16),
              // Item summary card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.brand100,
                      child: const Icon(Icons.person, color: AppColors.brand500),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(customerName, style: AppTypography.supportBold),
                          const SizedBox(height: 2),
                          Text(treatmentName, style: AppTypography.caption),
                          const SizedBox(height: 4),
                          Text(
                            isOnsite ? 'Onsite • 60 menit' : 'Homecare • 90 menit',
                            style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Durasi', style: AppTypography.caption),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.formatDuration(totalDurationSeconds),
                            style: AppTypography.supportBold.copyWith(
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Selesai Pada', style: AppTypography.caption),
                          const SizedBox(height: 4),
                          Text(
                            '${DateTime.now().hour.toString().padLeft(2, '0')}.${DateTime.now().minute.toString().padLeft(2, '0')} WIB',
                            style: AppTypography.supportBold,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Catatan Internal (Opsional)',
                hintText: 'Tambahkan catatan mengenai hasil treatment...',
                controller: noteController,
                maxLines: 2,
                maxLength: 200,
              ),
              const SizedBox(height: 20),
              AppButton(
                text: 'Konfirmasi Selesai',
                onPressed: () {
                  Navigator.pop(ctx, true);
                  onConfirm();
                },
              ),
              const SizedBox(height: 10),
              AppButton(
                text: 'Batal',
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.pop(ctx, false),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Session Expired (HTTP 401) bottom sheet
  static Future<void> showSessionExpiredSheet(BuildContext context, {required VoidCallback onLoginAgain}) {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.brand100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline, color: AppColors.brand500, size: 28),
              ),
              const SizedBox(height: 16),
              const Text('Sesi Telah Berakhir', style: AppTypography.h2),
              const SizedBox(height: 8),
              const Text(
                'Silakan masuk kembali untuk melanjutkan.',
                textAlign: TextAlign.center,
                style: AppTypography.support,
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Masuk Kembali',
                onPressed: () {
                  Navigator.pop(ctx);
                  onLoginAgain();
                },
              ),
              const SizedBox(height: 10),
              AppButton(
                text: 'Tutup',
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Logout confirmation sheet
  static Future<bool?> showLogoutConfirmationSheet(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.feedbackDangerBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, color: AppColors.feedbackDanger, size: 28),
              ),
              const SizedBox(height: 16),
              const Text('Keluar dari Akun?', style: AppTypography.h2),
              const SizedBox(height: 8),
              const Text(
                'Apakah Anda yakin ingin keluar dari aplikasi Momnjo Therapist?',
                textAlign: TextAlign.center,
                style: AppTypography.support,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Tetap Masuk',
                      variant: AppButtonVariant.secondary,
                      onPressed: () => Navigator.pop(ctx, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Ya, Keluar',
                      variant: AppButtonVariant.danger,
                      onPressed: () => Navigator.pop(ctx, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Branch Contact Unavailable (HTTP 404) sheet
  static Future<void> showBranchUnavailableSheet(BuildContext context, {required String branchName}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.feedbackDangerBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.storefront_outlined, color: AppColors.feedbackDanger, size: 28),
              ),
              const SizedBox(height: 16),
              const Text('Kontak Gerai Belum Tersedia', style: AppTypography.h2),
              const SizedBox(height: 8),
              const Text(
                'Data kontak gerai tidak ditemukan atau sedang dinonaktifkan.',
                textAlign: TextAlign.center,
                style: AppTypography.support,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, color: AppColors.inkMuted, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Gerai', style: AppTypography.caption),
                          Text(branchName, style: AppTypography.supportBold),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const AppButton(
                text: 'Hubungi via WhatsApp',
                onPressed: null, // Disabled
              ),
              const SizedBox(height: 10),
              AppButton(
                text: 'Kembali',
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Edit Profile Success sheet
  static Future<void> showEditProfileSuccessSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.feedbackSuccessBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: AppColors.feedbackSuccess, size: 36),
              ),
              const SizedBox(height: 16),
              const Text('Profil Berhasil Diperbarui', style: AppTypography.h2),
              const SizedBox(height: 8),
              const Text(
                'Informasi pribadi Anda telah disimpan.',
                textAlign: TextAlign.center,
                style: AppTypography.support,
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Kembali ke Profil',
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }
}

