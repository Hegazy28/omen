// lib/features/quran/widgets/quran_theme.dart
//
// Gold + deep black palette for the Quran screen.
// Intentionally separate from tasks_theme / matches_theme.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class QuranColors {
  // Backgrounds
  static const bg         = Color(0xFF06080F);
  static const panel      = Color(0x0AFFFFFF);
  static const panelHover = Color(0x12FFFFFF);
  static const border     = Color(0x14FFFFFF);
  static const border2    = Color(0x0CFFFFFF);

  // Gold palette
  static const gold       = Color(0xFFC9A84C);
  static const gold2      = Color(0xFFE8C97A);
  static const gold3      = Color(0xFFF5E6B8);
  static const goldDim    = Color(0x26C9A84C);
  static const goldGlow   = Color(0x14C9A84C);

  // Emerald accent
  static const emerald    = Color(0xFF2DD4A0);
  static const emeraldDim = Color(0x1F2DD4A0);

  // Text
  static const text1      = Color(0xFFF0EAD6);
  static const text2      = Color(0xFFC5B99A);
  static const text3      = Color(0xFF7A6E5A);
  static const text4      = Color(0xFF3D3428);
}

abstract final class QuranTextStyles {
  /// Heading — Cairo bold
  static TextStyle heading(double size) => GoogleFonts.cairo(
    fontSize: size, fontWeight: FontWeight.w800,
    color: QuranColors.gold2, letterSpacing: 0.3,
  );

  /// UI label — Cairo semibold
  static TextStyle label(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.cairo(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w600,
        color: color ?? QuranColors.text1,
      );

  /// Body — Cairo regular
  static TextStyle body(double size, {Color? color}) => GoogleFonts.cairo(
    fontSize: size, fontWeight: FontWeight.w400,
    color: color ?? QuranColors.text2,
  );

  /// Quran Arabic text — Amiri Quran
  static const TextStyle quranText = TextStyle(
    fontFamily: 'AmiriQuran',
    fontSize: 20, height: 2.0,
    color: QuranColors.text1,
  );

  /// Surah name display — Amiri
  static const TextStyle surahName = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 18, height: 1.4,
    color: QuranColors.text1,
    fontWeight: FontWeight.w400,
  );

  /// Monospace numbers
  static TextStyle mono(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.cairo(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w700,
        color: color ?? QuranColors.gold,
      );
}

abstract final class QuranDecorations {
  static BoxDecoration panel({Color? border, BorderRadius? radius}) =>
      BoxDecoration(
        color: QuranColors.panel,
        borderRadius: radius ?? BorderRadius.circular(16),
        border: Border.all(
          color: border ?? QuranColors.border,
          width: 1,
        ),
      );

  static BoxDecoration goldCard({BorderRadius? radius}) => BoxDecoration(
    color: QuranColors.goldDim,
    borderRadius: radius ?? BorderRadius.circular(12),
    border: Border.all(
      color: QuranColors.gold.withOpacity(0.20),
      width: 1,
    ),
  );

  static BoxDecoration emeraldCard({BorderRadius? radius}) => BoxDecoration(
    color: QuranColors.emeraldDim,
    borderRadius: radius ?? BorderRadius.circular(12),
    border: Border.all(
      color: QuranColors.emerald.withOpacity(0.20),
      width: 1,
    ),
  );

  static BoxDecoration pill({required Color color}) => BoxDecoration(
    color: color.withOpacity(0.12),
    borderRadius: BorderRadius.circular(100),
    border: Border.all(color: color.withOpacity(0.22), width: 1),
  );
}
