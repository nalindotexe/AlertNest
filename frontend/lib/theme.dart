import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Color tokens ────────────────────────────────────────────────────────────
const Color kBgDeep      = Color(0xFF060B18);
const Color kBgCard      = Color(0xFF0D1526);
const Color kBgCardAlt   = Color(0xFF111E34);
const Color kAccentCyan  = Color(0xFF00E5FF);
const Color kAccentDim   = Color(0xFF007E8C);
const Color kSevHigh     = Color(0xFFFF3B5C);
const Color kSevMed      = Color(0xFFFF8C00);
const Color kSevLow      = Color(0xFF00E676);
const Color kTextPrimary = Color(0xFFE8F4FF);
const Color kTextSecond  = Color(0xFF607D9E);
const Color kDivider     = Color(0xFF1A2C47);

// ── Theme builder ────────────────────────────────────────────────────────────
ThemeData buildAlertNestTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: kBgDeep,
    cardColor: kBgCard,
    dividerColor: kDivider,
    colorScheme: const ColorScheme.dark(
      primary: kAccentCyan,
      secondary: kAccentDim,
      surface: kBgCard,
      onPrimary: kBgDeep,
      onSurface: kTextPrimary,
      onSecondary: kTextPrimary,
    ),
    textTheme: GoogleFonts.exo2TextTheme(base.textTheme).copyWith(
      bodyLarge:  GoogleFonts.exo2(color: kTextPrimary, fontSize: 14),
      bodyMedium: GoogleFonts.exo2(color: kTextPrimary, fontSize: 13),
      bodySmall:  GoogleFonts.exo2(color: kTextSecond,  fontSize: 11),
      labelLarge: GoogleFonts.exo2(
          color: kTextPrimary, fontSize: 13, fontWeight: FontWeight.w600),
      labelSmall: GoogleFonts.exo2(
          color: kTextSecond, fontSize: 10, letterSpacing: 1.2),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kBgCardAlt,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kAccentCyan, width: 1.5),
      ),
      hintStyle: GoogleFonts.exo2(color: kTextSecond, fontSize: 12),
      labelStyle: GoogleFonts.exo2(color: kTextSecond, fontSize: 12),
    ),
    dividerTheme: const DividerThemeData(color: kDivider, thickness: 1),
    cardTheme: CardThemeData(
      color: kBgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: kDivider),
      ),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(kAccentDim),
    ),
  );
}
