import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class JobSummaryCard extends StatelessWidget {
  final int count;
  final String label;
  final String subLabel;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final VoidCallback? onTap;

  const JobSummaryCard({
    super.key,
    required this.count,
    required this.label,
    required this.subLabel,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor, size: 18),
                  ),
                  Text(
                    subLabel,
                    style: AppTypography.caption.copyWith(fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '$count',
                style: AppTypography.h1.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Lihat detail',
                    style: AppTypography.captionBold.copyWith(
                      color: AppColors.brand500,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward, size: 12, color: AppColors.brand500),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

