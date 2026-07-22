import 'package:flutter/material.dart';

class AppIconAsset extends StatelessWidget {
  const AppIconAsset({required this.size, super.key});

  static const _lightAsset = 'assets/icons/app_ic_light.png';
  static const _darkAsset = 'assets/icons/app_ic_dark.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).colorScheme.brightness == Brightness.dark;

    return SizedBox.square(
      dimension: size,
      child: Image.asset(
        isDark ? _darkAsset : _lightAsset,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        semanticLabel: 'To-Do app icon',
      ),
    );
  }
}
