import 'package:flutter/material.dart';

import '../../../../core/utils/date_time_formatter.dart';
import '../../domain/entities/todo_task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChanged,
    super.key,
  });

  final TodoTask task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<TaskStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final priorityColor = _priorityColor(context, task.priority);
    final isOverdue =
        isPastCalendarDate(task.dueDate) && task.status != TaskStatus.completed;

    return Card(
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'task-icon-${task.id}',
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.flag_outlined, color: priorityColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Edit task',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: 'Delete task',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _InfoPill(
                    icon: Icons.event,
                    label: task.dueDate.toTaskDate(),
                    color: isOverdue ? colorScheme.error : colorScheme.primary,
                  ),
                  _InfoPill(
                    icon: Icons.flag_outlined,
                    label: task.priority.label,
                    color: priorityColor,
                  ),
                  PopupMenuButton<TaskStatus>(
                    tooltip: 'Change status',
                    onSelected: onStatusChanged,
                    itemBuilder: (context) {
                      return TaskStatus.values
                          .map(
                            (status) => PopupMenuItem(
                              value: status,
                              enabled: status != task.status,
                              child: Row(
                                children: [
                                  Icon(_statusIcon(status), size: 18),
                                  const SizedBox(width: 10),
                                  Text(status.label),
                                ],
                              ),
                            ),
                          )
                          .toList();
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Chip(
                        key: ValueKey(task.status),
                        avatar: Icon(
                          _statusIcon(task.status),
                          size: 18,
                          color: _statusColor(context, task.status),
                        ),
                        label: Text(task.status.label),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Updated ${task.updatedAt.toTaskDateTime()}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(color: color),
          ),
        ],
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

Color _statusColor(BuildContext context, TaskStatus status) {
  final colorScheme = Theme.of(context).colorScheme;
  return switch (status) {
    TaskStatus.pending => colorScheme.outline,
    TaskStatus.inProgress => const Color(0xFF2563EB),
    TaskStatus.completed => const Color(0xFF15803D),
  };
}

IconData _statusIcon(TaskStatus status) {
  return switch (status) {
    TaskStatus.pending => Icons.radio_button_unchecked,
    TaskStatus.inProgress => Icons.sync,
    TaskStatus.completed => Icons.check_circle_outline,
  };
}
