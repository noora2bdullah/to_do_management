import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_style.dart';

class TaskStatePanel extends StatelessWidget {
  const TaskStatePanel({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.isLoading = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: AppTextStyle.raisedSurfaceDecoration(
        colorScheme,
        tintColor: colorScheme.primary,
        prominent: true,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox.square(
                dimension: 36,
                child: CircularProgressIndicator(strokeWidth: 3),
              )
            else
              Container(
                width: 68,
                height: 68,
                decoration: AppTextStyle.raisedTintDecoration(
                  colorScheme,
                  colorScheme.primary,
                  radius: 8,
                  prominent: true,
                ),
                child: Icon(icon, size: 38, color: colorScheme.primary),
              ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyle.style20Black.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyle.style14Regular.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}
