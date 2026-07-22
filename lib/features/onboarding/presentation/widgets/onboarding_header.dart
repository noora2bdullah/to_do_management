import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_style.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';

class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({required this.isCompleting, super.key});

  final bool isCompleting;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: AppTextStyle.raisedTintDecoration(
              colorScheme,
              colorScheme.primary,
              radius: 12,
            ),
            child: Icon(Icons.task_alt, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Text(
            'To-Do',
            style: AppTextStyle.style20Black.copyWith(color: colorScheme.onSurface),
          ),
          const Spacer(),
          TextButton(
            onPressed: isCompleting
                ? null
                : () {
                    context.read<OnboardingBloc>().add(
                      const OnboardingCompleted(),
                    );
                  },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }
}
