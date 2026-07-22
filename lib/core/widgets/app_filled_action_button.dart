import 'package:flutter/material.dart';

class AppFilledActionButton extends StatelessWidget {
  const AppFilledActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isLoading = false,
    this.loadingLabel,
    this.loadingStrokeWidth = 2.5,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final Widget label;
  final bool isLoading;
  final Widget? loadingLabel;
  final double loadingStrokeWidth;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: loadingStrokeWidth),
            )
          : icon,
      label: isLoading ? loadingLabel ?? label : label,
    );
  }
}
