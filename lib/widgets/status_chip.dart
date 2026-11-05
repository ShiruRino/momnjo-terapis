import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../data/models/job_model.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Widget? icon;
  final bool hasDot;
  final Color? dotColor;

  const StatusChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
    this.hasDot = false,
    this.dotColor,
  });

  factory StatusChip.fromJobStatus(StatusLayanan status) {
    switch (status) {
      case StatusLayanan.menunggu:
        return const StatusChip(
          label: 'Menunggu',
          backgroundColor: AppColors.brand100,
          textColor: AppColors.brand500,
        );
      case StatusLayanan.arrived:
        return const StatusChip(
          label: 'Arrived',
          backgroundColor: AppColors.feedbackSuccessBg,
          textColor: AppColors.feedbackSuccess,
        );
      case StatusLayanan.proses:
        return const StatusChip(
          label: 'Proses',
          backgroundColor: AppColors.feedbackWarningBg,
          textColor: AppColors.feedbackWarning,
        );
      case StatusLayanan.dijeda:
        return const StatusChip(
          label: 'Dijeda',
          backgroundColor: AppColors.feedbackWarningBg,
          textColor: AppColors.feedbackWarning,
        );
      case StatusLayanan.selesai:
        return const StatusChip(
          label: 'Selesai',
          backgroundColor: AppColors.feedbackSuccessBg,
          textColor: AppColors.feedbackSuccess,
        );
    }
  }

  factory StatusChip.closed() {
    return const StatusChip(
      label: 'Closed',
      backgroundColor: Color(0xFFFFF0E8),
      textColor: Color(0xFFC75A18),
    );
  }

  factory StatusChip.category(KategoriLayanan kategori) {
    if (kategori == KategoriLayanan.homecare) {
      return const StatusChip(
        label: 'Homecare',
        backgroundColor: Color(0xFFFBF0F4),
        textColor: AppColors.brand500,
        icon: Icon(Icons.home_outlined, size: 13, color: AppColors.brand500),
      );
    } else {
      return const StatusChip(
        label: 'Onsite',
        backgroundColor: Color(0xFFEEF6F2),
        textColor: Color(0xFF2C7D59),
        icon: Icon(Icons.storefront_outlined, size: 13, color: Color(0xFF2C7D59)),
      );
    }
  }

  factory StatusChip.duty({required bool isOnDuty}) {
    return StatusChip(
      label: isOnDuty ? 'On Duty' : 'Off Duty',
      backgroundColor: isOnDuty ? AppColors.feedbackSuccessBg : const Color(0xFFFDEBEC),
      textColor: isOnDuty ? AppColors.feedbackSuccess : AppColors.feedbackDanger,
      hasDot: true,
      dotColor: isOnDuty ? AppColors.feedbackSuccess : AppColors.feedbackDanger,
    );
  }

  factory StatusChip.attendanceAction({required bool isCheckIn, bool isAuto = false}) {
    if (isAuto) {
      return const StatusChip(
        label: 'Keluar (Otomatis)',
        backgroundColor: Color(0xFFFFEEDD),
        textColor: Color(0xFFC25D00),
      );
    }
    if (isCheckIn) {
      return const StatusChip(
        label: 'Masuk',
        backgroundColor: AppColors.feedbackSuccessBg,
        textColor: AppColors.feedbackSuccess,
      );
    } else {
      return const StatusChip(
        label: 'Keluar',
        backgroundColor: Color(0xFFFDEBEC),
        textColor: AppColors.feedbackDanger,
      );
    }
  }

  factory StatusChip.treatmentType({required String type}) {
    final lower = type.toLowerCase().trim();

    if (lower.contains('override')) {
      return const StatusChip(
        label: 'Redeem Override',
        backgroundColor: Color(0xFFEDE9FE), // Soft Purple
        textColor: Color(0xFF6D28D9),
      );
    } else if (lower.contains('paket lama') || lower.contains('old package')) {
      return const StatusChip(
        label: 'Paket Lama',
        backgroundColor: Color(0xFFE2E8F0), // Soft Slate
        textColor: Color(0xFF475569),
      );
    } else if (lower.contains('redeem') || lower.contains('paket') || lower.contains('package')) {
      return const StatusChip(
        label: 'Redeem Paket',
        backgroundColor: Color(0xFFFFF3E6), // Soft Amber/Orange
        textColor: Color(0xFFC9600E),
      );
    } else if (lower.contains('reguler') ||
        lower.contains('regular') ||
        lower.contains('normal') ||
        lower.contains('treatment') ||
        lower.contains('single') ||
        lower.contains('layanan')) {
      return const StatusChip(
        label: 'Treatment Reguler',
        backgroundColor: Color(0xFFFDEFF4), // Brand Pink
        textColor: AppColors.brand500,
      );
    } else {
      return StatusChip(
        label: type.isNotEmpty ? type : 'Treatment Reguler',
        backgroundColor: const Color(0xFFF0F2F6),
        textColor: AppColors.inkStrong,
      );
    }
  }

  factory StatusChip.override({required bool isMasuk}) {
    return StatusChip(
      label: isMasuk ? 'Override Masuk' : 'Override Keluar',
      backgroundColor: isMasuk ? AppColors.feedbackSuccessBg : const Color(0xFFFDEBEC),
      textColor: isMasuk ? AppColors.feedbackSuccess : AppColors.feedbackDanger,
      icon: Icon(
        isMasuk ? Icons.arrow_downward : Icons.arrow_upward,
        size: 13,
        color: isMasuk ? AppColors.feedbackSuccess : AppColors.feedbackDanger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (hasDot) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: dotColor ?? textColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.captionBold.copyWith(
              color: textColor,
              fontSize: 11,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

