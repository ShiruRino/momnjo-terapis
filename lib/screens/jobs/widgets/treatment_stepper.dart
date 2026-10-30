import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/job_model.dart';

class TreatmentStepper extends StatelessWidget {
  final bool isHomecare;
  final StatusLayanan currentStatus;

  const TreatmentStepper({
    super.key,
    required this.isHomecare,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    final steps = isHomecare
        ? ['Menunggu', 'Tiba di Lokasi', 'Proses', 'Selesai']
        : ['Menunggu', 'Proses', 'Selesai'];

    int activeIndex = 0;
    if (isHomecare) {
      switch (currentStatus) {
        case StatusLayanan.menunggu:
          activeIndex = 0;
          break;
        case StatusLayanan.arrived:
          activeIndex = 1;
          break;
        case StatusLayanan.proses:
        case StatusLayanan.dijeda:
          activeIndex = 2;
          break;
        case StatusLayanan.selesai:
          activeIndex = 3;
          break;
      }
    } else {
      switch (currentStatus) {
        case StatusLayanan.menunggu:
        case StatusLayanan.arrived:
          activeIndex = 0;
          break;
        case StatusLayanan.proses:
        case StatusLayanan.dijeda:
          activeIndex = 1;
          break;
        case StatusLayanan.selesai:
          activeIndex = 2;
          break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.hub_outlined, size: 16, color: AppColors.brand500),
            const SizedBox(width: 6),
            const Text('Progres Pekerjaan', style: AppTypography.supportBold),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: List.generate(steps.length * 2 - 1, (i) {
            if (i.isOdd) {
              final stepBefore = i ~/ 2;
              final isPassed = stepBefore < activeIndex;
              return Expanded(
                child: Container(
                  height: 2,
                  color: isPassed ? AppColors.brand500 : AppColors.surfaceBorder,
                ),
              );
            } else {
              final stepIndex = i ~/ 2;
              final isCompleted = stepIndex < activeIndex;
              final isCurrent = stepIndex == activeIndex;

              return Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AppColors.brand500
                      : (isCurrent ? Colors.white : Colors.white),
                  border: Border.all(
                    color: isCompleted || isCurrent
                        ? AppColors.brand500
                        : AppColors.surfaceBorder,
                    width: isCurrent ? 5 : 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                    : null,
              );
            }
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: steps.map((label) {
            return SizedBox(
              width: 70,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  fontSize: 10,
                  color: AppColors.inkStrong,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

