import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    primaryColor: AppColors.primary,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textDark),
      titleTextStyle: AppTextStyles.headline,
    ),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      headlineLarge: AppTextStyles.headline,
      titleMedium: AppTextStyles.subHeadline,
      bodyLarge: AppTextStyles.body,
      bodyMedium: AppTextStyles.bodyMuted,
      labelLarge: AppTextStyles.button,
      bodySmall: AppTextStyles.caption,
    ),
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.tertiary,
      surface: AppColors.surface,
      onPrimary: AppColors.textDark,
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
      titleTextStyle: AppTextStyles.headline.copyWith(color: AppColors.textLight),
    ),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      headlineLarge: AppTextStyles.headline.copyWith(color: AppColors.textLight),
      titleMedium: AppTextStyles.subHeadline.copyWith(color: AppColors.textMuted),
      bodyLarge: AppTextStyles.body.copyWith(color: AppColors.textLight),
      bodyMedium: AppTextStyles.bodyMuted,
      labelLarge: AppTextStyles.button.copyWith(color: AppColors.textDark),
      bodySmall: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
    ),
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.tertiary,
      surface: AppColors.surface,
      onPrimary: AppColors.textDark,
      onSurface: AppColors.textLight,
    ),
  );
}
