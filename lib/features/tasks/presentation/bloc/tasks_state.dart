import 'package:equatable/equatable.dart';

import '../../domain/entities/task_filters.dart';
import '../../domain/entities/todo_task.dart';

enum TasksLoadStatus { initial, loading, success, failure }

enum TasksMutationStatus { idle, loading, success, failure }

final class TasksState extends Equatable {
  const TasksState({
    this.userId,
    this.tasks = const [],
    this.filters = const TaskFilters(),
    this.loadStatus = TasksLoadStatus.initial,
    this.mutationStatus = TasksMutationStatus.idle,
    this.loadError,
    this.actionMessage,
    this.actionError,
    this.lastSyncedAt,
  });

  final String? userId;
  final List<TodoTask> tasks;
  final TaskFilters filters;
  final TasksLoadStatus loadStatus;
  final TasksMutationStatus mutationStatus;
  final String? loadError;
  final String? actionMessage;
  final String? actionError;
  final DateTime? lastSyncedAt;

  bool get isLoading => loadStatus == TasksLoadStatus.loading;

  bool get hasTasks => tasks.isNotEmpty;

  List<TodoTask> get visibleTasks => filters.apply(tasks);

  int get pendingCount {
    return tasks.where((task) => task.status == TaskStatus.pending).length;
  }

  int get inProgressCount {
    return tasks.where((task) => task.status == TaskStatus.inProgress).length;
  }

  int get completedCount {
    return tasks.where((task) => task.status == TaskStatus.completed).length;
  }

  TasksState copyWith({
    String? userId,
    List<TodoTask>? tasks,
    TaskFilters? filters,
    TasksLoadStatus? loadStatus,
    TasksMutationStatus? mutationStatus,
    String? loadError,
    bool clearLoadError = false,
    String? actionMessage,
    bool clearActionMessage = false,
    String? actionError,
    bool clearActionError = false,
    DateTime? lastSyncedAt,
  }) {
    return TasksState(
      userId: userId ?? this.userId,
      tasks: tasks ?? this.tasks,
      filters: filters ?? this.filters,
      loadStatus: loadStatus ?? this.loadStatus,
      mutationStatus: mutationStatus ?? this.mutationStatus,
      loadError: clearLoadError ? null : loadError ?? this.loadError,
      actionMessage: clearActionMessage
          ? null
          : actionMessage ?? this.actionMessage,
      actionError: clearActionError ? null : actionError ?? this.actionError,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    tasks,
    filters,
    loadStatus,
    mutationStatus,
    loadError,
    actionMessage,
    actionError,
    lastSyncedAt,
  ];
}
