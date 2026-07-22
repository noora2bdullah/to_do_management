import 'package:flutter/material.dart';

import '../../../../core/widgets/app_widgets.dart';

class OnboardingControls extends StatelessWidget {
  const OnboardingControls({
    required this.length,
    required this.pageIndex,
    required this.isCompleting,
    required this.onNext,
    super.key,
  });

  final int length;
  final int pageIndex;
  final bool isCompleting;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isLastPage = pageIndex == length - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Row(
        children: [
          _PageIndicator(length: length, selectedIndex: pageIndex),
          const Spacer(),
          AppFilledActionButton(
            onPressed: isCompleting ? null : onNext,
            isLoading: isCompleting,
            loadingStrokeWidth: 2.4,
            icon: Icon(isLastPage ? Icons.check : Icons.arrow_forward),
            label: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Text(
                isLastPage ? 'Get started' : 'Next',
                key: ValueKey(isLastPage),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.length, required this.selectedIndex});

  final int length;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: List.generate(length, (index) {
        final isSelected = index == selectedIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: isSelected ? 28 : 8,
          height: 8,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}
