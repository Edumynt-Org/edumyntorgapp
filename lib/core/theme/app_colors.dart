import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primaryLight = Color(0xFF1E3A8A); // Deep Blue
  static const Color primaryDark = Color(0xFF60A5FA); // Light Blue

  static const Color secondaryLight = Color(0xFFE0E7FF);
  static const Color secondaryDark = Color(0x1960A5FA); // 10% opacity blue

  static const Color accentLight = Color(0xFFD97706); // Gold
  static const Color accentDark = Color(0xFFFBBF24); // Gold

  // Legacy aliases for existing screens
  static const Color primary = primaryLight;
  static const Color secondary = secondaryLight;

  // Backgrounds
  static const Color backgroundLight = Color(0xFFF4F4F5);
  static const Color backgroundDark = Color(0xFF09090B);
  
  // Surfaces
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF18181B);
  
  // Text
  static const Color textLight = Color(0xFF09090B);
  static const Color textDark = Color(0xFFFAFAFA);
  static const Color textMutedLight = Color(0xFF71717A);
  static const Color textMutedDark = Color(0xFFA1A1AA);
  
  // Borders & Dividers
  static const Color borderLight = Color(0xFFE4E4E7);
  static const Color borderDark = Color(0xFF27272A);
  
  // Status
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
}
