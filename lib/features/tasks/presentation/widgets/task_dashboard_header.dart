import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../bloc/tasks_bloc.dart';
import '../bloc/tasks_state.dart';
import '../view_models/task_overview_view_models.dart';
import 'task_metric_tile.dart';

class TaskDashboardHeader extends StatelessWidget {
  const TaskDashboardHeader({required this.onCreateTask, super.key});

  final VoidCallback onCreateTask;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TasksBloc, TasksState, TaskSummaryViewModel>(
      selector: TaskSummaryViewModel.fromState,
      builder: (context, summary) {
        final colorScheme = Theme.of(context).colorScheme;
        final isDark = colorScheme.brightness == Brightness.dark;
        final syncLabel = summary.lastSyncedAt == null
            ? 'Sync pending'
            : 'Synced ${summary.lastSyncedAt!.toTaskDateTime()}';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tasks',
                        style: AppTextStyle.style28ExtraBold.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        syncLabel,
                        style: AppTextStyle.style14Medium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filled(
                  tooltip: 'Create task',
                  onPressed: onCreateTask,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final metrics = [
                  (
                    icon: Icons.inventory_2_outlined,
                    label: 'Total',
                    value: summary.totalCount,
                    color: colorScheme.primary,
                  ),
                  (
                    icon: Icons.radio_button_unchecked,
                    label: 'Pending',
                    value: summary.pendingCount,
                    color: isDark
                        ? colorScheme.outline
                        : const Color(0xFF7B5C72),
                  ),
                  (
                    icon: Icons.sync,
                    label: 'Progress',
                    value: summary.inProgressCount,
                    color: const Color(0xFF2563EB),
                  ),
                  (
                    icon: Icons.check_circle_outline,
                    label: 'Done',
                    value: summary.completedCount,
                    color: const Color(0xFF15803D),
                  ),
                ];
                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  primary: false,
                  shrinkWrap: true,
                  itemCount: metrics.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final metric = metrics[index];

                    return TaskMetricTile(
                      icon: metric.icon,
                      label: metric.label,
                      value: metric.value,
                      color: metric.color,
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
