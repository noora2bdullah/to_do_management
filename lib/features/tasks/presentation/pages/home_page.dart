import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/date_time_formatter.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../domain/entities/todo_task.dart';
import '../bloc/tasks_bloc.dart';
import '../bloc/tasks_event.dart';
import '../bloc/tasks_state.dart';
import '../widgets/task_card.dart';
import '../widgets/task_filters_panel.dart';
import '../widgets/task_metric_tile.dart';
import '../widgets/task_state_panel.dart';
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
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.task_alt),
              SizedBox(width: 10),
              Text('TaskFlow'),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: Text(
                    user.email,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Sign out',
              onPressed: () {
                context.read<AuthBloc>().add(const AuthSignOutRequested());
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'create-task-fab',
          onPressed: () => _openTaskForm(context),
          icon: const Icon(Icons.add),
          label: const Text('Task'),
        ),
        body: SafeArea(
          child: BlocBuilder<TasksBloc, TasksState>(
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () => _refresh(context),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1120),
                        child: _HomeContent(
                          state: state,
                          onCreateTask: () => _openTaskForm(context),
                          onEditTask: (task) =>
                              _openTaskForm(context, task: task),
                          onDeleteTask: (task) => _confirmDelete(context, task),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<TasksBloc>();
    bloc.add(const TasksRefreshRequested());
    await bloc.stream
        .firstWhere((state) => state.loadStatus != TasksLoadStatus.loading)
        .timeout(const Duration(seconds: 3), onTimeout: () => bloc.state);
  }

  Future<void> _openTaskForm(BuildContext context, {TodoTask? task}) async {
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete task'),
          content: Text('Delete "${task.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!context.mounted || confirmed != true) {
      return;
    }

    context.read<TasksBloc>().add(TaskDeleted(task.id));
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.state,
    required this.onCreateTask,
    required this.onEditTask,
    required this.onDeleteTask,
  });

  final TasksState state;
  final VoidCallback onCreateTask;
  final ValueChanged<TodoTask> onEditTask;
  final ValueChanged<TodoTask> onDeleteTask;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final dashboard = _DashboardHeader(
          state: state,
          onCreateTask: onCreateTask,
        );
        final filters = TaskFiltersPanel(state: state);
        final tasks = _TasksContent(
          state: state,
          onCreateTask: onCreateTask,
          onEditTask: onEditTask,
          onDeleteTask: onDeleteTask,
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 320,
                child: Column(
                  children: [dashboard, const SizedBox(height: 16), filters],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: tasks),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            dashboard,
            const SizedBox(height: 16),
            filters,
            const SizedBox(height: 16),
            if (state.isLoading && state.hasTasks) ...[
              LinearProgressIndicator(
                color: colorScheme.primary,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(height: 12),
            ],
            tasks,
          ],
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.state, required this.onCreateTask});

  final TasksState state;
  final VoidCallback onCreateTask;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Synced ${DateTime.now().toTaskDate()}',
                    style: theme.textTheme.bodyMedium?.copyWith(
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
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2,
          shrinkWrap: true,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            TaskMetricTile(
              icon: Icons.inventory_2_outlined,
              label: 'Total',
              value: state.tasks.length,
              color: colorScheme.primary,
            ),
            TaskMetricTile(
              icon: Icons.radio_button_unchecked,
              label: 'Pending',
              value: state.pendingCount,
              color: colorScheme.outline,
            ),
            TaskMetricTile(
              icon: Icons.sync,
              label: 'Progress',
              value: state.inProgressCount,
              color: const Color(0xFF2563EB),
            ),
            TaskMetricTile(
              icon: Icons.check_circle_outline,
              label: 'Done',
              value: state.completedCount,
              color: const Color(0xFF15803D),
            ),
          ],
        ),
      ],
    );
  }
}

class _TasksContent extends StatelessWidget {
  const _TasksContent({
    required this.state,
    required this.onCreateTask,
    required this.onEditTask,
    required this.onDeleteTask,
  });

  final TasksState state;
  final VoidCallback onCreateTask;
  final ValueChanged<TodoTask> onEditTask;
  final ValueChanged<TodoTask> onDeleteTask;

  @override
  Widget build(BuildContext context) {
    final visibleTasks = state.visibleTasks;
    final contentKey = ValueKey(
      '${state.loadStatus}-${state.tasks.length}-${visibleTasks.length}',
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      child: switch (state.loadStatus) {
        TasksLoadStatus.initial ||
        TasksLoadStatus.loading when !state.hasTasks => const TaskStatePanel(
          key: ValueKey('loading'),
          icon: Icons.hourglass_empty,
          title: 'Loading tasks',
          message: 'Connecting to Firestore.',
          isLoading: true,
        ),
        TasksLoadStatus.failure when !state.hasTasks => TaskStatePanel(
          key: ValueKey('failure'),
          icon: Icons.cloud_off_outlined,
          title: 'Unable to load tasks',
          message: state.loadError ?? 'Please try again.',
          action: FilledButton.icon(
            onPressed: () {
              context.read<TasksBloc>().add(const TasksRefreshRequested());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ),
        _ when !state.hasTasks => TaskStatePanel(
          key: ValueKey('empty-all'),
          icon: Icons.playlist_add_check,
          title: 'No tasks yet',
          message: 'Create your first task to start tracking work.',
          action: FilledButton.icon(
            onPressed: onCreateTask,
            icon: const Icon(Icons.add),
            label: const Text('Task'),
          ),
        ),
        _ when visibleTasks.isEmpty => TaskStatePanel(
          key: ValueKey('empty-filtered'),
          icon: Icons.filter_alt_off_outlined,
          title: 'No matching tasks',
          message: 'Adjust the current filters or search text.',
        ),
        _ => Column(
          key: contentKey,
          children: [
            if (state.isLoading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
            ],
            ...visibleTasks.map(
              (task) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TaskCard(
                  task: task,
                  onEdit: () => onEditTask(task),
                  onDelete: () => onDeleteTask(task),
                  onStatusChanged: (status) {
                    context.read<TasksBloc>().add(
                      TaskStatusChanged(taskId: task.id, status: status),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      },
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
