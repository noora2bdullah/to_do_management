import 'package:flutter/material.dart';

import 'onboarding_slide.dart';

const onboardingSlides = [
  OnboardingSlideData(
    icon: Icons.fact_check_outlined,
    title: 'Plan every task',
    message:
        'Capture work with clear titles, descriptions, priorities, and due dates.',
    accentAlignment: Alignment.topLeft,
  ),
  OnboardingSlideData(
    icon: Icons.flag_outlined,
    title: 'Focus by priority',
    message:
        'Filter by status and priority so the next best action is always easy to find.',
    accentAlignment: Alignment.centerRight,
  ),
  OnboardingSlideData(
    icon: Icons.cloud_sync_outlined,
    title: 'Stay synced',
    message:
        'Firestore streams keep your tasks updated in realtime across every signed-in device.',
    accentAlignment: Alignment.bottomLeft,
  ),
];
