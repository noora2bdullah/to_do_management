import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/todo_task.dart';
import '../bloc/task_form_bloc.dart';
import '../bloc/task_form_event.dart';
import '../bloc/task_form_state.dart';
import 'task_form_validators.dart';
import 'task_visuals.dart';

class TaskFormPanel extends StatelessWidget {
  const TaskFormPanel({
    required this.isEditing,
    required this.task,
    required this.titleController,
    required this.descriptionController,
    required this.onPickDueDate,
    super.key,
  });

  final bool isEditing;
  final TodoTask? task;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final ValueChanged<DateTime?> onPickDueDate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: AppTextStyle.raisedSurfaceDecoration(
        colorScheme,
        tintColor: colorScheme.primary,
        prominent: true,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TaskFormHeaderConnector(isEditing: isEditing, task: task),
            const SizedBox(height: 18),
            AppTextFormField(
              controller: titleController,
              textInputAction: TextInputAction.next,
              maxLength: 100,
              labelText: 'Title',
              prefixIcon: Icons.title,
              validator: TaskFormValidators.title,
            ),
            const SizedBox(height: 12),
            AppTextFormField(
              controller: descriptionController,
              minLines: 3,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              labelText: 'Description',
              alignLabelWithHint: true,
              prefixIcon: Icons.notes_outlined,
              validator: TaskFormValidators.description,
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 620;
                const prioritySelector = _PriorityControlGroup();
                const statusSelector = _StatusControlGroup();

                if (!isWide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      prioritySelector,
                      const SizedBox(height: 16),
                      statusSelector,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: prioritySelector),
                    const SizedBox(width: 16),
                    Expanded(child: statusSelector),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            _DueDateSelectorConnector(onPickDueDate: onPickDueDate),
          ],
        ),
      ),
    );
  }
}

class _TaskFormHeaderConnector extends StatelessWidget {
  const _TaskFormHeaderConnector({required this.isEditing, required this.task});

  final bool isEditing;
  final TodoTask? task;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TaskFormBloc, TaskFormState, TaskPriority>(
      selector: (state) => state.priority,
      builder: (context, priority) {
        return _TaskFormHeader(
          isEditing: isEditing,
          task: task,
          priority: priority,
        );
      },
    );
  }
}

class _TaskFormHeader extends StatelessWidget {
  const _TaskFormHeader({
    required this.isEditing,
    required this.task,
    required this.priority,
  });

  final bool isEditing;
  final TodoTask? task;
  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final priorityColor = taskPriorityColor(context, priority);
    final timestamp = task == null
        ? 'New task'
        : 'Updated ${task!.updatedAt.toTaskDateTime()}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: AppTextStyle.raisedTintDecoration(
            colorScheme,
            priorityColor,
            prominent: true,
          ),
          child: Icon(
            isEditing ? Icons.edit_note : Icons.add_task,
            color: priorityColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit task' : 'Create task',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.style20Black.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                timestamp,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.style12Medium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _PriorityBadge(priority: priority),
      ],
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final color = taskPriorityColor(context, priority);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 9),
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
          Icon(Icons.flag_outlined, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            priority.label,
            style: AppTextStyle.style12Bold.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _PriorityControlGroup extends StatelessWidget {
  const _PriorityControlGroup();

  @override
  Widget build(BuildContext context) {
    return const AppControlGroup(
      icon: Icons.flag_outlined,
      label: 'Priority',
      child: _PrioritySelector(),
    );
  }
}

class _PrioritySelector extends StatelessWidget {
  const _PrioritySelector();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TaskFormBloc, TaskFormState, TaskPriority>(
      selector: (state) => state.priority,
      builder: (context, value) {
        return AppSegmentedButton<TaskPriority>(
          selectedValue: value,
          compact: true,
          options: TaskPriority.values.map((priority) {
            return AppSegmentedOption<TaskPriority>(
              value: priority,
              icon: Icon(taskPriorityIcon(priority), size: 16),
              label: priority.label,
            );
          }).toList(),
          onChanged: (priority) {
            context.read<TaskFormBloc>().add(TaskFormPriorityChanged(priority));
          },
        );
      },
    );
  }
}

class _StatusControlGroup extends StatelessWidget {
  const _StatusControlGroup();

  @override
  Widget build(BuildContext context) {
    return const AppControlGroup(
      icon: Icons.timeline,
      label: 'Status',
      child: _StatusSelector(),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  const _StatusSelector();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TaskFormBloc, TaskFormState, TaskStatus>(
      selector: (state) => state.status,
      builder: (context, value) {
        return AppSegmentedButton<TaskStatus>(
          selectedValue: value,
          compact: true,
          options: TaskStatus.values.map((status) {
            return AppSegmentedOption<TaskStatus>(
              value: status,
              icon: Icon(taskStatusIcon(status), size: 16),
              label: taskStatusFormLabel(status),
            );
          }).toList(),
          onChanged: (status) {
            context.read<TaskFormBloc>().add(TaskFormStatusChanged(status));
          },
        );
      },
    );
  }
}

class _DueDateSelectorConnector extends StatelessWidget {
  const _DueDateSelectorConnector({required this.onPickDueDate});

  final ValueChanged<DateTime?> onPickDueDate;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TaskFormBloc, TaskFormState, DateTime?>(
      selector: (state) => state.dueDate,
      builder: (context, dueDate) {
        return _DueDateSelector(value: dueDate, onPickDueDate: onPickDueDate);
      },
    );
  }
}

class _DueDateSelector extends StatelessWidget {
  const _DueDateSelector({required this.value, required this.onPickDueDate});

  final DateTime? value;
  final ValueChanged<DateTime?> onPickDueDate;

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(DateTime.now());
    final shortcuts = [
      _DateShortcut('Today', today),
      _DateShortcut('Tomorrow', today.add(const Duration(days: 1))),
      _DateShortcut('Next week', today.add(const Duration(days: 7))),
    ];

    return AppControlGroup(
      icon: Icons.event,
      label: 'Due date',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormField<DateTime>(
            key: ValueKey(value?.millisecondsSinceEpoch),
            initialValue: value,
            validator: TaskFormValidators.dueDate,
            builder: (field) {
              final selectedDate = field.value;

              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => onPickDueDate(selectedDate),
                child: InputDecorator(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    suffixIcon: const Icon(Icons.keyboard_arrow_down),
                    errorText: field.errorText,
                  ),
                  child: Text(
                    selectedDate == null
                        ? 'Select date'
                        : selectedDate.toTaskDate(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.style14Bold.copyWith(
                      color: selectedDate == null
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: shortcuts.map((shortcut) {
              final selected = _isSameDate(value, shortcut.date);

              return ChoiceChip(
                visualDensity: VisualDensity.compact,
                selected: selected,
                showCheckmark: false,
                avatar: Icon(
                  selected ? Icons.check_circle : Icons.event_available,
                  size: 16,
                ),
                label: Text(shortcut.label),
                onSelected: (_) => context.read<TaskFormBloc>().add(
                  TaskFormDueDateChanged(shortcut.date),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

final class _DateShortcut {
  const _DateShortcut(this.label, this.date);

  final String label;
  final DateTime date;
}

bool _isSameDate(DateTime? first, DateTime second) {
  return first != null && dateOnly(first).isAtSameMomentAs(dateOnly(second));
}
