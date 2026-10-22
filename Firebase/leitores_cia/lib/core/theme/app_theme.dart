import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Tema oficial do aplicativo Leitores & Cia. (Book Nook),
/// em conformidade com as especificações estéticas de DESIGN.md.
abstract class AppTheme {
  static ThemeData get lightTheme {
    final TextTheme textTheme;

    // Se o download de fontes em runtime estiver desativado (ex.: em testes de widget),
    // utiliza TextStyle nativo com os mesmos nomes de família para evitar exceções de rede.
    if (!GoogleFonts.config.allowRuntimeFetching) {
      textTheme = const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Literata',
          fontSize: 56,
          height: 1.14,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Literata',
          fontSize: 45,
          height: 1.15,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Literata',
          fontSize: 32,
          height: 1.25,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Literata',
          fontSize: 28,
          height: 1.28,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Literata',
          fontSize: 20,
          height: 1.4,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 20,
          height: 1.4,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 16,
          height: 1.5,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 14,
          height: 1.42,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 16,
          height: 1.6,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurface,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 14,
          height: 1.45,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurface,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 12,
          height: 1.33,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurfaceVariant,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 14,
          height: 1.42,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 12,
          height: 1.33,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 11,
          height: 1.27,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurfaceVariant,
        ),
      );
    } else {
      textTheme = TextTheme(
        displayLarge: GoogleFonts.literata(
          fontSize: 56,
          height: 1.14,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.02 * 56,
          color: AppColors.onSurface,
        ),
        displayMedium: GoogleFonts.literata(
          fontSize: 45,
          height: 1.15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.015 * 45,
          color: AppColors.onSurface,
        ),
        headlineLarge: GoogleFonts.literata(
          fontSize: 32,
          height: 1.25,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.01 * 32,
          color: AppColors.onSurface,
        ),
        headlineMedium: GoogleFonts.literata(
          fontSize: 28, // headline-lg-mobile no DESIGN
          height: 1.28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.01 * 28,
          color: AppColors.onSurface,
        ),
        headlineSmall: GoogleFonts.literata(
          fontSize: 20,
          height: 1.4,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          height: 1.4,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          height: 1.5,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        titleSmall: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          height: 1.42,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          height: 1.6,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurface,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          height: 1.45,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurface,
        ),
        bodySmall: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          height: 1.33,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurfaceVariant,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          height: 1.42,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.01 * 14,
          color: AppColors.onSurface,
        ),
        labelMedium: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          height: 1.33,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.02 * 12,
          color: AppColors.onSurface,
        ),
        labelSmall: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          height: 1.27,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.03 * 11,
          color: AppColors.onSurfaceVariant,
        ),
      );
    }

    final colorScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      primaryFixed: AppColors.primaryFixed,
      primaryFixedDim: AppColors.primaryFixedDim,
      onPrimaryFixed: AppColors.onPrimaryFixed,
      onPrimaryFixedVariant: AppColors.onPrimaryFixedVariant,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      secondaryFixed: AppColors.secondaryFixed,
      secondaryFixedDim: AppColors.secondaryFixedDim,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      tertiaryFixed: AppColors.tertiaryFixed,
      tertiaryFixedDim: AppColors.tertiaryFixedDim,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.config.allowRuntimeFetching
            ? GoogleFonts.literata(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              )
            : const TextStyle(
                fontFamily: 'Literata',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
        iconTheme: const IconThemeData(color: AppColors.secondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.config.allowRuntimeFetching
            ? GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.outline,
              )
            : const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                color: AppColors.outline,
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.config.allowRuntimeFetching
              ? GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                )
              : const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
          elevation: 1,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
