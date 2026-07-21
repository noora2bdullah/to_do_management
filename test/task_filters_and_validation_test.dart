import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_man_management/features/tasks/domain/entities/task_filters.dart';
import 'package:to_do_man_management/features/tasks/domain/entities/todo_task.dart';
import 'package:to_do_man_management/features/tasks/presentation/widgets/task_form_validators.dart';

void main() {
  group('TaskFilters', () {
    test('searches by title and applies status and priority filters', () {
      final tasks = [
        _task(
          id: '1',
          title: 'Write release notes',
          priority: TaskPriority.high,
          status: TaskStatus.pending,
        ),
        _task(
          id: '2',
          title: 'Review onboarding copy',
          priority: TaskPriority.medium,
          status: TaskStatus.inProgress,
        ),
        _task(
          id: '3',
          title: 'Write tests',
          priority: TaskPriority.high,
          status: TaskStatus.completed,
        ),
      ];

      final result = const TaskFilters(
        searchQuery: 'write',
        priority: TaskPriority.high,
        status: TaskStatus.pending,
      ).apply(tasks);

      expect(result.map((task) => task.id), ['1']);
    });

    test('sorts by due date ascending', () {
      final tasks = [
        _task(id: 'later', dueDate: DateTime(2026, 8, 1)),
        _task(id: 'sooner', dueDate: DateTime(2026, 7, 24)),
      ];

      final result = const TaskFilters(
        sortOption: TaskSortOption.dueDate,
      ).apply(tasks);

      expect(result.map((task) => task.id), ['sooner', 'later']);
    });

    test('sorts by created date descending', () {
      final tasks = [
        _task(id: 'older', createdAt: DateTime(2026, 7, 20)),
        _task(id: 'newer', createdAt: DateTime(2026, 7, 21)),
      ];

      final result = const TaskFilters(
        sortOption: TaskSortOption.createdDate,
      ).apply(tasks);

      expect(result.map((task) => task.id), ['newer', 'older']);
    });
  });

  group('TaskFormValidators', () {
    test('requires title and limits it to 100 characters', () {
      expect(TaskFormValidators.title(''), 'Title is required.');
      expect(
        TaskFormValidators.title(List.filled(101, 'a').join()),
        'Title must be 100 characters or fewer.',
      );
      expect(TaskFormValidators.title('Plan sprint'), isNull);
    });

    test('requires description', () {
      expect(TaskFormValidators.description('  '), 'Description is required.');
      expect(TaskFormValidators.description('Ship the dashboard'), isNull);
    });

    test('rejects past due dates', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final today = DateTime.now();

      expect(
        TaskFormValidators.dueDate(yesterday),
        'Due date cannot be in the past.',
      );
      expect(TaskFormValidators.dueDate(today), isNull);
    });
  });
}

TodoTask _task({
  required String id,
  String title = 'Task',
  TaskPriority priority = TaskPriority.low,
  TaskStatus status = TaskStatus.pending,
  DateTime? dueDate,
  DateTime? createdAt,
}) {
  final created = createdAt ?? DateTime(2026, 7, 21, 9);

  return TodoTask(
    id: id,
    ownerId: 'user-1',
    title: title,
    description: 'Description',
    priority: priority,
    dueDate: dueDate ?? DateTime(2026, 7, 25),
    status: status,
    createdAt: created,
    updatedAt: created,
  );
}
