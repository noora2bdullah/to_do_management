import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/task_input.dart';
import '../../domain/entities/todo_task.dart';
import '../models/task_model.dart';

abstract interface class TaskRemoteDataSource {
  Stream<List<TaskModel>> watchTasks(String userId);

  Future<void> createTask({required String userId, required TaskInput input});

  Future<void> updateTask({required String userId, required TodoTask task});

  Future<void> deleteTask({required String userId, required String taskId});

  Future<void> changeTaskStatus({
    required String userId,
    required String taskId,
    required TaskStatus status,
  });
}

final class FirestoreTaskRemoteDataSource implements TaskRemoteDataSource {
  const FirestoreTaskRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _taskCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  @override
  Stream<List<TaskModel>> watchTasks(String userId) {
    return _taskCollection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(TaskModel.fromSnapshot).toList())
        .handleError((Object error) {
          throw _databaseException(error, 'Unable to load tasks.');
        });
  }

  @override
  Future<void> createTask({
    required String userId,
    required TaskInput input,
  }) async {
    try {
      await _taskCollection(
        userId,
      ).add(TaskModel.createMap(userId: userId, input: input));
    } on FirebaseException catch (error) {
      throw _databaseException(error, 'Unable to create this task.');
    }
  }

  @override
  Future<void> updateTask({
    required String userId,
    required TodoTask task,
  }) async {
    try {
      await _taskCollection(
        userId,
      ).doc(task.id).update(TaskModel.updateMap(task));
    } on FirebaseException catch (error) {
      throw _databaseException(error, 'Unable to update this task.');
    }
  }

  @override
  Future<void> deleteTask({
    required String userId,
    required String taskId,
  }) async {
    try {
      await _taskCollection(userId).doc(taskId).delete();
    } on FirebaseException catch (error) {
      throw _databaseException(error, 'Unable to delete this task.');
    }
  }

  @override
  Future<void> changeTaskStatus({
    required String userId,
    required String taskId,
    required TaskStatus status,
  }) async {
    try {
      await _taskCollection(
        userId,
      ).doc(taskId).update(TaskModel.statusMap(status));
    } on FirebaseException catch (error) {
      throw _databaseException(error, 'Unable to change this task status.');
    }
  }
}

DatabaseAppException _databaseException(Object error, String fallback) {
  if (error is FirebaseException) {
    final message = switch (error.code) {
      'permission-denied' =>
        'You do not have permission to access these tasks.',
      'unavailable' => 'Firestore is unavailable. Please try again shortly.',
      'not-found' => 'This task no longer exists.',
      _ => fallback,
    };

    return DatabaseAppException(message, code: error.code);
  }

  return DatabaseAppException(fallback);
}
