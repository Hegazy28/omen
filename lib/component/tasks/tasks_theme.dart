// lib/features/tasks/widgets/tasks_theme.dart
//
// All colors, text styles, and decoration helpers used by the task widget.
// Edit this file to restyle the entire widget system at once.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class TaskColors {
  // Background
  static const skyDeep      = Color(0xFF010916);
  static const primary      = Color(0xFF00BFFF);
  static const primaryGlow  = Color(0xFF1E90FF);

  // Glass surfaces
  static const glass        = Color(0x0FFFFFFF);
  static const glassBorder  = Color(0x1FFFFFFF);

  // Text
  static const text1        = Color(0xFFEFF6FF);
  static const text2        = Color(0xFFB8D4F0);
  static const text3        = Color(0xFF6A9BC3);

  // Priority
  static const priorityHigh = Color(0xFFFF6B6B);
  static const priorityMed  = Color(0xFFFFD166);
  static const priorityLow  = Color(0xFF06D6A0);
  static const success      = Color(0xFF06D6A0);

  // Section accents
  static const morning      = Color(0xFFFFD166);
  static const afternoon    = Color(0xFF87CEEB);
  static const evening      = Color(0xFFB39DDB);
}

abstract final class TaskTextStyles {
  static TextStyle heading(double size) => GoogleFonts.outfit(
    fontSize: size, fontWeight: FontWeight.w800,
    color: TaskColors.text1, letterSpacing: -0.5,
  );

  static TextStyle label(double size, {Color? color}) => GoogleFonts.outfit(
    fontSize: size, fontWeight: FontWeight.w600,
    color: color ?? TaskColors.text1,
  );

  static TextStyle body(double size, {Color? color}) => GoogleFonts.dmSans(
    fontSize: size, fontWeight: FontWeight.w400,
    color: color ?? TaskColors.text2,
  );

  static TextStyle mono(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w600,
        color: color ?? TaskColors.primary,
        letterSpacing: 0.2,
      );
}

abstract final class TaskDecorations {
  static BoxDecoration glassCard({BorderRadius? radius}) => BoxDecoration(
    color: TaskColors.glass,
    borderRadius: radius ?? BorderRadius.circular(20),
    border: Border.all(color: TaskColors.glassBorder, width: 1),
  );

  static BoxDecoration pill({required Color color}) => BoxDecoration(
    color: color.withOpacity(0.10),
    borderRadius: BorderRadius.circular(100),
    border: Border.all(color: color.withOpacity(0.20), width: 1),
  );
}
