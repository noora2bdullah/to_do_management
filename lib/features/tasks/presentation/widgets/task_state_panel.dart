import 'package:flutter/material.dart';

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

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox.square(
                dimension: 36,
                child: CircularProgressIndicator(strokeWidth: 3),
              )
            else
              Icon(icon, size: 48, color: colorScheme.primary),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
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
