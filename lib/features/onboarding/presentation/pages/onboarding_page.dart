import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/onboarding_controls.dart';
import '../widgets/onboarding_header.dart';
import '../widgets/onboarding_slide.dart';
import '../widgets/onboarding_slide_items.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext(int pageIndex) {
    if (pageIndex == onboardingSlides.length - 1) {
      context.read<OnboardingBloc>().add(const OnboardingCompleted());
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listenWhen: (previous, current) {
        return previous.errorMessage != current.errorMessage;
      },
      listener: (context, state) {
        final message = state.errorMessage;
        if (message == null) {
          return;
        }

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              behavior: SnackBarBehavior.floating,
            ),
          );
      },
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<OnboardingBloc, OnboardingState>(
            builder: (context, state) {
              final pageIndex = state.pageIndex;

              return Column(
                children: [
                  OnboardingHeader(isCompleting: state.isCompleting),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: onboardingSlides.length,
                      onPageChanged: (index) {
                        context.read<OnboardingBloc>().add(
                          OnboardingPageChanged(index),
                        );
                      },
                      itemBuilder: (context, index) {
                        return OnboardingSlide(
                          data: onboardingSlides[index],
                          isActive: index == pageIndex,
                        );
                      },
                    ),
                  ),
                  OnboardingControls(
                    length: onboardingSlides.length,
                    pageIndex: pageIndex,
                    isCompleting: state.isCompleting,
                    onNext: () => _goNext(pageIndex),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
