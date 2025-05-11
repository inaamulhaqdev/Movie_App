import 'package:flutter/material.dart';
import 'app_typography.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      // Main colors
      primaryColor: AppColors.darkPurple,
      scaffoldBackgroundColor: AppColors.lightGray,

      // Text colors
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),

      // Divider color
      dividerColor: AppColors.dividerGray,

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightGray,
        selectedColor: AppColors.accentBlue,
        labelStyle: const TextStyle(color: AppColors.textGray),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // Color scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.darkPurple,
        secondary: AppColors.accentBlue,
        surface: AppColors.lightGray,
        background: AppColors.lightGray,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textGray,
        onBackground: AppColors.textGray,
      ),
    );
  }

  static ThemeData get darkTheme {
    return lightTheme.copyWith(brightness: Brightness.dark);
  }
}
