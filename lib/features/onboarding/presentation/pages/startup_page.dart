import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_style.dart';
import '../../../../core/widgets/app_icon_asset.dart';

class StartupPage extends StatelessWidget {
  const StartupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(color: colorScheme.surface),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.88, end: 1),
            duration: const Duration(milliseconds: 760),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) {
              return Opacity(
                opacity: scale.clamp(0.0, 1.0),
                child: Transform.scale(scale: scale, child: child),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppIconAsset(size: 92),
                const SizedBox(height: 22),
                Text(
                  'To-Do',
                  style: AppTextStyle.style32Black.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Work organized, beautifully.',
                  style: AppTextStyle.style16Medium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: colorScheme.secondary,
                    backgroundColor: colorScheme.secondary.withValues(
                      alpha: 0.14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
