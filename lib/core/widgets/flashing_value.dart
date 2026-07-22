import 'package:flutter/material.dart';

typedef FlashingValueBuilder<T> =
    Widget Function(BuildContext context, T value);

class FlashingValue<T> extends StatefulWidget {
  const FlashingValue({
    required this.value,
    required this.builder,
    this.flashColor,
    this.duration = const Duration(milliseconds: 700),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final T value;
  final FlashingValueBuilder<T> builder;
  final Color? flashColor;
  final Duration duration;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  State<FlashingValue<T>> createState() => _FlashingValueState<T>();
}

class _FlashingValueState<T> extends State<FlashingValue<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _flash;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _flash = _controller.drive(
      TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 0,
            end: 1,
          ).chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 24,
        ),
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 1,
            end: 0,
          ).chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 76,
        ),
      ]),
    );
  }

  @override
  void didUpdateWidget(covariant FlashingValue<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }

    if (oldWidget.value != widget.value) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final flashColor = widget.flashColor ?? colorScheme.primary;
    final isDark = colorScheme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _flash,
      child: widget.builder(context, widget.value),
      builder: (context, child) {
        final amount = _flash.value;

        return Transform.scale(
          alignment: Alignment.centerLeft,
          scale: 1 + amount * 0.035,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: flashColor.withValues(
                alpha: amount * (isDark ? 0.24 : 0.16),
              ),
              borderRadius: widget.borderRadius,
              border: Border.all(
                color: flashColor.withValues(
                  alpha: amount * (isDark ? 0.42 : 0.28),
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: flashColor.withValues(
                    alpha: amount * (isDark ? 0.24 : 0.18),
                  ),
                  blurRadius: 14 * amount,
                  spreadRadius: amount,
                ),
              ],
            ),
            child: Padding(padding: widget.padding, child: child),
          ),
        );
      },
    );
  }
}
