import '../../domain/entities/task_input.dart';
import '../../domain/entities/task_sync_snapshot.dart';
import '../../domain/entities/todo_task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/firestore_task_remote_data_source.dart';

final class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl(this._remoteDataSource);

  final TaskRemoteDataSource _remoteDataSource;

  @override
  Stream<TaskSyncSnapshot> watchTasks(String userId) {
    return _remoteDataSource.watchTasks(userId);
  }

  @override
  Future<TaskSyncSnapshot> refreshTasks(String userId) {
    return _remoteDataSource.refreshTasks(userId);
  }

  @override
  Future<void> createTask({
    required String userId,
    required TaskInput input,
    required int sortOrder,
  }) {
    return _remoteDataSource.createTask(
      userId: userId,
      input: input,
      sortOrder: sortOrder,
    );
  }

  @override
  Future<void> updateTask({required String userId, required TodoTask task}) {
    return _remoteDataSource.updateTask(userId: userId, task: task);
  }

  @override
  Future<void> deleteTask({required String userId, required String taskId}) {
    return _remoteDataSource.deleteTask(userId: userId, taskId: taskId);
  }

  @override
  Future<void> changeTaskStatus({
    required String userId,
    required String taskId,
    required TaskStatus status,
  }) {
    return _remoteDataSource.changeTaskStatus(
      userId: userId,
      taskId: taskId,
      status: status,
    );
  }

  @override
  Future<void> reorderTasks({
    required String userId,
    required List<TodoTask> tasks,
  }) {
    return _remoteDataSource.reorderTasks(userId: userId, tasks: tasks);
  }
}
