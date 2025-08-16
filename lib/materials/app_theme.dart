import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    primaryColor: AppColors.primary,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textDark),
      titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
    ),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.subHeadlineLight),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.textDark),
      bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.textMutedLight),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textMutedLight),
    ),
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceLight,
      onPrimary: Colors.white,
      onSurface: AppColors.textDark,
    ),
  );

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    primaryColor: AppColors.primary,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textLight),
      titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textLight),
    ),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textLight),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.subHeadlineDark),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.textLight),
      bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.textMutedDark),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textLight),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textMutedDark),
    ),
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceDark,
      onPrimary: Colors.white,
      onSurface: AppColors.textLight,
    ),
  );
}
