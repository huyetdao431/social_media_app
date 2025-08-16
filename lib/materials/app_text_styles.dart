import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle headline(BuildContext context) =>
      GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.headlineLarge?.color,
      );

  static TextStyle subHeadline(BuildContext context) =>
      GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.titleMedium?.color,
      );

  static TextStyle body(BuildContext context) =>
      GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      );

  static TextStyle bodyMuted(BuildContext context) =>
      GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      );

  static TextStyle caption(BuildContext context) =>
      GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).textTheme.bodySmall?.color,
      );

  static TextStyle button(BuildContext context) =>
      GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.labelLarge?.color,
      );
  static TextStyle username(BuildContext context) =>
      GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      );
  static TextStyle name(BuildContext context) =>
      GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).textTheme.bodySmall?.color,
      );

  static TextStyle hashtag(BuildContext context) =>
      GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.secondary,
      );

  static TextStyle comment(BuildContext context) =>
      GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      );

  static TextStyle commentUsername(BuildContext context) =>
      GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
      );

  static TextStyle link(BuildContext context) =>
      GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.secondary,
      );

  static TextStyle badge(BuildContext context) =>
      GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

}
