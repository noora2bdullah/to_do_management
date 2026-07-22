import 'package:flutter/material.dart';

abstract final class AppTextStyle {
  static const fontFamily = 'Gilroy';
  static const fontFamilyFallback = ['Tajawal', 'OpenSans'];

  static TextStyle custom(double size, FontWeight weight, {Color? color}) {
    return _textStyle(size, weight, color: color);
  }

  static BoxDecoration raisedSurfaceDecoration(
    ColorScheme colorScheme, {
    Color? tintColor,
    Color? borderColor,
    double radius = 8,
    bool prominent = false,
  }) {
    return BoxDecoration(
      gradient: surfaceGradient(colorScheme, tintColor: tintColor),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? surfaceBorderColor(colorScheme)),
      boxShadow: surfaceShadows(
        colorScheme,
        tintColor: tintColor,
        prominent: prominent,
      ),
    );
  }

  static BoxDecoration raisedTintDecoration(
    ColorScheme colorScheme,
    Color color, {
    double radius = 8,
    bool prominent = false,
  }) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final baseColor = isDark
        ? colorScheme.surfaceContainerHighest
        : colorScheme.surfaceContainerHigh;
    final tintAlpha = isDark ? 0.2 : 0.28;
    final endTintAlpha = isDark ? 0.1 : 0.16;

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.alphaBlend(
            Colors.white.withValues(alpha: isDark ? 0.05 : 0.62),
            Color.alphaBlend(color.withValues(alpha: tintAlpha), baseColor),
          ),
          Color.alphaBlend(
            color.withValues(alpha: endTintAlpha),
            isDark ? baseColor : colorScheme.surfaceContainerLow,
          ),
        ],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: color.withValues(alpha: isDark ? 0.2 : 0.24)),
      boxShadow: tintedShadows(colorScheme, color, prominent: prominent),
    );
  }

  static LinearGradient surfaceGradient(
    ColorScheme colorScheme, {
    Color? tintColor,
  }) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final baseColor = colorScheme.surfaceContainerLowest;
    final tint = tintColor ?? colorScheme.primary;

    if (!isDark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.alphaBlend(tint.withValues(alpha: 0.018), Colors.white),
          Color.alphaBlend(tint.withValues(alpha: 0.028), baseColor),
          Color.alphaBlend(
            tint.withValues(alpha: 0.085),
            colorScheme.surfaceContainerLow,
          ),
        ],
        stops: const [0, 0.56, 1],
      );
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.alphaBlend(
          Colors.white.withValues(alpha: isDark ? 0.04 : 0.72),
          baseColor,
        ),
        baseColor,
        Color.alphaBlend(tint.withValues(alpha: 0.12), baseColor),
      ],
      stops: const [0, 0.58, 1],
    );
  }

  static Color surfaceBorderColor(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    if (isDark) {
      return colorScheme.outlineVariant.withValues(alpha: 0.36);
    }

    return Color.alphaBlend(
      colorScheme.primary.withValues(alpha: 0.16),
      colorScheme.outlineVariant,
    ).withValues(alpha: 0.82);
  }

  static List<BoxShadow> surfaceShadows(
    ColorScheme colorScheme, {
    Color? tintColor,
    bool prominent = false,
  }) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final tint = tintColor ?? colorScheme.primary;

    if (!isDark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: prominent ? 0.13 : 0.08),
          blurRadius: prominent ? 28 : 18,
          offset: Offset(0, prominent ? 16 : 10),
          spreadRadius: prominent ? -11 : -8,
        ),
        BoxShadow(
          color: tint.withValues(alpha: prominent ? 0.18 : 0.12),
          blurRadius: prominent ? 38 : 26,
          offset: Offset(0, prominent ? 18 : 12),
          spreadRadius: prominent ? -18 : -14,
        ),
      ];
    }

    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: prominent ? 0.48 : 0.34),
        blurRadius: prominent ? 28 : 18,
        offset: Offset(0, prominent ? 16 : 10),
        spreadRadius: prominent ? -9 : -7,
      ),
      BoxShadow(
        color: tint.withValues(alpha: prominent ? 0.2 : 0.14),
        blurRadius: prominent ? 36 : 24,
        offset: Offset(0, prominent ? 18 : 12),
        spreadRadius: prominent ? -17 : -14,
      ),
    ];
  }

  static List<BoxShadow> tintedShadows(
    ColorScheme colorScheme,
    Color color, {
    bool prominent = false,
  }) {
    final isDark = colorScheme.brightness == Brightness.dark;

    if (!isDark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: prominent ? 0.08 : 0.05),
          blurRadius: prominent ? 18 : 12,
          offset: Offset(0, prominent ? 10 : 7),
          spreadRadius: prominent ? -8 : -6,
        ),
        BoxShadow(
          color: color.withValues(alpha: prominent ? 0.22 : 0.15),
          blurRadius: prominent ? 25 : 17,
          offset: Offset(0, prominent ? 12 : 8),
          spreadRadius: prominent ? -10 : -8,
        ),
      ];
    }

    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: prominent ? 0.36 : 0.26),
        blurRadius: prominent ? 18 : 12,
        offset: Offset(0, prominent ? 10 : 7),
        spreadRadius: prominent ? -8 : -6,
      ),
      BoxShadow(
        color: color.withValues(alpha: prominent ? 0.3 : 0.22),
        blurRadius: prominent ? 24 : 16,
        offset: Offset(0, prominent ? 12 : 8),
        spreadRadius: prominent ? -10 : -8,
      ),
    ];
  }

  static TextTheme textTheme(Color color) {
    return TextTheme(
      displayLarge: style36Black.copyWith(color: color),
      displayMedium: style32Black.copyWith(color: color),
      displaySmall: style28Black.copyWith(color: color),
      headlineLarge: style32Bold.copyWith(color: color),
      headlineMedium: style28Bold.copyWith(color: color),
      headlineSmall: style24Bold.copyWith(color: color),
      titleLarge: style20Bold.copyWith(color: color),
      titleMedium: style16Bold.copyWith(color: color),
      titleSmall: style14Bold.copyWith(color: color),
      bodyLarge: style16Regular.copyWith(color: color),
      bodyMedium: style14Regular.copyWith(color: color),
      bodySmall: style12Regular.copyWith(color: color),
      labelLarge: style14Bold.copyWith(color: color),
      labelMedium: style12Bold.copyWith(color: color),
      labelSmall: style10Bold.copyWith(color: color),
    );
  }

  static TextStyle _textStyle(double size, FontWeight weight, {Color? color}) {
    return TextStyle(
      color: color,
      fontSize: size,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontWeight: weight,
      letterSpacing: 0,
    );
  }

  static TextStyle get style32ExtraLight => _textStyle(32, FontWeight.w200);

  static TextStyle get style28ExtraLight => _textStyle(28, FontWeight.w200);

  static TextStyle get style24ExtraLight => _textStyle(24, FontWeight.w200);

  static TextStyle get style18ExtraLight => _textStyle(18, FontWeight.w200);

  static TextStyle get style16ExtraLight => _textStyle(16, FontWeight.w200);

  static TextStyle get style14ExtraLight => _textStyle(14, FontWeight.w200);

  static TextStyle get style13ExtraLight => _textStyle(13, FontWeight.w200);

  static TextStyle get style10ExtraLight => _textStyle(10, FontWeight.w200);

  static TextStyle get style32Light => _textStyle(32, FontWeight.w300);

  static TextStyle get style28Light => _textStyle(28, FontWeight.w300);

  static TextStyle get style24Light => _textStyle(24, FontWeight.w300);

  static TextStyle get style18Light => _textStyle(18, FontWeight.w300);

  static TextStyle get style16Light => _textStyle(16, FontWeight.w300);

  static TextStyle get style14Light => _textStyle(14, FontWeight.w300);

  static TextStyle get style13Light => _textStyle(13, FontWeight.w300);

  static TextStyle get style10Light => _textStyle(10, FontWeight.w300);

  static TextStyle get style32Regular => _textStyle(32, FontWeight.w400);

  static TextStyle get style28Regular => _textStyle(28, FontWeight.w400);

  static TextStyle get style24Regular => _textStyle(24, FontWeight.w400);

  static TextStyle get style18Regular => _textStyle(18, FontWeight.w400);

  static TextStyle get style16Regular => _textStyle(16, FontWeight.w400);

  static TextStyle get style14Regular => _textStyle(14, FontWeight.w400);

  static TextStyle get style13Regular => _textStyle(13, FontWeight.w400);

  static TextStyle get style12Regular => _textStyle(12, FontWeight.w400);

  static TextStyle get style10Regular => _textStyle(10, FontWeight.w400);

  static TextStyle get style32Medium => _textStyle(32, FontWeight.w500);

  static TextStyle get style28Medium => _textStyle(28, FontWeight.w500);

  static TextStyle get style24Medium => _textStyle(24, FontWeight.w500);

  static TextStyle get style18Medium => _textStyle(18, FontWeight.w500);

  static TextStyle get style16Medium => _textStyle(16, FontWeight.w500);

  static TextStyle get style15Medium => _textStyle(15, FontWeight.w500);

  static TextStyle get style14Medium => _textStyle(14, FontWeight.w500);

  static TextStyle get style13Medium => _textStyle(13, FontWeight.w500);

  static TextStyle get style12Medium => _textStyle(12, FontWeight.w500);

  static TextStyle get style10Medium => _textStyle(10, FontWeight.w500);

  static TextStyle get style32SemiBold => _textStyle(32, FontWeight.w600);

  static TextStyle get style28SemiBold => _textStyle(28, FontWeight.w600);

  static TextStyle get style24SemiBold => _textStyle(24, FontWeight.w600);

  static TextStyle get style18SemiBold => _textStyle(18, FontWeight.w600);

  static TextStyle get style16SemiBold => _textStyle(16, FontWeight.w600);

  static TextStyle get style14SemiBold => _textStyle(14, FontWeight.w600);

  static TextStyle get style13SemiBold => _textStyle(13, FontWeight.w600);

  static TextStyle get style12SemiBold => _textStyle(12, FontWeight.w600);

  static TextStyle get style10SemiBold => _textStyle(10, FontWeight.w600);

  static TextStyle get style36Bold => _textStyle(36, FontWeight.w700);

  static TextStyle get style32Bold => _textStyle(32, FontWeight.w700);

  static TextStyle get style28Bold => _textStyle(28, FontWeight.w700);

  static TextStyle get style24Bold => _textStyle(24, FontWeight.w700);

  static TextStyle get style22Bold => _textStyle(22, FontWeight.w700);

  static TextStyle get style20Bold => _textStyle(20, FontWeight.w700);

  static TextStyle get style18Bold => _textStyle(18, FontWeight.w700);

  static TextStyle get style16Bold => _textStyle(16, FontWeight.w700);

  static TextStyle get style15Bold => _textStyle(15, FontWeight.w700);

  static TextStyle get style14Bold => _textStyle(14, FontWeight.w700);

  static TextStyle get style13Bold => _textStyle(13, FontWeight.w700);

  static TextStyle get style12Bold => _textStyle(12, FontWeight.w700);

  static TextStyle get style11Bold => _textStyle(11, FontWeight.w700);

  static TextStyle get style10Bold => _textStyle(10, FontWeight.w700);

  static TextStyle get style32ExtraBold => _textStyle(32, FontWeight.w800);

  static TextStyle get style28ExtraBold => _textStyle(28, FontWeight.w800);

  static TextStyle get style24ExtraBold => _textStyle(24, FontWeight.w800);

  static TextStyle get style18ExtraBold => _textStyle(18, FontWeight.w800);

  static TextStyle get style16ExtraBold => _textStyle(16, FontWeight.w800);

  static TextStyle get style14ExtraBold => _textStyle(14, FontWeight.w800);

  static TextStyle get style13ExtraBold => _textStyle(13, FontWeight.w800);

  static TextStyle get style12ExtraBold => _textStyle(12, FontWeight.w800);

  static TextStyle get style10ExtraBold => _textStyle(10, FontWeight.w800);

  static TextStyle get style36Black => _textStyle(36, FontWeight.w900);

  static TextStyle get style32Black => _textStyle(32, FontWeight.w900);

  static TextStyle get style28Black => _textStyle(28, FontWeight.w900);

  static TextStyle get style24Black => _textStyle(24, FontWeight.w900);

  static TextStyle get style22Black => _textStyle(22, FontWeight.w900);

  static TextStyle get style20Black => _textStyle(20, FontWeight.w900);

  static TextStyle get style18Black => _textStyle(18, FontWeight.w900);

  static TextStyle get style16Black => _textStyle(16, FontWeight.w900);

  static TextStyle get style14Black => _textStyle(14, FontWeight.w900);

  static TextStyle get style13Black => _textStyle(13, FontWeight.w900);

  static TextStyle get style10Black => _textStyle(10, FontWeight.w900);
}
