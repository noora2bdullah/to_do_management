import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/error/app_exception.dart' as app_error;
import '../../domain/entities/task_sync_snapshot.dart';
import '../../domain/entities/todo_task.dart';
import '../../domain/usecases/task_usecases.dart';
import 'tasks_event.dart';
import 'tasks_state.dart';

final class TasksBloc extends Bloc<TasksEvent, TasksState> {
  TasksBloc(
    this._watchTasks,
    this._refreshTasks,
    this._createTask,
    this._updateTask,
    this._deleteTask,
    this._changeTaskStatus,
    this._reorderTasks,
  ) : super(const TasksState()) {
    on<TasksSubscriptionRequested>(_onSubscriptionRequested);
    on<TasksRefreshRequested>(_onRefreshRequested);
    on<TasksLoaded>(_onTasksLoaded);
    on<TasksStreamFailed>(_onTasksStreamFailed);
    on<TaskCreated>(_onTaskCreated);
    on<TaskUpdated>(_onTaskUpdated);
    on<TaskDeleted>(_onTaskDeleted);
    on<TaskStatusChanged>(_onTaskStatusChanged);
    on<TasksReordered>(_onTasksReordered);
    on<TaskSearchChanged>(_onTaskSearchChanged);
    on<TaskStatusFilterChanged>(_onTaskStatusFilterChanged);
    on<TaskPriorityFilterChanged>(_onTaskPriorityFilterChanged);
    on<TaskSortChanged>(_onTaskSortChanged);
    on<TaskActionMessageCleared>(_onActionMessageCleared);
  }

  final WatchTasks _watchTasks;
  final RefreshTasks _refreshTasks;
  final CreateTask _createTask;
  final UpdateTask _updateTask;
  final DeleteTask _deleteTask;
  final ChangeTaskStatus _changeTaskStatus;
  final ReorderTasks _reorderTasks;

  StreamSubscription<TaskSyncSnapshot>? _tasksSubscription;
  int _reorderGeneration = 0;

  Future<void> _onSubscriptionRequested(
    TasksSubscriptionRequested event,
    Emitter<TasksState> emit,
  ) async {
    if (_tasksSubscription != null &&
        state.userId == event.userId &&
        state.loadStatus == TasksLoadStatus.success) {
      return;
    }

    await _tasksSubscription?.cancel();
    emit(
      state.copyWith(
        userId: event.userId,
        loadStatus: TasksLoadStatus.loading,
        clearLoadError: true,
      ),
    );

    _tasksSubscription = _watchTasks(WatchTasksParams(userId: event.userId))
        .listen(
          (snapshot) => add(
            TasksLoaded(
              snapshot.tasks,
              isSyncedWithServer: snapshot.isSyncedWithServer,
            ),
          ),
          onError: (Object error) =>
              add(TasksStreamFailed(exceptionMessage(error))),
        );
  }

  Future<void> _onRefreshRequested(
    TasksRefreshRequested event,
    Emitter<TasksState> emit,
  ) async {
    final userId = state.userId;
    if (userId == null) {
      return;
    }

    emit(
      state.copyWith(loadStatus: TasksLoadStatus.loading, clearLoadError: true),
    );

    try {
      final snapshot = await _refreshTasks(WatchTasksParams(userId: userId));
      emit(
        state.copyWith(
          tasks: snapshot.tasks,
          loadStatus: TasksLoadStatus.success,
          lastSyncedAt: DateTime.now(),
          clearLoadError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          loadStatus: TasksLoadStatus.failure,
          loadError: app_error.exceptionMessage(error),
        ),
      );
    }
  }

  void _onTasksLoaded(TasksLoaded event, Emitter<TasksState> emit) {
    final tasksChanged = !_areTaskListsEqual(state.tasks, event.tasks);
    final shouldTransitionToSuccess =
        state.loadStatus != TasksLoadStatus.success || state.loadError != null;
    final shouldUpdateSyncTime =
        event.isSyncedWithServer &&
        (tasksChanged ||
            shouldTransitionToSuccess ||
            state.lastSyncedAt == null);

    if (!tasksChanged && !shouldTransitionToSuccess && !shouldUpdateSyncTime) {
      return;
    }

    emit(
      state.copyWith(
        tasks: tasksChanged ? event.tasks : state.tasks,
        loadStatus: TasksLoadStatus.success,
        lastSyncedAt: shouldUpdateSyncTime
            ? DateTime.now()
            : state.lastSyncedAt,
        clearLoadError: true,
      ),
    );
  }

  void _onTasksStreamFailed(TasksStreamFailed event, Emitter<TasksState> emit) {
    emit(
      state.copyWith(
        loadStatus: TasksLoadStatus.failure,
        loadError: event.message,
      ),
    );
  }

  Future<void> _onTaskCreated(
    TaskCreated event,
    Emitter<TasksState> emit,
  ) async {
    final userId = _requireUserId();
    final sortOrder = _nextSortOrder(state.tasks);
    emit(_mutationLoadingState());

    try {
      await _createTask(
        TaskWriteParams(
          userId: userId,
          input: event.input,
          sortOrder: sortOrder,
        ),
      );
      emit(_mutationSuccessState('Task created.'));
    } catch (error) {
      emit(_mutationFailureState(error));
    }
  }

  Future<void> _onTaskUpdated(
    TaskUpdated event,
    Emitter<TasksState> emit,
  ) async {
    final userId = _requireUserId();
    emit(_mutationLoadingState());

    try {
      await _updateTask(UpdateTaskParams(userId: userId, task: event.task));
      emit(_mutationSuccessState('Task updated.'));
    } catch (error) {
      emit(_mutationFailureState(error));
    }
  }

  Future<void> _onTaskDeleted(
    TaskDeleted event,
    Emitter<TasksState> emit,
  ) async {
    final userId = _requireUserId();
    emit(_mutationLoadingState());

    try {
      await _deleteTask(DeleteTaskParams(userId: userId, taskId: event.taskId));
      emit(_mutationSuccessState('Task deleted.'));
    } catch (error) {
      emit(_mutationFailureState(error));
    }
  }

  Future<void> _onTaskStatusChanged(
    TaskStatusChanged event,
    Emitter<TasksState> emit,
  ) async {
    final userId = _requireUserId();
    emit(_mutationLoadingState());

    try {
      await _changeTaskStatus(
        ChangeTaskStatusParams(
          userId: userId,
          taskId: event.taskId,
          status: event.status,
        ),
      );
      emit(_mutationSuccessState('Status changed.'));
    } catch (error) {
      emit(_mutationFailureState(error));
    }
  }

  Future<void> _onTasksReordered(
    TasksReordered event,
    Emitter<TasksState> emit,
  ) async {
    if (state.filters.sortOption != TaskSortOption.manual ||
        state.filters.hasActiveFilters) {
      return;
    }

    final visibleTasks = state.visibleTasks;
    final newIndex = event.newIndex;

    if (event.oldIndex < 0 ||
        event.oldIndex >= visibleTasks.length ||
        newIndex < 0 ||
        newIndex >= visibleTasks.length ||
        event.oldIndex == newIndex) {
      return;
    }

    final userId = _requireUserId();
    final previousTasks = state.tasks;
    final reorderedTasks = List<TodoTask>.from(visibleTasks);
    final movedTask = reorderedTasks.removeAt(event.oldIndex);
    reorderedTasks.insert(newIndex, movedTask);

    final orderedTasks = [
      for (var index = 0; index < reorderedTasks.length; index++)
        reorderedTasks[index].copyWith(sortOrder: index),
    ];
    final reorderGeneration = ++_reorderGeneration;

    emit(
      state.copyWith(
        tasks: orderedTasks,
        mutationStatus: TasksMutationStatus.idle,
        clearActionMessage: true,
        clearActionError: true,
      ),
    );

    try {
      await _reorderTasks(
        ReorderTasksParams(userId: userId, tasks: orderedTasks),
      );
      if (reorderGeneration != _reorderGeneration) {
        return;
      }

      emit(
        state.copyWith(
          mutationStatus: TasksMutationStatus.idle,
          clearActionMessage: true,
          clearActionError: true,
        ),
      );
    } catch (error) {
      if (reorderGeneration != _reorderGeneration) {
        return;
      }

      emit(
        state.copyWith(
          tasks: previousTasks,
          mutationStatus: TasksMutationStatus.failure,
          actionError: app_error.exceptionMessage(error),
          clearActionMessage: true,
        ),
      );
    }
  }

  void _onTaskSearchChanged(TaskSearchChanged event, Emitter<TasksState> emit) {
    emit(
      state.copyWith(filters: state.filters.copyWith(searchQuery: event.query)),
    );
  }

  void _onTaskStatusFilterChanged(
    TaskStatusFilterChanged event,
    Emitter<TasksState> emit,
  ) {
    emit(
      state.copyWith(
        filters: state.filters.copyWith(
          status: event.status,
          clearStatus: event.status == null,
        ),
      ),
    );
  }

  void _onTaskPriorityFilterChanged(
    TaskPriorityFilterChanged event,
    Emitter<TasksState> emit,
  ) {
    emit(
      state.copyWith(
        filters: state.filters.copyWith(
          priority: event.priority,
          clearPriority: event.priority == null,
        ),
      ),
    );
  }

  void _onTaskSortChanged(TaskSortChanged event, Emitter<TasksState> emit) {
    emit(
      state.copyWith(
        filters: state.filters.copyWith(sortOption: event.sortOption),
      ),
    );
  }

  void _onActionMessageCleared(
    TaskActionMessageCleared event,
    Emitter<TasksState> emit,
  ) {
    emit(
      state.copyWith(
        mutationStatus: TasksMutationStatus.idle,
        clearActionMessage: true,
        clearActionError: true,
      ),
    );
  }

  TasksState _mutationLoadingState() {
    return state.copyWith(
      mutationStatus: TasksMutationStatus.loading,
      clearActionMessage: true,
      clearActionError: true,
    );
  }

  TasksState _mutationSuccessState(String message) {
    return state.copyWith(
      mutationStatus: TasksMutationStatus.success,
      actionMessage: message,
      clearActionError: true,
    );
  }

  TasksState _mutationFailureState(Object error) {
    return state.copyWith(
      mutationStatus: TasksMutationStatus.failure,
      actionError: app_error.exceptionMessage(error),
      clearActionMessage: true,
    );
  }

  String _requireUserId() {
    final userId = state.userId;
    if (userId == null) {
      throw const ValidationAppException('Sign in before editing tasks.');
    }

    return userId;
  }

  @override
  Future<void> close() async {
    await _tasksSubscription?.cancel();
    return super.close();
  }
}

bool _areTaskListsEqual(List<TodoTask> first, List<TodoTask> second) {
  if (identical(first, second)) {
    return true;
  }

  if (first.length != second.length) {
    return false;
  }

  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) {
      return false;
    }
  }

  return true;
}

int _nextSortOrder(List<TodoTask> tasks) {
  if (tasks.isEmpty) {
    return 0;
  }

  var highestSortOrder = tasks.first.sortOrder;
  for (final task in tasks.skip(1)) {
    if (task.sortOrder > highestSortOrder) {
      highestSortOrder = task.sortOrder;
    }
  }

  return highestSortOrder + 1;
}
