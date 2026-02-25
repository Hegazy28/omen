import 'package:flutter/material.dart';
import 'package:omen/core/myColors.dart';
import 'package:omen/core/myFonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Mycolors.skyDeep,
        textTheme: Myfonts.textTheme,
        colorScheme: const ColorScheme.dark(
          primary: Mycolors.primary,
          secondary: Mycolors.aurora1,
          surface: Mycolors.skyMid,
          error: Mycolors.error,
          onPrimary: Mycolors.skyDeep,
          onSecondary: Mycolors.textPrimary,
          onSurface: Mycolors.textPrimary,
        ),
        cardTheme: CardThemeData(
          color: Mycolors.glassWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Mycolors.glassBorder, width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Mycolors.primary,
            foregroundColor: Mycolors.skyDeep,
            textStyle: Myfonts.button,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Mycolors.glassWhite,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Mycolors.glassBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Mycolors.glassBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Mycolors.primary, width: 1.5),
          ),
          hintStyle: Myfonts.bodyMedium,
          labelStyle: Myfonts.labelMedium,
        ),
        dividerColor: Mycolors.glassBorder,
        iconTheme: const IconThemeData(color: Mycolors.textSecondary, size: 22),
      );
}
