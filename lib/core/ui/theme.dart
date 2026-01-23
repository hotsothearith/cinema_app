import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dark, modern cinema theme (works on Web + mobile).
ThemeData buildTheme(Brightness brightness) {
  final seed = const Color(0xFFFF2D55); // modern pink/red
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorSchemeSeed: seed,
  );

  final textTheme = GoogleFonts.interTextTheme(base.textTheme);

  // Keep theme compatible across Flutter versions (avoid CardThemeData vs CardTheme issues)
  return base.copyWith(
    textTheme: textTheme,
    scaffoldBackgroundColor: brightness == Brightness.dark ? const Color(0xFF0B0B10) : null,
    appBarTheme: base.appBarTheme.copyWith(
      centerTitle: true,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: brightness == Brightness.dark
          ? const Color(0xFF141421).withOpacity(0.9)
          : base.colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
  );
}
