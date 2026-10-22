import 'package:flutter/material.dart';

/// Design tokens de cores do projeto Leitores & Cia.
/// Extraídos diretamente da especificação oficial em DESIGN.md.
abstract class AppColors {
  // Primárias (Verde Sálvia Editorial)
  static const Color primary = Color(0xFF3E644A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF567D62);
  static const Color onPrimaryContainer = Color(0xFFF6FFF4);
  static const Color primaryFixed = Color(0xFFC2EDCB);
  static const Color primaryFixedDim = Color(0xFFA7D1B0);
  static const Color onPrimaryFixed = Color(0xFF00210F);
  static const Color onPrimaryFixedVariant = Color(0xFF294E36);

  // Secundárias (Tons Terrosos / Café)
  static const Color secondary = Color(0xFF6C5B51);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFF6DED1);
  static const Color onSecondaryContainer = Color(0xFF726157);
  static const Color secondaryFixed = Color(0xFFF6DED1);
  static const Color secondaryFixedDim = Color(0xFFD9C2B6);

  // Terciárias (Terracota Quente)
  static const Color tertiary = Color(0xFF8D4932);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFAB6148);
  static const Color onTertiaryContainer = Color(0xFFFFFBFF);
  static const Color tertiaryFixed = Color(0xFFFFDBD0);
  static const Color tertiaryFixedDim = Color(0xFFFFB59E);

  // Superfícies e Fundos (Papel Suave / Pergaminho)
  static const Color surface = Color(0xFFFCF9F4);
  static const Color onSurface = Color(0xFF1C1C19);
  static const Color background = Color(0xFFFCF9F4);
  static const Color onBackground = Color(0xFF1C1C19);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF6F3EE);
  static const Color surfaceContainer = Color(0xFFF0EDE9);
  static const Color surfaceContainerHigh = Color(0xFFEBE8E3);
  static const Color surfaceContainerHighest = Color(0xFFE5E2DD);
  static const Color surfaceVariant = Color(0xFFE5E2DD);
  static const Color onSurfaceVariant = Color(0xFF424942);

  // Contornos e Bordas
  static const Color outline = Color(0xFF727972);
  static const Color outlineVariant = Color(0xFFC1C8C0);

  // Erro e Alertas
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
}
