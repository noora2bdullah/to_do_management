import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_style.dart';
import '../../../../core/widgets/app_icon_asset.dart';

class AuthBrandPanel extends StatelessWidget {
  const AuthBrandPanel({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: compact
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        AppIconAsset(size: compact ? 72 : 92),
        const SizedBox(height: 24),
        Text(
          'To-Do',
          textAlign: compact ? TextAlign.center : TextAlign.start,
          style:
              (compact ? AppTextStyle.style32Black : AppTextStyle.style36Black)
                  .copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: 12),
        Text(
          'Plan work, track progress, and keep every device in sync.',
          textAlign: compact ? TextAlign.center : TextAlign.start,
          style: AppTextStyle.style16Medium.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
