import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../domain/entities/todo_task.dart';
import 'task_visuals.dart';

enum _TaskCardAction { edit, delete }

class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChanged,
    this.showDragHandle = false,
    super.key,
  });

  final TodoTask task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<TaskStatus> onStatusChanged;
  final bool showDragHandle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final priorityColor = taskPriorityColor(context, task.priority);
    final isOverdue =
        isPastCalendarDate(task.dueDate) && task.status != TaskStatus.completed;
    final dueColor = isOverdue
        ? colorScheme.error
        : colorScheme.onSurfaceVariant;

    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: 1,
      margin: EdgeInsets.zero,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppTextStyle.surfaceGradient(
            colorScheme,
            tintColor: priorityColor,
          ),
        ),
        child: InkWell(
          onTap: onEdit,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                child: ColoredBox(
                  color: priorityColor,
                  child: const SizedBox(width: 5),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 8, 6, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (showDragHandle) ...[
                          Icon(
                            Icons.drag_indicator,
                            size: 18,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            task.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.style14ExtraBold.copyWith(
                              color: colorScheme.onSurface,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        SizedBox.square(
                          dimension: 30,
                          child: PopupMenuButton<_TaskCardAction>(
                            tooltip: 'Task actions',
                            padding: EdgeInsets.zero,
                            iconSize: 18,
                            onSelected: (action) {
                              switch (action) {
                                case _TaskCardAction.edit:
                                  onEdit();
                                case _TaskCardAction.delete:
                                  onDelete();
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: _TaskCardAction.edit,
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined),
                                    SizedBox(width: 10),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: _TaskCardAction.delete,
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline),
                                    SizedBox(width: 10),
                                    Text('Delete'),
                                  ],
                                ),
                              ),
                            ],
                            icon: const Icon(Icons.more_horiz),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.style12Regular.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _InfoPill(
                          icon: isOverdue
                              ? Icons.event_busy_outlined
                              : Icons.event,
                          label: task.dueDate.toTaskDate(),
                          color: dueColor,
                        ),
                        _InfoPill(
                          icon: Icons.flag_outlined,
                          label: task.priority.label,
                          color: priorityColor,
                        ),
                        PopupMenuButton<TaskStatus>(
                          tooltip: 'Change status',
                          padding: EdgeInsets.zero,
                          onSelected: onStatusChanged,
                          itemBuilder: (context) {
                            return TaskStatus.values
                                .map(
                                  (status) => PopupMenuItem(
                                    value: status,
                                    enabled: status != task.status,
                                    child: Row(
                                      children: [
                                        Icon(taskStatusIcon(status), size: 18),
                                        const SizedBox(width: 10),
                                        Text(status.label),
                                      ],
                                    ),
                                  ),
                                )
                                .toList();
                          },
                          child: _StatusPill(status: task.status),
                        ),
                        _InlineMeta(
                          icon: Icons.update,
                          label: task.updatedAt.toTaskDateTime(),
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ],
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
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: _pillDecoration(colorScheme, color),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(label, style: AppTextStyle.style10Bold.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _InlineMeta extends StatelessWidget {
  const _InlineMeta({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTextStyle.style10SemiBold.copyWith(
              color: color,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final color = taskStatusColor(context, status);
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: _pillDecoration(colorScheme, color),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(taskStatusIcon(status), size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              status.label,
              style: AppTextStyle.style10Bold.copyWith(color: color),
            ),
            const SizedBox(width: 2),
            Icon(Icons.keyboard_arrow_down, size: 13, color: color),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _pillDecoration(ColorScheme colorScheme, Color color) {
  final isDark = colorScheme.brightness == Brightness.dark;
  final baseColor = isDark
      ? colorScheme.surfaceContainerHighest
      : colorScheme.surfaceContainerLow;

  return BoxDecoration(
    color: Color.alphaBlend(
      color.withValues(alpha: isDark ? 0.18 : 0.13),
      baseColor,
    ),
    borderRadius: BorderRadius.circular(6),
    border: Border.all(color: color.withValues(alpha: isDark ? 0.22 : 0.2)),
  );
}
