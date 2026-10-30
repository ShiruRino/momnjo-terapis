import 'package:flutter/material.dart';

/// Semantic color tokens defined in docs/DESIGN_SYSTEM.md
class AppColors {
  // Brand
  static const Color brand500 = Color(0xFFAD3B64);
  static const Color brand600 = Color(0xFFA63762);
  static const Color brand700 = Color(0xFF8B2349);
  static const Color brand100 = Color(0xFFF7DFE8);
  static const Color brand50 = Color(0xFFFCF0F4);

  // Ink / Text
  static const Color inkStrong = Color(0xFF111B3C);
  static const Color inkMuted = Color(0xFF64708A);
  static const Color inkLight = Color(0xFF9AA4B8);

  // Surface
  static const Color surfaceCanvas = Color(0xFFFFFAFA);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceBorder = Color(0xFFE5E8EF);
  static const Color surfaceSubtle = Color(0xFFF8F9FC);

  // Feedback
  static const Color feedbackSuccess = Color(0xFF19865C);
  static const Color feedbackSuccessBg = Color(0xFFE8F6F0);

  static const Color feedbackWarning = Color(0xFFB95A08);
  static const Color feedbackWarningBg = Color(0xFFFFF4E8);

  static const Color feedbackDanger = Color(0xFFD52F46);
  static const Color feedbackDangerBg = Color(0xFFFDEBEC);

  static const Color feedbackInfo = Color(0xFF3159A2);
  static const Color feedbackInfoBg = Color(0xFFEDF2FA);

  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brand500, brand600],
  );

  static const LinearGradient brandCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brand600, brand700],
  );

  static const LinearGradient softPinkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF5F7), Color(0xFFFFFAFA)],
  );
}

