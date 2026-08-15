import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';

class AppTheme {
  static TextTheme _buildTextTheme(TextTheme base, Color textColor) {
    return GoogleFonts.interTextTheme(base)
        .copyWith(
          displayLarge: GoogleFonts.nunito(
            textStyle: base.displayLarge?.copyWith(color: textColor),
          ),
          displayMedium: GoogleFonts.nunito(
            textStyle: base.displayMedium?.copyWith(color: textColor),
          ),
          displaySmall: GoogleFonts.nunito(
            textStyle: base.displaySmall?.copyWith(color: textColor),
          ),
          headlineLarge: GoogleFonts.nunito(
            textStyle: base.headlineLarge?.copyWith(color: textColor),
          ),
          headlineMedium: GoogleFonts.nunito(
            textStyle: base.headlineMedium?.copyWith(color: textColor),
          ),
          headlineSmall: GoogleFonts.nunito(
            textStyle: base.headlineSmall?.copyWith(color: textColor),
          ),
          titleLarge: GoogleFonts.nunito(
            textStyle: base.titleLarge?.copyWith(color: textColor),
          ),
          titleMedium: GoogleFonts.nunito(
            textStyle: base.titleMedium?.copyWith(color: textColor),
          ),
          titleSmall: GoogleFonts.nunito(
            textStyle: base.titleSmall?.copyWith(color: textColor),
          ),
        )
        .apply(bodyColor: textColor, displayColor: textColor);
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primaryLight,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
      ),
      textTheme: _buildTextTheme(
        ThemeData.light().textTheme,
        AppColors.textLight,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        labelStyle: const TextStyle(color: AppColors.textMutedLight),
        hintStyle: const TextStyle(color: AppColors.textMutedLight),
        floatingLabelStyle: const TextStyle(color: AppColors.primaryLight),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryDark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.secondaryDark,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
      ),
      textTheme: _buildTextTheme(
        ThemeData.dark().textTheme,
        AppColors.textDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        labelStyle: const TextStyle(color: AppColors.textMutedDark),
        hintStyle: const TextStyle(color: AppColors.textMutedDark),
        floatingLabelStyle: const TextStyle(color: AppColors.primaryDark),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
      ),
    );
  }
}
