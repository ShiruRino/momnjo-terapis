import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import 'app_button.dart';

class CustomDialogs {
  /// Blocked Account (HTTP 403)
  static Future<void> showBlockedAccountDialog(
    BuildContext context, {
    required List<String> branchList,
    required ValueChanged<String> onContactAdmin,
  }) {
    String selectedBranch = branchList.isNotEmpty ? branchList.first : 'Momnjo Dharmawangsa';

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF4E8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.warning_amber_rounded, color: AppColors.feedbackWarning, size: 32),
                    ),
                    const SizedBox(height: 16),
                    const Text('Akun Tidak Aktif', style: AppTypography.h2),
                    const SizedBox(height: 8),
                    const Text(
                      'Akun Anda tidak aktif atau diblokir.\nSilakan hubungi admin.',
                      textAlign: TextAlign.center,
                      style: AppTypography.support,
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Pilih Gerai untuk Dihubungi',
                        style: AppTypography.captionBold.copyWith(color: AppColors.inkMuted),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedBranch,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.inkMuted),
                          items: branchList.map((branch) {
                            return DropdownMenuItem<String>(
                              value: branch,
                              child: Row(
                                children: [
                                  const Icon(Icons.storefront_outlined, size: 18, color: AppColors.brand500),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      branch,
                                      style: AppTypography.supportMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => selectedBranch = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: 'Hubungi Admin Gerai',
                      icon: const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(ctx);
                        onContactAdmin(selectedBranch);
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
              ),
            );
          },
        );
      },
    );
  }

  /// Account Deactivated (HTTP 403 on protected action)
  static Future<void> showAccountDeactivatedDialog(BuildContext context, {required VoidCallback onBackToLogin}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
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
                  child: const Icon(Icons.priority_high, color: AppColors.feedbackDanger, size: 32),
                ),
                const SizedBox(height: 16),
                const Text('Akun Dinonaktifkan', style: AppTypography.h2),
                const SizedBox(height: 8),
                const Text(
                  'Akun Anda telah dinonaktifkan.\nSilakan hubungi admin.',
                  textAlign: TextAlign.center,
                  style: AppTypography.support,
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: 'Kembali ke Login',
                  onPressed: () {
                    Navigator.pop(ctx);
                    onBackToLogin();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Job Not Found or Reassigned (HTTP 404)
  static Future<void> showJobNotFoundDialog(BuildContext context, {required VoidCallback onBackToJobs}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.feedbackDangerBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.folder_off_outlined, color: AppColors.feedbackDanger, size: 32),
                ),
                const SizedBox(height: 16),
                const Text('Pekerjaan Tidak Tersedia', style: AppTypography.h2),
                const SizedBox(height: 8),
                const Text(
                  'Job tidak ditemukan atau Anda tidak memiliki akses ke job ini.\n\nPekerjaan mungkin telah dialihkan ke terapis lain.',
                  textAlign: TextAlign.center,
                  style: AppTypography.support,
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: 'Kembali ke Daftar Job',
                  onPressed: () {
                    Navigator.pop(ctx);
                    onBackToJobs();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Treatment Already Completed (Duplicate complete dialog)
  static Future<void> showTreatmentAlreadyCompletedDialog(BuildContext context, {required VoidCallback onBack}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.feedbackDangerBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.article_outlined, color: AppColors.feedbackDanger, size: 32),
                ),
                const SizedBox(height: 16),
                const Text('Treatment Telah Selesai', style: AppTypography.h2),
                const SizedBox(height: 8),
                const Text(
                  'Pekerjaan ini sudah tercatat selesai.\n\nJob ini sudah berstatus Selesai. Silakan kembali ke daftar job untuk melihat pekerjaan aktif lainnya.',
                  textAlign: TextAlign.center,
                  style: AppTypography.support,
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: 'Kembali ke Daftar Job Aktif',
                  onPressed: () {
                    Navigator.pop(ctx);
                    onBack();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Reassign Warning Conflict (HTTP 409)
  static Future<bool?> showReassignConflictDialog(
    BuildContext context, {
    required String currentTerapis,
    required String newTerapis,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF4E8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.sync_problem, color: AppColors.feedbackWarning, size: 30),
                ),
                const SizedBox(height: 16),
                const Text('Konfirmasi Pengalihan Job', style: AppTypography.h2),
                const SizedBox(height: 8),
                Text(
                  'Terapis $currentTerapis saat ini sedang MEMPROSES treatment ini. Apakah Anda yakin ingin memindahkan job ke $newTerapis?',
                  textAlign: TextAlign.center,
                  style: AppTypography.support,
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: 'Tetap Pindahkan (Force)',
                  variant: AppButtonVariant.danger,
                  onPressed: () => Navigator.pop(ctx, true),
                ),
                const SizedBox(height: 10),
                AppButton(
                  text: 'Batal',
                  variant: AppButtonVariant.secondary,
                  onPressed: () => Navigator.pop(ctx, false),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

