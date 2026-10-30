import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/app_button.dart';

class AttendanceCard extends StatelessWidget {
  final bool isOnDuty;
  final String? checkInTime;
  final VoidCallback onToggleDuty;
  final VoidCallback? onViewHistory;

  const AttendanceCard({
    super.key,
    required this.isOnDuty,
    this.checkInTime,
    required this.onToggleDuty,
    this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onViewHistory,
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isOnDuty ? AppColors.feedbackSuccessBg : const Color(0xFFFDEBEC),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.work_outline,
                      color: isOnDuty ? AppColors.feedbackSuccess : AppColors.feedbackDanger,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Status Kehadiran',
                              style: AppTypography.caption,
                            ),
                            if (onViewHistory != null) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.history, size: 12, color: AppColors.brand500),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isOnDuty ? AppColors.feedbackSuccess : AppColors.feedbackDanger,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isOnDuty ? 'On Duty' : 'Off Duty',
                              style: AppTypography.supportBold.copyWith(
                                color: isOnDuty ? AppColors.feedbackSuccess : AppColors.feedbackDanger,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isOnDuty
                              ? (checkInTime != null ? 'Check In $checkInTime' : 'Aktif Bertugas')
                              : 'Belum check in hari ini',
                          style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: AppButton(
              text: isOnDuty ? 'Check Out' : 'Check In',
              height: 38,
              borderRadius: 10,
              variant: isOnDuty ? AppButtonVariant.primary : AppButtonVariant.primary,
              onPressed: onToggleDuty,
            ),
          ),
        ],
      ),
    );
  }
}

