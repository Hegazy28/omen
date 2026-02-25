import 'package:flutter/material.dart';

class Mycolors {
  Mycolors._();

  // ── Sky / Background ──────────────────────
  static const Color skyDeep = Color(0xFF010916); // darkest top
  static const Color skyMid = Color(0xFF041228); // mid sky
  static const Color skyBase = Color(0xFF0A2248); // base sky
  static const Color skyLight = Color(0xFF1A4080); // horizon glow
  static const Color transparent = Color(0x00FFFFFF); // transparent
  // ── Primary Accent — Ice Blue ─────────────
  static const Color primary = Color(0xFF00BFFF); // deep sky blue
  static const Color primaryLight = Color(0xFF87CEEB); // sky blue
  static const Color primaryGlow = Color(0xFF1E90FF); // dodger blue
  static const Color primarySubtle = Color(0xFF4FC3F7); // light blue

  // ── Secondary Accent — Aurora ────────────
  static const Color aurora1 = Color(0xFF4169E1); // royal blue
  static const Color aurora2 = Color(0xFF00B4FF); // aurora teal-blue
  static const Color aurora3 = Color(0xFFADD8E6); // ice shimmer

  // ── Glass / Cards ────────────────────────
  static const Color glassWhite = Color(0x14FFFFFF); // white 8%
  static const Color glassBorder = Color(0x26FFFFFF); // white 15%
  static const Color glassHighlight = Color(0x0FFFFFFF); // white 6%
  static const Color glassDeep = Color(0x1A0A2248); // dark glass

  // ── Text ─────────────────────────────────
  static const Color textPrimary = Color(0xFFEFF6FF); // near white
  static const Color textSecondary = Color(0xFFB8D4F0); // icy blue-white
  static const Color textMuted = Color(0xFF6A9BC3); // muted blue
  static const Color textDisabled = Color(0xFF3A5F82); // dim

  // ── Task Priority Dots ───────────────────
  static const Color priorityHigh = Color(0xFFFF6B6B); // soft red
  static const Color priorityMedium = Color(0xFFFFD166); // warm yellow
  static const Color priorityLow = Color(0xFF06D6A0); // mint green

  // ── States ───────────────────────────────
  static const Color success = Color(0xFF06D6A0); // mint
  static const Color warning = Color(0xFFFFD166); // amber
  static const Color error = Color(0xFFFF6B6B); // coral
  static const Color info = Color(0xFF00BFFF); // ice blue

  // ── Gradients ────────────────────────────
  static const LinearGradient skyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [skyDeep, skyMid, skyBase, skyLight],
    stops: [0.0, 0.3, 0.65, 1.0],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGlow, primary, aurora2],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [glassWhite, glassHighlight],
  );

  static const LinearGradient frostGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A6FA8), Color(0xFF0D2B5E), Color(0xFF061228)],
  );

  // ── Shadows ──────────────────────────────
  static List<BoxShadow> glowShadow({double intensity = 1.0}) => [
        BoxShadow(
          color: primary.withOpacity(0.25 * intensity),
          blurRadius: 20 * intensity,
          spreadRadius: 2 * intensity,
        ),
        BoxShadow(
          color: primaryGlow.withOpacity(0.10 * intensity),
          blurRadius: 40 * intensity,
          spreadRadius: 4 * intensity,
        ),
      ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: skyDeep.withOpacity(0.5),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: primary.withOpacity(0.05),
      blurRadius: 8,
      offset: const Offset(0, 1),
    ),
  ];
}
