import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/todo_task.dart';
import '../bloc/tasks_bloc.dart';
import '../bloc/tasks_event.dart';
import '../bloc/tasks_state.dart';
import 'task_search_field.dart';

class TaskFiltersPanel extends StatelessWidget {
  const TaskFiltersPanel({required this.state, super.key});

  final TasksState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filters = state.filters;
    final bloc = context.read<TasksBloc>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find work',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            TaskSearchField(
              query: filters.searchQuery,
              onChanged: (query) => bloc.add(TaskSearchChanged(query)),
            ),
            const SizedBox(height: 18),
            Text('Status', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: filters.status == null,
                  onSelected: (_) {
                    bloc.add(const TaskStatusFilterChanged(null));
                  },
                ),
                ...TaskStatus.values.map(
                  (status) => ChoiceChip(
                    label: Text(status.label),
                    selected: filters.status == status,
                    onSelected: (_) {
                      bloc.add(TaskStatusFilterChanged(status));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text('Priority', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: filters.priority == null,
                  onSelected: (_) {
                    bloc.add(const TaskPriorityFilterChanged(null));
                  },
                ),
                ...TaskPriority.values.map(
                  (priority) => ChoiceChip(
                    avatar: Icon(
                      Icons.flag_outlined,
                      size: 18,
                      color: _priorityColor(context, priority),
                    ),
                    label: Text(priority.label),
                    selected: filters.priority == priority,
                    onSelected: (_) {
                      bloc.add(TaskPriorityFilterChanged(priority));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text('Sort', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<TaskSortOption>(
                selected: {filters.sortOption},
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: TaskSortOption.dueDate,
                    icon: Icon(Icons.event),
                    label: Text('Due'),
                  ),
                  ButtonSegment(
                    value: TaskSortOption.createdDate,
                    icon: Icon(Icons.schedule),
                    label: Text('Created'),
                  ),
                ],
                onSelectionChanged: (selection) {
                  bloc.add(TaskSortChanged(selection.first));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _priorityColor(BuildContext context, TaskPriority priority) {
  final colorScheme = Theme.of(context).colorScheme;
  return switch (priority) {
    TaskPriority.low => colorScheme.primary,
    TaskPriority.medium => const Color(0xFFB7791F),
    TaskPriority.high => colorScheme.error,
  };
}
