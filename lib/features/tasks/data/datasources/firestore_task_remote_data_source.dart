import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/app_exception.dart';
import '../../../auth/data/datasources/firebase_account_session_manager.dart';
import '../../domain/entities/task_input.dart';
import '../../domain/entities/task_sync_snapshot.dart';
import '../../domain/entities/todo_task.dart';
import '../models/task_model.dart';

abstract interface class TaskRemoteDataSource {
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

final class FirestoreTaskRemoteDataSource implements TaskRemoteDataSource {
  const FirestoreTaskRemoteDataSource(this._sessionManager);

  final FirebaseAccountSessionManager _sessionManager;

  CollectionReference<Map<String, dynamic>> _taskCollection(String userId) {
    return _sessionManager
        .firestoreForUser(userId)
        .collection('users')
        .doc(userId)
        .collection('tasks');
  }

  Query<Map<String, dynamic>> _orderedTasksQuery(String userId) {
    return _taskCollection(userId).orderBy('createdAt', descending: true);
  }

  @override
  Stream<TaskSyncSnapshot> watchTasks(String userId) {
    return _orderedTasksQuery(userId)
        .snapshots(includeMetadataChanges: true)
        .map(_syncSnapshotFromQuerySnapshot)
        .handleError((Object error) {
          throw _databaseException(error, 'Unable to load tasks.');
        });
  }

  @override
  Future<TaskSyncSnapshot> refreshTasks(String userId) async {
    try {
      final snapshot = await _orderedTasksQuery(
        userId,
      ).get(const GetOptions(source: Source.server));
      return _syncSnapshotFromQuerySnapshot(snapshot);
    } on FirebaseException catch (error) {
      throw _databaseException(error, 'Unable to sync tasks.');
    }
  }

  @override
  Future<void> createTask({
    required String userId,
    required TaskInput input,
    required int sortOrder,
  }) async {
    try {
      await _taskCollection(userId).add(
        TaskModel.createMap(userId: userId, input: input, sortOrder: sortOrder),
      );
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

  @override
  Future<void> reorderTasks({
    required String userId,
    required List<TodoTask> tasks,
  }) async {
    try {
      const batchLimit = 500;
      for (var start = 0; start < tasks.length; start += batchLimit) {
        final firestore = _sessionManager.firestoreForUser(userId);
        final batch = firestore.batch();
        final end = (start + batchLimit).clamp(0, tasks.length);

        for (var index = start; index < end; index++) {
          final task = tasks[index];
          batch.update(
            _taskCollection(userId).doc(task.id),
            TaskModel.sortOrderMap(task.sortOrder),
          );
        }

        await batch.commit();
      }
    } on FirebaseException catch (error) {
      throw _databaseException(error, 'Unable to reorder these tasks.');
    }
  }
}

TaskSyncSnapshot _syncSnapshotFromQuerySnapshot(
  QuerySnapshot<Map<String, dynamic>> snapshot,
) {
  return TaskSyncSnapshot(
    tasks: snapshot.docs.map(TaskModel.fromSnapshot).toList(),
    isFromCache: snapshot.metadata.isFromCache,
    hasPendingWrites: snapshot.metadata.hasPendingWrites,
  );
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
