import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_decorations.dart';

/// SceneSplit design system — modern minimal.
/// Brand colors picked from the logo, generous white space, rounded cards.
abstract class AppColors {
  static const primary = Color(0xFF00B5B2);
  static const primaryDark = Color(0xFF008B89);
  static const primarySoft = Color(0xFFCCF4F3);

  static const secondary = Color(0xFF7856E6);
  static const secondaryDark = Color(0xFF5B3BC4);
  static const secondarySoft = Color(0xFFE7DFFC);

  static const logoBackground = Color(0xFF0A1334);

  static const background = Color(0xFFFAFAF9);
  static const surface = Colors.white;

  static const backgroundDark = Color(0xFF0D1117);
  static const surfaceDark = Color(0xFF161B22);
  static const borderDark = Color(0xFF30363D);

  static const textPrimary = Color(0xFF1C1917);
  static const textSecondary = Color(0xFF78716C);
  static const textPrimaryDark = Color(0xFFF0F6FC);
  static const textSecondaryDark = Color(0xFF8B949E);

  static const positive = Color(0xFF16A34A);
  static const negative = Color(0xFFDC2626);
  static const border = Color(0xFFE7E5E4);

  static const avatarColors = [
    Color(0xFF00B5B2),
    Color(0xFF7856E6),
    Color(0xFFDB2777),
    Color(0xFFD97706),
    Color(0xFF2563EB),
    Color(0xFF059669),
    Color(0xFFDC2626),
    Color(0xFF9333EA),
  ];
}

abstract class AppTheme {
  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final textTheme = GoogleFonts.interTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );

    final scaffoldBg = isDark ? AppColors.backgroundDark : AppColors.background;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: surfaceColor,
        error: AppColors.negative,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
      ),
      textTheme: textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: isDark ? 0 : 2,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: borderColor),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(color: textSecondary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.borderDark : AppColors.textPrimary,
        contentTextStyle: GoogleFonts.inter(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
