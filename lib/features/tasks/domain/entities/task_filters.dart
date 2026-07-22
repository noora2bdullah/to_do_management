import 'package:equatable/equatable.dart';

import 'todo_task.dart';

final class TaskFilters extends Equatable {
  const TaskFilters({
    this.searchQuery = '',
    this.status,
    this.priority,
    this.sortOption = TaskSortOption.manual,
  });

  final String searchQuery;
  final TaskStatus? status;
  final TaskPriority? priority;
  final TaskSortOption sortOption;

  bool get hasActiveFilters {
    return searchQuery.trim().isNotEmpty || status != null || priority != null;
  }

  List<TodoTask> apply(List<TodoTask> tasks) {
    final query = searchQuery.trim().toLowerCase();
    final filtered = tasks.where((task) {
      final matchesSearch =
          query.isEmpty || task.title.toLowerCase().contains(query);
      final matchesStatus = status == null || task.status == status;
      final matchesPriority = priority == null || task.priority == priority;

      return matchesSearch && matchesStatus && matchesPriority;
    }).toList();

    filtered.sort((first, second) {
      return switch (sortOption) {
        TaskSortOption.manual => _compareManualOrder(first, second),
        TaskSortOption.dueDate => first.dueDate.compareTo(second.dueDate),
        TaskSortOption.createdDate => second.createdAt.compareTo(
          first.createdAt,
        ),
      };
    });

    return filtered;
  }

  TaskFilters copyWith({
    String? searchQuery,
    TaskStatus? status,
    bool clearStatus = false,
    TaskPriority? priority,
    bool clearPriority = false,
    TaskSortOption? sortOption,
  }) {
    return TaskFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      status: clearStatus ? null : status ?? this.status,
      priority: clearPriority ? null : priority ?? this.priority,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  @override
  List<Object?> get props => [searchQuery, status, priority, sortOption];
}

int _compareManualOrder(TodoTask first, TodoTask second) {
  final orderComparison = first.sortOrder.compareTo(second.sortOrder);
  if (orderComparison != 0) {
    return orderComparison;
  }

  final createdComparison = second.createdAt.compareTo(first.createdAt);
  if (createdComparison != 0) {
    return createdComparison;
  }

  return first.id.compareTo(second.id);
}
