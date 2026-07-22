import 'package:flutter/material.dart';

import '../theme/app_text_style.dart';

class AppSegmentedOption<T> {
  const AppSegmentedOption({
    required this.value,
    required this.label,
    this.icon,
    this.tooltip,
    this.enabled = true,
  });

  final T value;
  final String label;
  final Widget? icon;
  final String? tooltip;
  final bool enabled;
}

class AppSegmentedButton<T extends Object> extends StatelessWidget {
  const AppSegmentedButton({
    required this.selectedValue,
    required this.options,
    required this.onChanged,
    this.compact = false,
    this.showSelectedIcon = false,
    this.style,
    super.key,
  });

  final T selectedValue;
  final List<AppSegmentedOption<T>> options;
  final ValueChanged<T>? onChanged;
  final bool compact;
  final bool showSelectedIcon;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      selected: {selectedValue},
      showSelectedIcon: showSelectedIcon,
      style: style ?? (compact ? _compactStyle : null),
      segments: options.map((option) {
        return ButtonSegment<T>(
          value: option.value,
          icon: option.icon,
          label: Text(option.label),
          tooltip: option.tooltip,
          enabled: option.enabled,
        );
      }).toList(),
      onSelectionChanged: onChanged == null
          ? null
          : (selection) {
              if (selection.isNotEmpty) {
                onChanged!(selection.first);
              }
            },
    );
  }

  static final ButtonStyle _compactStyle = SegmentedButton.styleFrom(
    visualDensity: VisualDensity.compact,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    textStyle: AppTextStyle.style12Bold,
  );
}
