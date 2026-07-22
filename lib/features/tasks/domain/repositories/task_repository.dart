import '../entities/task_input.dart';
import '../entities/task_sync_snapshot.dart';
import '../entities/todo_task.dart';

abstract interface class TaskRepository {
  Stream<TaskSyncSnapshot> watchTasks(String userId);

  Future<TaskSyncSnapshot> refreshTasks(String userId);

  Future<void> createTask({
    required String userId,
    required TaskInput input,
    required int sortOrder,
  });

  Future<void> updateTask({required String userId, required TodoTask task});

  Future<void> deleteTask({required String userId, required String taskId});

  Future<void> changeTaskStatus({
    required String userId,
    required String taskId,
    required TaskStatus status,
  });

  Future<void> reorderTasks({
    required String userId,
    required List<TodoTask> tasks,
  });
}
