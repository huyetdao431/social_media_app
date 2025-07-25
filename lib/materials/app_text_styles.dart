import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static final TextStyle headline = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textLight,
  );

  static final TextStyle subHeadline = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.subHeadline,
  );

  static final TextStyle body = GoogleFonts.poppins(
    fontSize: 14,
    color: AppColors.textDark,
  );

  static final TextStyle bodyMuted = GoogleFonts.poppins(
    fontSize: 14,
    color: AppColors.textMuted,
  );

  static final TextStyle button = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark, // Button text
  );

  static final TextStyle caption = GoogleFonts.poppins(
    fontSize: 12,
    color: AppColors.textMuted,
  );
}
