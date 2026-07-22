import 'package:flutter/material.dart';

import 'app_text_style.dart';

abstract final class AppTheme {
  static const _primaryLight = Color(0xFF551A50);
  static const _secondaryLight = Color(0xFFE85FA2);
  static const _tertiaryLight = Color(0xFF006A6F);
  static const _surfaceLight = Color(0xFFFFF7FA);
  static const _surfaceLightBright = Color(0xFFFFFBFD);
  static const _surfaceLightLowest = Color(0xFFFFFFFF);
  static const _surfaceLightLow = Color(0xFFFFF1F7);
  static const _surfaceLightBase = Color(0xFFFBEAF2);
  static const _surfaceLightHigh = Color(0xFFF5DEE9);
  static const _surfaceLightHighest = Color(0xFFEED2E0);
  static const _outlineLight = Color(0xFF8A6F82);
  static const _outlineVariantLight = Color(0xFFD7BECE);
  static const _onSurfaceLight = Color(0xFF241720);
  static const _onSurfaceVariantLight = Color(0xFF64535F);
  static const _primaryDark = Color(0xFFED6EA7);
  static const _secondaryDark = Color(0xFF471A47);
  static const _onDarkBrand = Color(0xFF111111);

  static ThemeData get light {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: _primaryLight,
          brightness: Brightness.light,
        ).copyWith(
          primary: _primaryLight,
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFFFD5EC),
          onPrimaryContainer: const Color(0xFF2F092D),
          secondary: _secondaryLight,
          onSecondary: _onDarkBrand,
          secondaryContainer: const Color(0xFFFFD8EA),
          onSecondaryContainer: const Color(0xFF3B0B2A),
          tertiary: _tertiaryLight,
          onTertiary: Colors.white,
          tertiaryContainer: const Color(0xFF8DF1F5),
          onTertiaryContainer: const Color(0xFF002022),
          surface: _surfaceLight,
          onSurface: _onSurfaceLight,
          surfaceBright: _surfaceLightBright,
          surfaceContainerLowest: _surfaceLightLowest,
          surfaceContainerLow: _surfaceLightLow,
          surfaceContainer: _surfaceLightBase,
          surfaceContainerHigh: _surfaceLightHigh,
          surfaceContainerHighest: _surfaceLightHighest,
          onSurfaceVariant: _onSurfaceVariantLight,
          outline: _outlineLight,
          outlineVariant: _outlineVariantLight,
          surfaceTint: _secondaryLight,
        );

    return _theme(colorScheme);
  }

  static ThemeData get dark {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: _primaryDark,
          brightness: Brightness.dark,
        ).copyWith(
          primary: _primaryDark,
          onPrimary: _onDarkBrand,
          secondary: _secondaryDark,
          onSecondary: Colors.white,
        );

    return _theme(colorScheme);
  }

  static ThemeData _theme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final inputFillColor = isDark
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.55)
        : Color.alphaBlend(
            colorScheme.primary.withValues(alpha: 0.035),
            colorScheme.surfaceContainerLow,
          );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStyle.fontFamily,
      fontFamilyFallback: AppTextStyle.fontFamilyFallback,
      colorScheme: colorScheme,
      textTheme: AppTextStyle.textTheme(colorScheme.onSurface),
      primaryTextTheme: AppTextStyle.textTheme(colorScheme.onPrimary),
      scaffoldBackgroundColor: colorScheme.surface,
      shadowColor: (isDark ? Colors.black : colorScheme.primary).withValues(
        alpha: isDark ? 0.46 : 0.16,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 6,
        shadowColor: (isDark ? Colors.black : colorScheme.primary).withValues(
          alpha: isDark ? 0.44 : 0.12,
        ),
        surfaceTintColor: colorScheme.primary.withValues(
          alpha: isDark ? 0.08 : 0.04,
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: AppTextStyle.style20Bold.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: isDark ? 3 : 4,
        color: colorScheme.surfaceContainerLowest,
        shadowColor: (isDark ? Colors.black : colorScheme.primary).withValues(
          alpha: isDark ? 0.38 : 0.14,
        ),
        surfaceTintColor: colorScheme.primary.withValues(
          alpha: isDark ? 0.05 : 0.03,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppTextStyle.surfaceBorderColor(colorScheme)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 8,
        focusElevation: 10,
        hoverElevation: 10,
        highlightElevation: 4,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        splashColor: colorScheme.secondary.withValues(alpha: 0.18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
            : colorScheme.surfaceContainerLow,
        selectedColor: colorScheme.secondaryContainer,
        labelStyle: AppTextStyle.style12Bold.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        secondaryLabelStyle: AppTextStyle.style12Bold.copyWith(
          color: colorScheme.onSecondaryContainer,
        ),
        side: BorderSide(color: AppTextStyle.surfaceBorderColor(colorScheme)),
        shadowColor: (isDark ? Colors.black : colorScheme.primary).withValues(
          alpha: isDark ? 0.28 : 0.1,
        ),
        selectedShadowColor: colorScheme.primary.withValues(
          alpha: isDark ? 0.24 : 0.18,
        ),
        elevation: 1,
        pressElevation: 2,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTextStyle.style14Bold,
          elevation: 2,
          shadowColor: colorScheme.primary.withValues(
            alpha: isDark ? 0.38 : 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTextStyle.style14Bold,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: AppTextStyle.style14Bold),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFillColor,
        hintStyle: AppTextStyle.style14Medium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        labelStyle: AppTextStyle.style14Medium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        floatingLabelStyle: AppTextStyle.style14Bold.copyWith(
          color: colorScheme.primary,
        ),
        errorStyle: AppTextStyle.style12Medium.copyWith(
          color: colorScheme.error,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
