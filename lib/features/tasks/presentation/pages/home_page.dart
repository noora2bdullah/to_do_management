import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/widgets/auth_account_menu.dart';
import '../../domain/entities/todo_task.dart';
import '../bloc/tasks_bloc.dart';
import '../bloc/tasks_event.dart';
import '../bloc/tasks_state.dart';
import '../widgets/home_content.dart';
import '../widgets/task_visuals.dart';
import 'task_form_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.user, super.key});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return BlocListener<TasksBloc, TasksState>(
      listenWhen: (previous, current) {
        return previous.actionMessage != current.actionMessage ||
            previous.actionError != current.actionError;
      },
      listener: (context, state) {
        if (ModalRoute.of(context)?.isCurrent != true) {
          return;
        }
        _showTaskFeedback(context, state);
      },
      child: Scaffold(
        appBar: AppBar(
          notificationPredicate: (_) => false,
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIconAsset(size: 30),
              SizedBox(width: 10),
              Text('To-Do'),
            ],
          ),
          actions: [AuthAccountMenu(user: user)],
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'create-task-fab',
          onPressed: () => _openTaskForm(context),
          icon: const Icon(Icons.add),
          label: const Text('Task'),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: SafeArea(
            child: HomeContent(
              onRefresh: () => _refresh(context),
              onCreateTask: () => _openTaskForm(context),
              onEditTask: (task) => _openTaskForm(context, task: task),
              onDeleteTask: (task) => _confirmDelete(context, task),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<TasksBloc>();
    final previousLastSyncedAt = bloc.state.lastSyncedAt;

    bloc.add(const TasksRefreshRequested());
    await bloc.stream
        .firstWhere(
          (state) =>
              state.lastSyncedAt != previousLastSyncedAt ||
              state.loadStatus == TasksLoadStatus.failure,
        )
        .timeout(const Duration(seconds: 3), onTimeout: () => bloc.state);
  }

  Future<void> _openTaskForm(BuildContext context, {TodoTask? task}) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final bloc = context.read<TasksBloc>();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return BlocProvider.value(
            value: bloc,
            child: TaskFormPage(task: task),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, TodoTask task) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return _DeleteTaskDialog(task: task);
      },
    );

    if (!context.mounted || confirmed != true) {
      return;
    }

    context.read<TasksBloc>().add(TaskDeleted(task.id));
  }
}

class _DeleteTaskDialog extends StatelessWidget {
  const _DeleteTaskDialog({required this.task});

  final TodoTask task;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final errorColor = colorScheme.error;
    final priorityColor = taskPriorityColor(context, task.priority);
    final statusColor = taskStatusColor(context, task.status);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppTextStyle.surfaceGradient(
              colorScheme,
              tintColor: errorColor,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DeleteDialogHeader(color: errorColor),
                const SizedBox(height: 18),
                _DeleteTaskPreview(
                  task: task,
                  priorityColor: priorityColor,
                  statusColor: statusColor,
                ),
                const SizedBox(height: 14),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withValues(alpha: 0.42),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: errorColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: colorScheme.onErrorContainer,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'This task will be permanently removed.',
                            style: AppTextStyle.style13SemiBold.copyWith(
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: errorColor,
                        foregroundColor: colorScheme.onError,
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteDialogHeader extends StatelessWidget {
  const _DeleteDialogHeader({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.delete_forever_outlined, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Delete task',
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.style20Bold.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Close',
          onPressed: () => Navigator.of(context).pop(false),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}

class _DeleteTaskPreview extends StatelessWidget {
  const _DeleteTaskPreview({
    required this.task,
    required this.priorityColor,
    required this.statusColor,
  });

  final TodoTask task;
  final Color priorityColor;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTextStyle.surfaceBorderColor(colorScheme)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: priorityColor.withValues(alpha: 0.24),
                    ),
                  ),
                  child: Icon(
                    taskPriorityIcon(task.priority),
                    color: priorityColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.style16Bold.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.16,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.style13Regular.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DeleteTaskChip(
                  icon: Icons.event,
                  label: task.dueDate.toTaskDate(),
                  color: colorScheme.onSurfaceVariant,
                ),
                _DeleteTaskChip(
                  icon: Icons.flag_outlined,
                  label: task.priority.label,
                  color: priorityColor,
                ),
                _DeleteTaskChip(
                  icon: taskStatusIcon(task.status),
                  label: task.status.label,
                  color: statusColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteTaskChip extends StatelessWidget {
  const _DeleteTaskChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(label, style: AppTextStyle.style10Bold.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

void _showTaskFeedback(BuildContext context, TasksState state) {
  final messenger = ScaffoldMessenger.of(context);
  final message = state.actionMessage;
  final error = state.actionError;

  if (message == null && error == null) {
    return;
  }

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message ?? error!),
      behavior: SnackBarBehavior.floating,
    ),
  );
  context.read<TasksBloc>().add(const TaskActionMessageCleared());
}
