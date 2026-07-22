import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_man_management/features/tasks/domain/entities/task_input.dart';
import 'package:to_do_man_management/features/tasks/domain/entities/task_sync_snapshot.dart';
import 'package:to_do_man_management/features/tasks/domain/entities/todo_task.dart';
import 'package:to_do_man_management/features/tasks/domain/repositories/task_repository.dart';
import 'package:to_do_man_management/features/tasks/domain/usecases/task_usecases.dart';
import 'package:to_do_man_management/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:to_do_man_management/features/tasks/presentation/bloc/tasks_event.dart';
import 'package:to_do_man_management/features/tasks/presentation/bloc/tasks_state.dart';
import 'package:to_do_man_management/features/tasks/presentation/view_models/task_overview_view_models.dart';

void main() {
  test(
    'refreshes from the server and updates sync time for unchanged tasks',
    () async {
      final repository = _FakeTaskRepository();
      final bloc = _tasksBloc(repository);
      final emittedStates = <TasksState>[];
      final subscription = bloc.stream.listen(emittedStates.add);
      final tasks = [_task(id: 'task-1')];

      bloc.add(const TasksSubscriptionRequested(userId: 'user-1'));
      await pumpEventQueue();

      repository.emit(
        TaskSyncSnapshot(
          tasks: tasks,
          isFromCache: false,
          hasPendingWrites: false,
        ),
      );
      await pumpEventQueue();

      expect(repository.watchCallCount, 1);
      expect(bloc.state.loadStatus, TasksLoadStatus.success);
      final firstSyncedAt = bloc.state.lastSyncedAt;

      emittedStates.clear();
      repository.emit(
        TaskSyncSnapshot(
          tasks: List<TodoTask>.of(tasks),
          isFromCache: false,
          hasPendingWrites: false,
        ),
      );
      await pumpEventQueue();

      expect(emittedStates, isEmpty);

      repository.refreshSnapshot = TaskSyncSnapshot(
        tasks: List<TodoTask>.of(tasks),
        isFromCache: false,
        hasPendingWrites: false,
      );
      bloc.add(const TasksRefreshRequested());
      await pumpEventQueue();

      expect(repository.watchCallCount, 1);
      expect(repository.refreshCallCount, 1);
      expect(bloc.state.loadStatus, TasksLoadStatus.success);
      expect(bloc.state.lastSyncedAt, isNot(firstSyncedAt));

      await subscription.cancel();
      await bloc.close();
    },
  );

  test('creates new tasks after the current manual order', () async {
    final repository = _FakeTaskRepository();
    final bloc = _tasksBloc(repository);

    bloc.add(const TasksSubscriptionRequested(userId: 'user-1'));
    await pumpEventQueue();

    repository.emit(
      TaskSyncSnapshot(
        tasks: [
          _task(id: 'first', sortOrder: 0),
          _task(id: 'last', sortOrder: 7),
        ],
        isFromCache: false,
        hasPendingWrites: false,
      ),
    );
    await pumpEventQueue();

    bloc.add(TaskCreated(_input()));
    await pumpEventQueue();

    expect(repository.createdSortOrders, [8]);

    await bloc.close();
  });

  test('keeps reordering available while manual order is saving', () async {
    final repository = _FakeTaskRepository()
      ..reorderCompleter = Completer<void>();
    final bloc = _tasksBloc(repository);

    bloc.add(const TasksSubscriptionRequested(userId: 'user-1'));
    await pumpEventQueue();

    repository.emit(
      TaskSyncSnapshot(
        tasks: [
          _task(id: 'first', sortOrder: 0),
          _task(id: 'middle', sortOrder: 1),
          _task(id: 'last', sortOrder: 2),
        ],
        isFromCache: false,
        hasPendingWrites: false,
      ),
    );
    await pumpEventQueue();

    bloc.add(const TasksReordered(oldIndex: 0, newIndex: 2));
    await pumpEventQueue();

    expect(bloc.state.tasks.map((task) => task.id), [
      'middle',
      'last',
      'first',
    ]);
    expect(bloc.state.mutationStatus, TasksMutationStatus.idle);
    expect(TaskListViewModel.fromState(bloc.state).canReorder, isTrue);

    repository.reorderCompleter!.complete();
    await pumpEventQueue();
    await bloc.close();
  });

  test(
    'places downward reorders at the index reported by onReorderItem',
    () async {
      final repository = _FakeTaskRepository();
      final bloc = _tasksBloc(repository);

      bloc.add(const TasksSubscriptionRequested(userId: 'user-1'));
      await pumpEventQueue();

      repository.emit(
        TaskSyncSnapshot(
          tasks: [
            _task(id: 'first', sortOrder: 0),
            _task(id: 'second', sortOrder: 1),
            _task(id: 'third', sortOrder: 2),
            _task(id: 'fourth', sortOrder: 3),
          ],
          isFromCache: false,
          hasPendingWrites: false,
        ),
      );
      await pumpEventQueue();

      bloc.add(const TasksReordered(oldIndex: 0, newIndex: 2));
      await pumpEventQueue();

      expect(bloc.state.tasks.map((task) => task.id), [
        'second',
        'third',
        'first',
        'fourth',
      ]);

      await bloc.close();
    },
  );
}

TasksBloc _tasksBloc(_FakeTaskRepository repository) {
  return TasksBloc(
    WatchTasks(repository),
    RefreshTasks(repository),
    CreateTask(repository),
    UpdateTask(repository),
    DeleteTask(repository),
    ChangeTaskStatus(repository),
    ReorderTasks(repository),
  );
}

final class _FakeTaskRepository implements TaskRepository {
  final _controller = StreamController<TaskSyncSnapshot>.broadcast();

  int watchCallCount = 0;
  int refreshCallCount = 0;
  final createdSortOrders = <int>[];
  final reorderedTaskIds = <List<String>>[];
  Completer<void>? reorderCompleter;
  TaskSyncSnapshot? refreshSnapshot;

  void emit(TaskSyncSnapshot snapshot) {
    _controller.add(snapshot);
  }

  @override
  Stream<TaskSyncSnapshot> watchTasks(String userId) {
    watchCallCount += 1;
    return _controller.stream;
  }

  @override
  Future<TaskSyncSnapshot> refreshTasks(String userId) async {
    refreshCallCount += 1;
    return refreshSnapshot ??
        const TaskSyncSnapshot(
          tasks: [],
          isFromCache: false,
          hasPendingWrites: false,
        );
  }

  @override
  Future<void> createTask({
    required String userId,
    required TaskInput input,
    required int sortOrder,
  }) async {
    createdSortOrders.add(sortOrder);
  }

  @override
  Future<void> updateTask({
    required String userId,
    required TodoTask task,
  }) async {}

  @override
  Future<void> deleteTask({
    required String userId,
    required String taskId,
  }) async {}

  @override
  Future<void> changeTaskStatus({
    required String userId,
    required String taskId,
    required TaskStatus status,
  }) async {}

  @override
  Future<void> reorderTasks({
    required String userId,
    required List<TodoTask> tasks,
  }) async {
    reorderedTaskIds.add([for (final task in tasks) task.id]);
    final completer = reorderCompleter;
    if (completer != null) {
      await completer.future;
    }
  }
}

TodoTask _task({required String id, int sortOrder = 0}) {
  final createdAt = DateTime(2026, 7, 22, 2, 36);

  return TodoTask(
    id: id,
    ownerId: 'user-1',
    title: 'Task',
    description: 'Description',
    priority: TaskPriority.medium,
    dueDate: DateTime(2026, 7, 25),
    status: TaskStatus.pending,
    sortOrder: sortOrder,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}

TaskInput _input() {
  return TaskInput(
    title: 'New task',
    description: 'Description',
    priority: TaskPriority.medium,
    dueDate: DateTime(2026, 7, 25),
    status: TaskStatus.pending,
  );
}
