import 'package:equatable/equatable.dart';

import '../../domain/entities/task_input.dart';
import '../../domain/entities/todo_task.dart';

final class TaskFormState extends Equatable {
  const TaskFormState({
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.dueDate,
  });

  factory TaskFormState.fromTask(TodoTask? task) {
    return TaskFormState(
      title: task?.title ?? '',
      description: task?.description ?? '',
      priority: task?.priority ?? TaskPriority.medium,
      status: task?.status ?? TaskStatus.pending,
      dueDate: task?.dueDate,
    );
  }

  final String title;
  final String description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? dueDate;

  TaskInput get input {
    return TaskInput(
      title: title.trim(),
      description: description.trim(),
      priority: priority,
      dueDate: dueDate!,
      status: status,
    );
  }

  TaskFormState copyWith({
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
  }) {
    return TaskFormState(
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  @override
  List<Object?> get props => [title, description, priority, status, dueDate];
}
