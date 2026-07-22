import 'package:flutter/material.dart';

import '../../domain/entities/todo_task.dart';

IconData taskPriorityIcon(TaskPriority priority) {
  return switch (priority) {
    TaskPriority.low => Icons.keyboard_arrow_down,
    TaskPriority.medium => Icons.remove,
    TaskPriority.high => Icons.priority_high,
  };
}

Color taskPriorityColor(BuildContext context, TaskPriority priority) {
  final colorScheme = Theme.of(context).colorScheme;
  final isDark = colorScheme.brightness == Brightness.dark;

  return switch (priority) {
    TaskPriority.low => isDark ? const Color(0xFFFFB1DD) : colorScheme.primary,
    TaskPriority.medium =>
      isDark ? const Color(0xFFFFD166) : const Color(0xFF9C5A00),
    TaskPriority.high =>
      isDark ? const Color(0xFFFFB4AB) : const Color(0xFFB3261E),
  };
}

IconData taskStatusIcon(TaskStatus status) {
  return switch (status) {
    TaskStatus.pending => Icons.radio_button_unchecked,
    TaskStatus.inProgress => Icons.sync,
    TaskStatus.completed => Icons.check_circle_outline,
  };
}

Color taskStatusColor(BuildContext context, TaskStatus status) {
  final colorScheme = Theme.of(context).colorScheme;
  final isDark = colorScheme.brightness == Brightness.dark;

  return switch (status) {
    TaskStatus.pending =>
      isDark ? const Color(0xFFE6DFEA) : const Color(0xFF6F5C69),
    TaskStatus.inProgress =>
      isDark ? const Color(0xFFA8C7FA) : const Color(0xFF0B57D0),
    TaskStatus.completed =>
      isDark ? const Color(0xFF78D996) : const Color(0xFF146C2E),
  };
}

String taskStatusFormLabel(TaskStatus status) {
  return switch (status) {
    TaskStatus.pending => 'Pending',
    TaskStatus.inProgress => 'Progress',
    TaskStatus.completed => 'Done',
  };
}
