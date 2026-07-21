import 'package:equatable/equatable.dart';

import 'todo_task.dart';

final class TaskInput extends Equatable {
  const TaskInput({
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    required this.status,
  });

  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime dueDate;
  final TaskStatus status;

  @override
  List<Object?> get props => [title, description, priority, dueDate, status];
}
