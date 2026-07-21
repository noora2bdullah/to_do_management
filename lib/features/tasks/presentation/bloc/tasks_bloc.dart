import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/error/app_exception.dart' as app_error;
import '../../domain/entities/todo_task.dart';
import '../../domain/usecases/task_usecases.dart';
import 'tasks_event.dart';
import 'tasks_state.dart';

final class TasksBloc extends Bloc<TasksEvent, TasksState> {
  TasksBloc(
    this._watchTasks,
    this._createTask,
    this._updateTask,
    this._deleteTask,
    this._changeTaskStatus,
  ) : super(const TasksState()) {
    on<TasksSubscriptionRequested>(_onSubscriptionRequested);
    on<TasksRefreshRequested>(_onRefreshRequested);
    on<TasksLoaded>(_onTasksLoaded);
    on<TasksStreamFailed>(_onTasksStreamFailed);
    on<TaskCreated>(_onTaskCreated);
    on<TaskUpdated>(_onTaskUpdated);
    on<TaskDeleted>(_onTaskDeleted);
    on<TaskStatusChanged>(_onTaskStatusChanged);
    on<TaskSearchChanged>(_onTaskSearchChanged);
    on<TaskStatusFilterChanged>(_onTaskStatusFilterChanged);
    on<TaskPriorityFilterChanged>(_onTaskPriorityFilterChanged);
    on<TaskSortChanged>(_onTaskSortChanged);
    on<TaskActionMessageCleared>(_onActionMessageCleared);
  }

  final WatchTasks _watchTasks;
  final CreateTask _createTask;
  final UpdateTask _updateTask;
  final DeleteTask _deleteTask;
  final ChangeTaskStatus _changeTaskStatus;

  StreamSubscription<List<TodoTask>>? _tasksSubscription;

  Future<void> _onSubscriptionRequested(
    TasksSubscriptionRequested event,
    Emitter<TasksState> emit,
  ) async {
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
          (tasks) => add(TasksLoaded(tasks)),
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

    add(TasksSubscriptionRequested(userId: userId));
  }

  void _onTasksLoaded(TasksLoaded event, Emitter<TasksState> emit) {
    emit(
      state.copyWith(
        tasks: event.tasks,
        loadStatus: TasksLoadStatus.success,
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
    emit(_mutationLoadingState());

    try {
      await _createTask(TaskWriteParams(userId: userId, input: event.input));
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
