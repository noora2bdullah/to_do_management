import 'package:equatable/equatable.dart';

import '../../domain/entities/todo_task.dart';
import '../bloc/tasks_state.dart';

final class TaskSummaryViewModel extends Equatable {
  const TaskSummaryViewModel({
    required this.totalCount,
    required this.pendingCount,
    required this.inProgressCount,
    required this.completedCount,
    required this.lastSyncedAt,
  });

  factory TaskSummaryViewModel.fromState(TasksState state) {
    return TaskSummaryViewModel(
      totalCount: state.tasks.length,
      pendingCount: state.pendingCount,
      inProgressCount: state.inProgressCount,
      completedCount: state.completedCount,
      lastSyncedAt: state.lastSyncedAt,
    );
  }

  final int totalCount;
  final int pendingCount;
  final int inProgressCount;
  final int completedCount;
  final DateTime? lastSyncedAt;

  @override
  List<Object?> get props => [
    totalCount,
    pendingCount,
    inProgressCount,
    completedCount,
    lastSyncedAt,
  ];
}

final class TaskListSummaryViewModel extends Equatable {
  const TaskListSummaryViewModel({
    required this.totalCount,
    required this.visibleCount,
    required this.hasActiveFilters,
    required this.loadStatus,
    required this.canReorder,
    required this.loadError,
  });

  factory TaskListSummaryViewModel.fromState(TasksState state) {
    final visibleTasks = state.visibleTasks;

    return TaskListSummaryViewModel(
      totalCount: state.tasks.length,
      visibleCount: visibleTasks.length,
      hasActiveFilters: state.filters.hasActiveFilters,
      loadStatus: state.loadStatus,
      canReorder: _canReorderTasks(state, visibleTasks.length),
      loadError: state.loadError,
    );
  }

  final int totalCount;
  final int visibleCount;
  final bool hasActiveFilters;
  final TasksLoadStatus loadStatus;
  final bool canReorder;
  final String? loadError;

  bool get hasTasks => totalCount > 0;

  bool get showLoadingBar => loadStatus == TasksLoadStatus.loading && hasTasks;

  @override
  List<Object?> get props => [
    totalCount,
    visibleCount,
    hasActiveFilters,
    loadStatus,
    canReorder,
    loadError,
  ];
}

final class TaskListViewModel extends Equatable {
  const TaskListViewModel({
    required this.totalCount,
    required this.visibleTaskIds,
    required this.loadStatus,
    required this.loadError,
    required this.canReorder,
  });

  factory TaskListViewModel.fromState(TasksState state) {
    final visibleTasks = state.visibleTasks;

    return TaskListViewModel(
      totalCount: state.tasks.length,
      visibleTaskIds: List.unmodifiable(visibleTasks.map((task) => task.id)),
      loadStatus: state.loadStatus,
      loadError: state.loadError,
      canReorder: _canReorderTasks(state, visibleTasks.length),
    );
  }

  final int totalCount;
  final List<String> visibleTaskIds;
  final TasksLoadStatus loadStatus;
  final String? loadError;
  final bool canReorder;

  bool get hasTasks => totalCount > 0;

  bool get showInitialLoading =>
      (loadStatus == TasksLoadStatus.initial ||
          loadStatus == TasksLoadStatus.loading) &&
      !hasTasks;

  bool get showInitialFailure =>
      loadStatus == TasksLoadStatus.failure && !hasTasks;

  @override
  List<Object?> get props => [
    totalCount,
    visibleTaskIds,
    loadStatus,
    loadError,
    canReorder,
  ];
}

bool _canReorderTasks(TasksState state, int visibleCount) {
  return state.filters.sortOption == TaskSortOption.manual &&
      !state.filters.hasActiveFilters &&
      state.mutationStatus != TasksMutationStatus.loading &&
      visibleCount > 1;
}
