import 'package:flutter/material.dart';

import '../theme/app_text_style.dart';

class AppControlGroup extends StatelessWidget {
  const AppControlGroup({
    required this.label,
    required this.child,
    this.icon,
    this.expandChild = true,
    super.key,
  });

  final String label;
  final Widget child;
  final IconData? icon;
  final bool expandChild;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final labelText = Text(
      label,
      style: AppTextStyle.style12Bold.copyWith(color: colorScheme.onSurfaceVariant),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon == null)
          labelText
        else
          Row(
            children: [
              Icon(icon, size: 16, color: colorScheme.primary),
              const SizedBox(width: 6),
              labelText,
            ],
          ),
        const SizedBox(height: 8),
        if (expandChild)
          SizedBox(width: double.infinity, child: child)
        else
          child,
      ],
    );
  }
}
