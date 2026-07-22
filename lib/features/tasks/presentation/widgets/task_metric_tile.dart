import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_style.dart';
import '../../../../core/widgets/flashing_value.dart';

class TaskMetricTile extends StatelessWidget {
  const TaskMetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    super.key,
  });

  final IconData icon;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppTextStyle.surfaceGradient(colorScheme, tintColor: color),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: AppTextStyle.raisedTintDecoration(colorScheme, color),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FlashingValue<int>(
                      value: value,
                      flashColor: color,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      builder: (context, value) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: Text(
                            '$value',
                            key: ValueKey(value),
                            style: AppTextStyle.style22Black.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        );
                      },
                    ),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.style14Bold.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
