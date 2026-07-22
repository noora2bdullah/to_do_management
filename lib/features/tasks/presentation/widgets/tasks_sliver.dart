import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/todo_task.dart';
import '../bloc/tasks_bloc.dart';
import '../bloc/tasks_event.dart';
import '../bloc/tasks_state.dart';
import '../view_models/task_overview_view_models.dart';
import 'task_card.dart';
import 'task_state_panel.dart';

class TasksSliver extends StatelessWidget {
  const TasksSliver({
    required this.horizontalPadding,
    required this.bottomPadding,
    required this.maxWidth,
    required this.onCreateTask,
    required this.onEditTask,
    required this.onDeleteTask,
    required this.isReorderModeEnabled,
    super.key,
  });

  final double horizontalPadding;
  final double bottomPadding;
  final double maxWidth;
  final VoidCallback onCreateTask;
  final ValueChanged<TodoTask> onEditTask;
  final ValueChanged<TodoTask> onDeleteTask;
  final bool isReorderModeEnabled;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksBloc, TasksState>(
      builder: (context, state) {
        final viewModel = TaskListViewModel.fromState(state);
        final tasksBloc = context.read<TasksBloc>();

        return SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            0,
            horizontalPadding,
            bottomPadding,
          ),
          sliver: _buildSliver(context, viewModel, tasksBloc),
        );
      },
    );
  }

  Widget _buildSliver(
    BuildContext context,
    TaskListViewModel viewModel,
    TasksBloc tasksBloc,
  ) {
    if (viewModel.showInitialLoading) {
      return _centeredPanel(
        const TaskStatePanel(
          icon: Icons.hourglass_empty,
          title: 'Loading tasks',
          message: 'Connecting to Firestore.',
          isLoading: true,
        ),
      );
    }

    if (viewModel.showInitialFailure) {
      return _centeredPanel(
        TaskStatePanel(
          icon: Icons.cloud_off_outlined,
          title: 'Unable to load tasks',
          message: viewModel.loadError ?? 'Please try again.',
          action: AppFilledActionButton(
            onPressed: () {
              context.read<TasksBloc>().add(const TasksRefreshRequested());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ),
      );
    }

    if (!viewModel.hasTasks) {
      return _centeredPanel(
        TaskStatePanel(
          icon: Icons.playlist_add_check,
          title: 'No tasks yet',
          message: 'Create your first task to start tracking work.',
          action: AppFilledActionButton(
            onPressed: onCreateTask,
            icon: const Icon(Icons.add),
            label: const Text('Task'),
          ),
        ),
      );
    }

    if (viewModel.visibleTaskIds.isEmpty) {
      return _centeredPanel(
        const TaskStatePanel(
          icon: Icons.filter_alt_off_outlined,
          title: 'No matching tasks',
          message: 'Adjust the current filters or search text.',
        ),
      );
    }

    final useReorderableList = viewModel.canReorder && isReorderModeEnabled;

    if (useReorderableList) {
      return SliverReorderableList(
        itemCount: viewModel.visibleTaskIds.length,
        onReorderItem: (oldIndex, newIndex) {
          context.read<TasksBloc>().add(
            TasksReordered(oldIndex: oldIndex, newIndex: newIndex),
          );
        },
        findChildIndexCallback: (key) {
          if (key is! ValueKey<String>) {
            return null;
          }

          final index = viewModel.visibleTaskIds.indexOf(key.value);

          return index == -1 ? null : index;
        },
        itemBuilder: (context, index) {
          final taskId = viewModel.visibleTaskIds[index];

          return ReorderableDelayedDragStartListener(
            key: ValueKey(taskId),
            index: index,
            child: _buildTaskItem(
              taskId: taskId,
              index: index,
              totalCount: viewModel.visibleTaskIds.length,
              showDragHandle: useReorderableList,
              tasksBloc: tasksBloc,
            ),
          );
        },
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final taskId = viewModel.visibleTaskIds[index];

          return _buildTaskItem(
            key: ValueKey(taskId),
            taskId: taskId,
            index: index,
            totalCount: viewModel.visibleTaskIds.length,
            showDragHandle: useReorderableList,
            tasksBloc: tasksBloc,
          );
        },
        childCount: viewModel.visibleTaskIds.length,
        findChildIndexCallback: (key) {
          if (key is! ValueKey<String>) {
            return null;
          }

          final index = viewModel.visibleTaskIds.indexOf(key.value);

          return index == -1 ? null : index;
        },
      ),
    );
  }

  Widget _buildTaskItem({
    Key? key,
    required String taskId,
    required int index,
    required int totalCount,
    required bool showDragHandle,
    required TasksBloc tasksBloc,
  }) {
    return Center(
      key: key,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.only(bottom: index == totalCount - 1 ? 0 : 10),
          child: RepaintBoundary(
            child: _TaskCardConnector(
              taskId: taskId,
              showDragHandle: showDragHandle,
              tasksBloc: tasksBloc,
              onEdit: onEditTask,
              onDelete: onDeleteTask,
            ),
          ),
        ),
      ),
    );
  }

  Widget _centeredPanel(Widget child) {
    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}

class _TaskCardConnector extends StatefulWidget {
  const _TaskCardConnector({
    required this.taskId,
    required this.showDragHandle,
    required this.tasksBloc,
    required this.onEdit,
    required this.onDelete,
  });

  final String taskId;
  final bool showDragHandle;
  final TasksBloc tasksBloc;
  final ValueChanged<TodoTask> onEdit;
  final ValueChanged<TodoTask> onDelete;

  @override
  State<_TaskCardConnector> createState() => _TaskCardConnectorState();
}

class _TaskCardConnectorState extends State<_TaskCardConnector>
    with AutomaticKeepAliveClientMixin<_TaskCardConnector> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocSelector<TasksBloc, TasksState, TodoTask?>(
      bloc: widget.tasksBloc,
      selector: (state) => _taskById(state.tasks, widget.taskId),
      builder: (context, task) {
        if (task == null) {
          return const SizedBox.shrink();
        }

        return TaskCard(
          task: task,
          showDragHandle: widget.showDragHandle,
          onEdit: () => widget.onEdit(task),
          onDelete: () => widget.onDelete(task),
          onStatusChanged: (status) {
            widget.tasksBloc.add(
              TaskStatusChanged(taskId: task.id, status: status),
            );
          },
        );
      },
    );
  }
}

TodoTask? _taskById(List<TodoTask> tasks, String taskId) {
  for (final task in tasks) {
    if (task.id == taskId) {
      return task;
    }
  }

  return null;
}
