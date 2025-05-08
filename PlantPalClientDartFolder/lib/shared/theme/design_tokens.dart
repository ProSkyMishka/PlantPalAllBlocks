import 'package:flutter/material.dart';

class AppColors {
  static const background    = Color(0xFFF2F2F2);
  static const surface       = Color(0xFFFFFFFF);
  static const primary       = Color(0xFF3A9D23);
  static const primaryDark   = Color(0xFF276E1C);
  static const textPrimary   = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF666666);
  static const error         = Color(0xFFD32F2F);
}

class AppSpacing {
  static const xs = 4.0, s = 8.0, m = 16.0, l = 24.0, xl = 32.0;
}

class AppTypography {
  static const fontFamily = 'Roboto';
  static final heading1 = TextStyle(
    fontFamily: fontFamily, fontSize: 28, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.2,
  );
  static final heading2 = TextStyle(
    fontFamily: fontFamily, fontSize: 22, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, height: 1.3,
  );
  static final body = TextStyle(
    fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary, height: 1.5,
  );
  static final hint = TextStyle(
    fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, height: 1.4,
  );
  static final button = TextStyle(
    fontFamily: fontFamily, fontSize: 18, fontWeight: FontWeight.w500,
    color: AppColors.surface, height: 1.2,
  );
}

class AppTheme {
  static ThemeData light() => ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary, onPrimary: AppColors.surface,
      secondary: AppColors.primaryDark, onSecondary: AppColors.surface,
      background: AppColors.background, onBackground: AppColors.textPrimary,
      surface: AppColors.surface, onSurface: AppColors.textPrimary,
      error: AppColors.error, onError: AppColors.surface,
    ),
    fontFamily: AppTypography.fontFamily,
    textTheme: TextTheme(
      displayLarge: AppTypography.heading1,
      displayMedium: AppTypography.heading2,
      bodyLarge: AppTypography.body,
      titleMedium: AppTypography.hint,
      labelLarge: AppTypography.button,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: AppColors.surface,
      hintStyle: AppTypography.hint,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m, vertical: AppSpacing.s),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
          textStyle: AppTypography.button),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primaryDark,
      unselectedItemColor: AppColors.textSecondary,
      showUnselectedLabels: true,
      selectedLabelStyle:
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
    ),
  );
}
