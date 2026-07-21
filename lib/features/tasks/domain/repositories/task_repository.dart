import '../entities/task_input.dart';
import '../entities/todo_task.dart';

abstract interface class TaskRepository {
  Stream<List<TodoTask>> watchTasks(String userId);

  Future<void> createTask({required String userId, required TaskInput input});

  Future<void> updateTask({required String userId, required TodoTask task});

  Future<void> deleteTask({required String userId, required String taskId});

  Future<void> changeTaskStatus({
    required String userId,
    required String taskId,
    required TaskStatus status,
  });
}
