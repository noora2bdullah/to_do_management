import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/task_input.dart';
import '../entities/todo_task.dart';
import '../repositories/task_repository.dart';

final class WatchTasksParams extends Equatable {
  const WatchTasksParams({required this.userId});

  final String userId;

  @override
  List<Object?> get props => [userId];
}

final class TaskWriteParams extends Equatable {
  const TaskWriteParams({required this.userId, required this.input});

  final String userId;
  final TaskInput input;

  @override
  List<Object?> get props => [userId, input];
}

final class UpdateTaskParams extends Equatable {
  const UpdateTaskParams({required this.userId, required this.task});

  final String userId;
  final TodoTask task;

  @override
  List<Object?> get props => [userId, task];
}

final class DeleteTaskParams extends Equatable {
  const DeleteTaskParams({required this.userId, required this.taskId});

  final String userId;
  final String taskId;

  @override
  List<Object?> get props => [userId, taskId];
}

final class ChangeTaskStatusParams extends Equatable {
  const ChangeTaskStatusParams({
    required this.userId,
    required this.taskId,
    required this.status,
  });

  final String userId;
  final String taskId;
  final TaskStatus status;

  @override
  List<Object?> get props => [userId, taskId, status];
}

final class WatchTasks extends StreamUseCase<List<TodoTask>, WatchTasksParams> {
  const WatchTasks(this._repository);

  final TaskRepository _repository;

  @override
  Stream<List<TodoTask>> call(WatchTasksParams params) {
    return _repository.watchTasks(params.userId);
  }
}

final class CreateTask extends UseCase<void, TaskWriteParams> {
  const CreateTask(this._repository);

  final TaskRepository _repository;

  @override
  Future<void> call(TaskWriteParams params) {
    return _repository.createTask(userId: params.userId, input: params.input);
  }
}

final class UpdateTask extends UseCase<void, UpdateTaskParams> {
  const UpdateTask(this._repository);

  final TaskRepository _repository;

  @override
  Future<void> call(UpdateTaskParams params) {
    return _repository.updateTask(userId: params.userId, task: params.task);
  }
}

final class DeleteTask extends UseCase<void, DeleteTaskParams> {
  const DeleteTask(this._repository);

  final TaskRepository _repository;

  @override
  Future<void> call(DeleteTaskParams params) {
    return _repository.deleteTask(userId: params.userId, taskId: params.taskId);
  }
}

final class ChangeTaskStatus extends UseCase<void, ChangeTaskStatusParams> {
  const ChangeTaskStatus(this._repository);

  final TaskRepository _repository;

  @override
  Future<void> call(ChangeTaskStatusParams params) {
    return _repository.changeTaskStatus(
      userId: params.userId,
      taskId: params.taskId,
      status: params.status,
    );
  }
}
