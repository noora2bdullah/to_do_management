import 'package:equatable/equatable.dart';

import '../../domain/entities/task_input.dart';
import '../../domain/entities/todo_task.dart';

sealed class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

final class TasksSubscriptionRequested extends TasksEvent {
  const TasksSubscriptionRequested({required this.userId});

  final String userId;

  @override
  List<Object?> get props => [userId];
}

final class TasksRefreshRequested extends TasksEvent {
  const TasksRefreshRequested();
}

final class TaskCreated extends TasksEvent {
  const TaskCreated(this.input);

  final TaskInput input;

  @override
  List<Object?> get props => [input];
}

final class TaskUpdated extends TasksEvent {
  const TaskUpdated(this.task);

  final TodoTask task;

  @override
  List<Object?> get props => [task];
}

final class TaskDeleted extends TasksEvent {
  const TaskDeleted(this.taskId);

  final String taskId;

  @override
  List<Object?> get props => [taskId];
}

final class TaskStatusChanged extends TasksEvent {
  const TaskStatusChanged({required this.taskId, required this.status});

  final String taskId;
  final TaskStatus status;

  @override
  List<Object?> get props => [taskId, status];
}

final class TaskSearchChanged extends TasksEvent {
  const TaskSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class TaskStatusFilterChanged extends TasksEvent {
  const TaskStatusFilterChanged(this.status);

  final TaskStatus? status;

  @override
  List<Object?> get props => [status];
}

final class TaskPriorityFilterChanged extends TasksEvent {
  const TaskPriorityFilterChanged(this.priority);

  final TaskPriority? priority;

  @override
  List<Object?> get props => [priority];
}

final class TaskSortChanged extends TasksEvent {
  const TaskSortChanged(this.sortOption);

  final TaskSortOption sortOption;

  @override
  List<Object?> get props => [sortOption];
}

final class TaskActionMessageCleared extends TasksEvent {
  const TaskActionMessageCleared();
}

final class TasksLoaded extends TasksEvent {
  const TasksLoaded(this.tasks);

  final List<TodoTask> tasks;

  @override
  List<Object?> get props => [tasks];
}

final class TasksStreamFailed extends TasksEvent {
  const TasksStreamFailed(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
