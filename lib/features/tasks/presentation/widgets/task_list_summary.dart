import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_style.dart';
import '../bloc/tasks_bloc.dart';
import '../bloc/tasks_state.dart';
import '../view_models/task_overview_view_models.dart';

class TaskListSummary extends StatelessWidget {
  const TaskListSummary({
    required this.isReorderModeEnabled,
    required this.onReorderModeChanged,
    super.key,
  });

  final bool isReorderModeEnabled;
  final ValueChanged<bool> onReorderModeChanged;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TasksBloc, TasksState, TaskListSummaryViewModel>(
      selector: TaskListSummaryViewModel.fromState,
      builder: (context, summary) {
        final colorScheme = Theme.of(context).colorScheme;
        final title = summary.hasTasks ? 'Tasks' : 'Workspace';
        final detail = summary.hasTasks
            ? 'Showing ${summary.visibleCount} of ${summary.totalCount}'
            : 'Ready when you are';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyle.style20Black.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        detail,
                        style: AppTextStyle.style13Medium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (summary.canReorder)
                  IconButton.filledTonal(
                    tooltip: isReorderModeEnabled
                        ? 'Finish reordering'
                        : 'Reorder tasks',
                    onPressed: () {
                      onReorderModeChanged(!isReorderModeEnabled);
                    },
                    icon: Icon(
                      isReorderModeEnabled ? Icons.done : Icons.drag_indicator,
                    ),
                  ),
                if (summary.hasActiveFilters)
                  _CompactBadge(
                    icon: Icons.filter_alt_outlined,
                    label: 'Filtered',
                    color: colorScheme.primary,
                  ),
              ],
            ),
            if (summary.showLoadingBar) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 4,
                  color: colorScheme.primary,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
            if (summary.loadError != null && summary.hasTasks) ...[
              const SizedBox(height: 10),
              _InlineError(message: summary.loadError!),
            ],
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}

class _CompactBadge extends StatelessWidget {
  const _CompactBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.14),
            color.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.12)),
        boxShadow: AppTextStyle.tintedShadows(colorScheme, color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyle.style12Bold.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.18)),
        boxShadow: AppTextStyle.tintedShadows(colorScheme, colorScheme.error),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.warning_amber_outlined, color: colorScheme.error),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTextStyle.style13Medium.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
