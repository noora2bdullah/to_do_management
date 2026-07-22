import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_man_management/features/tasks/domain/entities/task_filters.dart';
import 'package:to_do_man_management/features/tasks/domain/entities/todo_task.dart';
import 'package:to_do_man_management/features/tasks/presentation/bloc/tasks_state.dart';
import 'package:to_do_man_management/features/tasks/presentation/view_models/task_overview_view_models.dart';
import 'package:to_do_man_management/features/tasks/presentation/widgets/task_form_validators.dart';

void main() {
  group('TaskStatus parsing', () {
    test('accepts Firestore status aliases from manual edits', () {
      expect(taskStatusFromName('done'), TaskStatus.completed);
      expect(taskStatusFromName('complete'), TaskStatus.completed);
      expect(taskStatusFromName('completed'), TaskStatus.completed);
      expect(taskStatusFromName('in_progress'), TaskStatus.inProgress);
      expect(taskStatusFromName('in progress'), TaskStatus.inProgress);
      expect(taskStatusFromName('inProgress'), TaskStatus.inProgress);
      expect(taskStatusFromName('pending'), TaskStatus.pending);
    });
  });

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

    test('sorts by manual order by default', () {
      final tasks = [
        _task(id: 'second', sortOrder: 1),
        _task(id: 'first', sortOrder: 0),
      ];

      final result = const TaskFilters().apply(tasks);

      expect(result.map((task) => task.id), ['first', 'second']);
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

  group('TaskSummaryViewModel', () {
    test('uses the latest completed sync timestamp', () {
      final lastSyncedAt = DateTime(2026, 7, 22, 2, 16);
      final state = TasksState(
        lastSyncedAt: lastSyncedAt,
        tasks: [
          _task(id: 'older', updatedAt: DateTime(2026, 7, 20, 8)),
          _task(id: 'latest', updatedAt: DateTime(2026, 7, 22, 2, 5)),
          _task(id: 'middle', updatedAt: DateTime(2026, 7, 21, 9)),
        ],
      );

      final summary = TaskSummaryViewModel.fromState(state);

      expect(summary.lastSyncedAt, lastSyncedAt);
    });

    test('has no sync timestamp before tasks load', () {
      final summary = TaskSummaryViewModel.fromState(const TasksState());

      expect(summary.lastSyncedAt, isNull);
    });
  });

  group('TaskListSummaryViewModel', () {
    test('allows reordering only for manual unfiltered task lists', () {
      final tasks = [_task(id: 'first'), _task(id: 'second')];

      expect(
        TaskListSummaryViewModel.fromState(TasksState(tasks: tasks)).canReorder,
        isTrue,
      );
      expect(
        TaskListSummaryViewModel.fromState(
          TasksState(tasks: [tasks.first]),
        ).canReorder,
        isFalse,
      );
      expect(
        TaskListSummaryViewModel.fromState(
          TasksState(
            tasks: tasks,
            filters: const TaskFilters(searchQuery: 'first'),
          ),
        ).canReorder,
        isFalse,
      );
      expect(
        TaskListSummaryViewModel.fromState(
          TasksState(
            tasks: tasks,
            filters: const TaskFilters(sortOption: TaskSortOption.dueDate),
          ),
        ).canReorder,
        isFalse,
      );
      expect(
        TaskListSummaryViewModel.fromState(
          TasksState(tasks: tasks, mutationStatus: TasksMutationStatus.loading),
        ).canReorder,
        isFalse,
      );
    });
  });

  group('TaskListViewModel', () {
    test('treats unchanged visible ids as the same list structure', () {
      final before = TaskListViewModel.fromState(
        TasksState(
          tasks: [
            _task(id: 'first', title: 'Before'),
            _task(id: 'second', title: 'Stable'),
          ],
        ),
      );
      final after = TaskListViewModel.fromState(
        TasksState(
          tasks: [
            _task(id: 'first', title: 'After'),
            _task(id: 'second', title: 'Stable'),
          ],
        ),
      );

      expect(after, before);
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
  DateTime? updatedAt,
  int sortOrder = 0,
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
    sortOrder: sortOrder,
    createdAt: created,
    updatedAt: updatedAt ?? created,
  );
}
