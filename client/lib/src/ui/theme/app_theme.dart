import 'package:flutter/material.dart';

abstract final class DarkTokens {
  static const bgBase = Color(0xFF0A0E14);
  static const bgPanel = Color(0xFF131A24);
  static const bgCard = Color(0xFF1C2530);
  static const goldPrimary = Color(0xFFC9A24B);
  static const goldBright = Color(0xFFE6C56A);
  static const goldDark = Color(0xFF8A6A2F);
  static const redAccent = Color(0xFF8B1A2B);
  static const redBright = Color(0xFFB3273D);
  static const cardFace = Color(0xFFF5EFE0);
  static const cardBack = Color(0xFF22303E);
  static const textPrimary = Color(0xFFEDE8DC);
  static const textSecondary = Color(0xFF9A927F);
  static const textDisabled = Color(0xFF5A5748);
  static const suitRed = Color(0xFFC0392B);
  static const suitBlack = Color(0xFF1C1C1C);
  static const infoBlue = Color(0xFF4A7BA6);

  static const fontSizeL1 = 40.0;
  static const fontSizeL2 = 32.0;
  static const fontSizeL3 = 24.0;
  static const fontSizeL4 = 18.0;
  static const fontSizeL5 = 14.0;
  static const fontSizeL6 = 12.0;

  static const radiusCard = 8.0;
  static const radiusButton = 8.0;
  static const radiusPanel = 12.0;
  static const radiusBadge = 999.0;

  static const spacingS1 = 4.0;
  static const spacingS2 = 8.0;
  static const spacingS3 = 12.0;
  static const spacingS4 = 16.0;
  static const spacingS5 = 24.0;
  static const spacingS6 = 32.0;

  static const cardAspectRatio = 62 / 88;
}

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    fontFamilyFallback: const ['NotoSansSC'],
    scaffoldBackgroundColor: DarkTokens.bgBase,
    colorScheme: const ColorScheme.dark(
      primary: DarkTokens.goldPrimary,
      onPrimary: DarkTokens.bgBase,
      secondary: DarkTokens.goldBright,
      onSecondary: DarkTokens.bgBase,
      error: DarkTokens.redBright,
      onError: DarkTokens.textPrimary,
      surface: DarkTokens.bgPanel,
      onSurface: DarkTokens.textPrimary,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: DarkTokens.textPrimary,
        fontSize: DarkTokens.fontSizeL2,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: TextStyle(
        color: DarkTokens.textPrimary,
        fontSize: DarkTokens.fontSizeL3,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: DarkTokens.textPrimary,
        fontSize: DarkTokens.fontSizeL4,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: DarkTokens.textPrimary,
        fontSize: DarkTokens.fontSizeL5,
      ),
      bodyMedium: TextStyle(
        color: DarkTokens.textSecondary,
        fontSize: DarkTokens.fontSizeL6,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: DarkTokens.bgBase,
      foregroundColor: DarkTokens.textPrimary,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DarkTokens.bgCard,
      labelStyle: const TextStyle(color: DarkTokens.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DarkTokens.radiusButton),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DarkTokens.radiusButton),
        borderSide: const BorderSide(color: DarkTokens.cardBack),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DarkTokens.radiusButton),
        borderSide: const BorderSide(color: DarkTokens.goldPrimary),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: DarkTokens.goldPrimary,
        foregroundColor: DarkTokens.bgBase,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DarkTokens.radiusButton),
        ),
      ),
    ),
  );
}
