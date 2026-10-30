import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  static const TextStyle display = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.inkStrong,
    letterSpacing: -0.5,
  );

  static const TextStyle h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.inkStrong,
    letterSpacing: -0.3,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.inkStrong,
    letterSpacing: -0.2,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.inkStrong,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.inkStrong,
    height: 1.5,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.inkStrong,
    height: 1.5,
  );

  static const TextStyle support = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.inkMuted,
    height: 1.4,
  );

  static const TextStyle supportMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.inkStrong,
    height: 1.4,
  );

  static const TextStyle supportBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.inkStrong,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.inkMuted,
    height: 1.3,
  );

  static const TextStyle captionBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.inkMuted,
    height: 1.3,
  );

  /// Tabular / Monospace digits for timer and currency
  static const TextStyle timerDisplay = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.inkStrong,
    fontFeatures: [FontFeature.tabularFigures()],
    letterSpacing: 1.0,
  );

  static const TextStyle currencyDisplay = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.inkStrong,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}

