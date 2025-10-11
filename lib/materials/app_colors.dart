import 'package:flutter/material.dart';

class AppColors {
  // Light Theme
  static const Color backgroundLight = Color(0xFFF9FAFB); // Nền chính
  static const Color surfaceLight = Color(0xFFFFFFFF);     // Card, input
  static const Color textDark = Color(0xFF111827);         // Text chính
  static const Color textMutedLight = Color(0xFF6B7280);   // Text phụ
  static const Color subHeadlineLight = Color(0xFF374151); // Sub-headline

  // Dark Theme
  static const Color backgroundDark = Color(0xFF0F172A);   // Nền chính dark
  static const Color surfaceDark = Color(0xFF1E293B);       // Card dark
  static const Color textLight = Color(0xFFF1F5F9);         // Text chính
  static const Color textMutedDark = Color(0xFF94A3B8);     // Text phụ dark
  static const Color subHeadlineDark = Color(0xFFCBD5E1);   // Sub-headline dark

  // Shared
  static const Color primary = Color(0xFF3B82F6);           // Xanh chủ đạo
  static const Color secondary = Color(0xFF8B5CF6);         // Tím nhạt
  static const Color accent = Color(0xFFEC4899);            // Hồng neon (CTA)

  // Skeleton / Shimmer (tùy chỉnh dễ)
  static const Color skeletonBaseLight = Color(0xFFE6E9EE);
  static const Color skeletonHighlightLight = Color(0xFFF7F9FB);
  static const Color skeletonBaseDark = Color(0xFF1B2430);
  static const Color skeletonHighlightDark = Color(0xFF2E3B4B);
}
