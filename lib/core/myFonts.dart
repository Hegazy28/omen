import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omen/core/myColors.dart';

class Myfonts {
  Myfonts._();

  // ── Font Families ─────────────────────────
  // Display / Headers  → Outfit  (geometric, modern, clean)
  // Body / UI          → DM Sans (neutral, highly legible)
  // Monospace / Stats  → JetBrains Mono (great for numbers/time)

  // ── Display — Hero titles, greeting ──────
  static TextStyle get displayLarge => GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: Mycolors.textPrimary,
        letterSpacing: -0.5,
        height: 1.1,
      );

  static TextStyle get displayMedium => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: Mycolors.textPrimary,
        letterSpacing: -0.3,
        height: 1.15,
      );

  static TextStyle get displaySmall => GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Mycolors.textPrimary,
        letterSpacing: -0.2,
        height: 1.2,
      );

  // ── Headlines — Section titles ────────────
  static TextStyle get headlineLarge => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Mycolors.textPrimary,
        letterSpacing: 0.0,
      );

  static TextStyle get headlineMedium => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Mycolors.textPrimary,
        letterSpacing: 0.0,
      );

  static TextStyle get headlineSmall => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Mycolors.textSecondary,
      );

  // ── Body — Main content text ──────────────
  static TextStyle get bodyLarge => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Mycolors.textPrimary,
        height: 1.55,
      );

  static TextStyle get bodyMedium => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Mycolors.textSecondary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Mycolors.textMuted,
        height: 1.45,
      );

  // ── Labels — Tags, chips, badges ──────────
  static TextStyle get labelLarge => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Mycolors.textPrimary,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Mycolors.textSecondary,
        letterSpacing: 0.2,
      );

  static TextStyle get labelSmall => GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: Mycolors.textMuted,
        letterSpacing: 0.4,
      );

  // ── Mono — Time, stats, streaks, numbers ──
  static TextStyle get monoLarge => GoogleFonts.jetBrainsMono(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Mycolors.primary,
        letterSpacing: -0.5,
      );

  static TextStyle get monoMedium => GoogleFonts.jetBrainsMono(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Mycolors.primary,
        letterSpacing: 0.0,
      );

  static TextStyle get monoSmall => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Mycolors.textSecondary,
        letterSpacing: 0.2,
      );

  // ── Caption — Hints, subtitles ────────────
  static TextStyle get caption => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: Mycolors.textDisabled,
        letterSpacing: 0.3,
      );

  // ── Button ────────────────────────────────
  static TextStyle get button => GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Mycolors.textPrimary,
        letterSpacing: 0.3,
      );

  static TextStyle get buttonSmall => GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Mycolors.textPrimary,
        letterSpacing: 0.2,
      );

  // ── TextTheme — plug into ThemeData ───────
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );
}
