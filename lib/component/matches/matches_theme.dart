// lib/features/matches/widgets/matches_theme.dart
//
// Extends the FrostFlow palette with match-specific colors and helpers.
// Kept separate so it doesn't collide with tasks_theme.dart.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omen/component/matches/match_model.dart';

abstract final class MatchColors {
  // ── Base (same as tasks) ─────────────────────────────
  static const skyDeep = Color(0xFF010916);
  static const primary = Color(0xFF00BFFF);
  static const primaryGlow = Color(0xFF1E90FF);
  static const glass = Color(0x0FFFFFFF);
  static const glassBorder = Color(0x1FFFFFFF);
  static const text1 = Color(0xFFEFF6FF);
  static const text2 = Color(0xFFB8D4F0);
  static const text3 = Color(0xFF6A9BC3);
  static const success = Color(0xFF06D6A0);

  // ── Match-specific ───────────────────────────────────
  static const live = Color(0xFFFF4757); // red pulse
  static const liveGlow = Color(0xFFFF6B81);
  static const win = Color(0xFF06D6A0); // green
  static const draw = Color(0xFFFFD166); // amber
  static const loss = Color(0xFFFF6B6B); // red

  // Competition accent colours
  static const laLiga = Color(0xFFFF6B35);
  static const ucl = Color(0xFF4FC3F7);
  static const copa = Color(0xFFAB47BC);
  static const supercopa = Color(0xFFFFD166);
  static const friendly = Color(0xFF6A9BC3);

  // Barca palette
  static const barcaBlue = Color(0xFF004D98);
  static const barcaRed = Color(0xFFA50044);
}

abstract final class MatchTextStyles {
  static TextStyle heading(double size) => GoogleFonts.outfit(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: MatchColors.text1,
        letterSpacing: -0.5,
      );

  static TextStyle label(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.outfit(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w600,
        color: color ?? MatchColors.text1,
      );

  static TextStyle body(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w400,
        color: color ?? MatchColors.text2,
      );

  static TextStyle mono(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w600,
        color: color ?? MatchColors.primary,
        letterSpacing: 0.2,
      );

  static TextStyle score(double size) => GoogleFonts.outfit(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: MatchColors.text1,
        letterSpacing: -1,
      );
}

abstract final class MatchDecorations {
  static BoxDecoration glassCard({
    BorderRadius? radius,
    Color? border,
    List<BoxShadow>? shadows,
  }) =>
      BoxDecoration(
        color: MatchColors.glass,
        borderRadius: radius ?? BorderRadius.circular(20),
        border: Border.all(color: border ?? MatchColors.glassBorder, width: 1),
        boxShadow: shadows,
      );

  static BoxDecoration pill({required Color color}) => BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      );
}

// ── Helpers ───────────────────────────────────────────────

extension MatchCompetitionX on MatchCompetition {
  String get label => switch (this) {
        MatchCompetition.laLiga => 'La Liga',
        MatchCompetition.championsLeague => 'UEFA Champions League',
        MatchCompetition.copaDelRey => 'Copa del Rey',
        MatchCompetition.supercopa => 'Supercopa',
        MatchCompetition.friendly => 'Friendly',
      };

  String get shortLabel => switch (this) {
        MatchCompetition.laLiga => 'La Liga',
        MatchCompetition.championsLeague => 'UCL',
        MatchCompetition.copaDelRey => 'Copa',
        MatchCompetition.supercopa => 'Supercopa',
        MatchCompetition.friendly => 'Friendly',
      };

  Color get color => switch (this) {
        MatchCompetition.laLiga => MatchColors.laLiga,
        MatchCompetition.championsLeague => MatchColors.ucl,
        MatchCompetition.copaDelRey => MatchColors.copa,
        MatchCompetition.supercopa => MatchColors.supercopa,
        MatchCompetition.friendly => MatchColors.friendly,
      };
}
