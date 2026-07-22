import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_style.dart';

class OnboardingSlideData {
  const OnboardingSlideData({
    required this.icon,
    required this.title,
    required this.message,
    required this.accentAlignment,
  });

  final IconData icon;
  final String title;
  final String message;
  final Alignment accentAlignment;
}

class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    required this.data,
    required this.isActive,
    super.key,
  });

  final OnboardingSlideData data;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 680;
        final illustration = _OnboardingIllustration(data: data);
        final copy = _OnboardingCopy(data: data);

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 240),
            opacity: isActive ? 1 : 0.72,
            child: DecoratedBox(
              decoration: BoxDecoration(color: colorScheme.surface),
              child: isWide
                  ? Row(
                      children: [
                        Expanded(child: illustration),
                        const SizedBox(width: 32),
                        Expanded(child: copy),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(child: illustration),
                        const SizedBox(height: 24),
                        copy,
                        const SizedBox(height: 14),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingIllustration extends StatelessWidget {
  const _OnboardingIllustration({required this.data});

  final OnboardingSlideData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: data.accentAlignment,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(44),
                boxShadow: AppTextStyle.surfaceShadows(
                  colorScheme,
                  tintColor: colorScheme.primary,
                  prominent: true,
                ),
              ),
            ),
            Container(
              width: 152,
              height: 152,
              decoration: AppTextStyle.raisedTintDecoration(
                colorScheme,
                colorScheme.primary,
                radius: 34,
                prominent: true,
              ),
              child: Icon(data.icon, size: 76, color: colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingCopy extends StatelessWidget {
  const _OnboardingCopy({required this.data});

  final OnboardingSlideData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.title,
          style: AppTextStyle.style28Black.copyWith(
            color: colorScheme.onSurface,
            height: 1.02,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          data.message,
          style: AppTextStyle.style16Medium.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.38,
          ),
        ),
      ],
    );
  }
}
