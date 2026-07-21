import 'package:equatable/equatable.dart';

enum TaskPriority { low, medium, high }

enum TaskStatus { pending, inProgress, completed }

enum TaskSortOption { dueDate, createdDate }

extension TaskPriorityLabel on TaskPriority {
  String get label {
    return switch (this) {
      TaskPriority.low => 'Low',
      TaskPriority.medium => 'Medium',
      TaskPriority.high => 'High',
    };
  }
}

extension TaskStatusLabel on TaskStatus {
  String get label {
    return switch (this) {
      TaskStatus.pending => 'Pending',
      TaskStatus.inProgress => 'In Progress',
      TaskStatus.completed => 'Completed',
    };
  }
}

extension TaskSortOptionLabel on TaskSortOption {
  String get label {
    return switch (this) {
      TaskSortOption.dueDate => 'Due Date',
      TaskSortOption.createdDate => 'Created Date',
    };
  }
}

TaskPriority taskPriorityFromName(String? value) {
  return TaskPriority.values.firstWhere(
    (priority) => priority.name == value,
    orElse: () => TaskPriority.medium,
  );
}

TaskStatus taskStatusFromName(String? value) {
  return TaskStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => TaskStatus.pending,
  );
}

class TodoTask extends Equatable {
  const TodoTask({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime dueDate;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  TodoTask copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    TaskPriority? priority,
    DateTime? dueDate,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoTask(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    ownerId,
    title,
    description,
    priority,
    dueDate,
    status,
    createdAt,
    updatedAt,
  ];
}
