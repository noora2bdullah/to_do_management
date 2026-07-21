import 'package:equatable/equatable.dart';

import '../../domain/entities/todo_task.dart';

sealed class TaskFormEvent extends Equatable {
  const TaskFormEvent();

  @override
  List<Object?> get props => [];
}

final class TaskFormTitleChanged extends TaskFormEvent {
  const TaskFormTitleChanged(this.title);

  final String title;

  @override
  List<Object?> get props => [title];
}

final class TaskFormDescriptionChanged extends TaskFormEvent {
  const TaskFormDescriptionChanged(this.description);

  final String description;

  @override
  List<Object?> get props => [description];
}

final class TaskFormPriorityChanged extends TaskFormEvent {
  const TaskFormPriorityChanged(this.priority);

  final TaskPriority priority;

  @override
  List<Object?> get props => [priority];
}

final class TaskFormStatusChanged extends TaskFormEvent {
  const TaskFormStatusChanged(this.status);

  final TaskStatus status;

  @override
  List<Object?> get props => [status];
}

final class TaskFormDueDateChanged extends TaskFormEvent {
  const TaskFormDueDateChanged(this.dueDate);

  final DateTime dueDate;

  @override
  List<Object?> get props => [dueDate];
}
