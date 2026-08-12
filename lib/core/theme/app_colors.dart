import 'package:flutter/material.dart';

/// Single source of truth for all colors in the app.
/// Changing a hex value here will automatically update both light and dark themes.
class AppColors {
  // Brand / Primary
  static const Color primary = Color(0xFF58CC02);
  static const Color primaryShadow = Color(0xFF58A700);

  // Secondary
  static const Color secondary = Color(0xFF1CB0F6);
  static const Color secondaryShadow = Color(0xFF1899D6);

  // Warning / Gold
  static const Color warning = Color(0xFFFFC800);
  static const Color warningShadow = Color(0xFFFF9600);

  // Danger / Error
  static const Color danger = Color(0xFFFF4B4B);
  static const Color dangerShadow = Color(0xFFEA2B2B);

  // Backgrounds
  static const Color bgLight = Color(0xFFFFFFFF);
  static const Color bgDark = Color(0xFF131F24);

  // Surfaces (Cards, Modals)
  static const Color surfaceLight = Color(0xFFF7F7F7);
  static const Color surfaceDark = Color(0xFF202F36);

  // Text
  static const Color textLight = Color(0xFF4B4B4B);
  static const Color textDark = Color(0xFFFFFFFF);
  static const Color textMutedLight = Color(0xFF777777);
  static const Color textMutedDark = Color(0xFFA1A1A1);

  // Borders
  static const Color borderLight = Color(0xFFE5E5E5);
  static const Color borderDark = Color(0xFF37464F);
}
