import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/utils/formatters.dart';

class TreatmentTimerWidget extends StatelessWidget {
  final int durasiStandarDetik;
  final int elapsedSeconds;
  final int remainingSeconds;
  final bool isPaused;
  final String? pausedSince;

  const TreatmentTimerWidget({
    super.key,
    required this.durasiStandarDetik,
    required this.elapsedSeconds,
    required this.remainingSeconds,
    this.isPaused = false,
    this.pausedSince,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = durasiStandarDetik > 0
        ? (elapsedSeconds / durasiStandarDetik).clamp(0.0, 1.0)
        : 0.0;
    final int durasiMenit = durasiStandarDetik ~/ 60;

    return Column(
      children: [
        Center(
          child: SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Circular Ring Painter
                CustomPaint(
                  size: const Size(240, 240),
                  painter: _TimerRingPainter(
                    progress: progress,
                    isPaused: isPaused,
                  ),
                ),
                // Center Content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isPaused) ...[
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFDEBEC),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.pause, size: 20, color: AppColors.brand500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Treatment Dijeda',
                        style: AppTypography.captionBold.copyWith(color: AppColors.brand500),
                      ),
                      const SizedBox(height: 4),
                    ] else ...[
                      Text(
                        'Sisa Waktu',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.inkMuted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      Formatters.formatDuration(remainingSeconds),
                      style: AppTypography.timerDisplay.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: isPaused ? AppColors.brand700 : AppColors.inkStrong,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'dari $durasiMenit menit',
                      style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Elapsed / Waktu Berjalan Info
        Center(
          child: Column(
            children: [
              Text(
                'Waktu Berjalan',
                style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
              ),
              const SizedBox(height: 2),
              Text(
                Formatters.formatDuration(elapsedSeconds),
                style: AppTypography.h2.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              if (isPaused && pausedSince != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E8),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    pausedSince!,
                    style: AppTypography.captionBold.copyWith(
                      color: AppColors.feedbackWarning,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final bool isPaused;

  _TimerRingPainter({
    required this.progress,
    required this.isPaused,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    const strokeWidth = 12.0;

    // Track Background
    final trackPaint = Paint()
      ..color = const Color(0xFFF7DFE8).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Active Progress Arc
    final progressPaint = Paint()
      ..color = isPaused ? const Color(0xFFE28B9F) : AppColors.brand500
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isPaused != isPaused;
  }
}
