import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/task_input.dart';
import '../../domain/entities/todo_task.dart';

final class TaskModel extends TodoTask {
  const TaskModel({
    required super.id,
    required super.ownerId,
    required super.title,
    required super.description,
    required super.priority,
    required super.dueDate,
    required super.status,
    required super.sortOrder,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TaskModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    final now = DateTime.now();
    final createdAt = _dateFromValue(data['createdAt']) ?? now;
    final updatedAt = _dateFromValue(data['updatedAt']) ?? now;

    return TaskModel(
      id: snapshot.id,
      ownerId: data['ownerId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      priority: taskPriorityFromName(data['priority'] as String?),
      dueDate: _dateFromValue(data['dueDate']) ?? now,
      status: taskStatusFromName(data['status'] as String?),
      sortOrder:
          _sortOrderFromValue(data['sortOrder']) ??
          -createdAt.millisecondsSinceEpoch,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static Map<String, Object?> createMap({
    required String userId,
    required TaskInput input,
    required int sortOrder,
  }) {
    return {
      'ownerId': userId,
      'title': input.title.trim(),
      'description': input.description.trim(),
      'priority': input.priority.name,
      'dueDate': Timestamp.fromDate(input.dueDate),
      'status': input.status.name,
      'sortOrder': sortOrder,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, Object?> updateMap(TodoTask task) {
    return {
      'ownerId': task.ownerId,
      'title': task.title.trim(),
      'description': task.description.trim(),
      'priority': task.priority.name,
      'dueDate': Timestamp.fromDate(task.dueDate),
      'status': task.status.name,
      'sortOrder': task.sortOrder,
      'createdAt': Timestamp.fromDate(task.createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, Object?> statusMap(TaskStatus status) {
    return {'status': status.name, 'updatedAt': FieldValue.serverTimestamp()};
  }

  static Map<String, Object?> sortOrderMap(int sortOrder) {
    return {'sortOrder': sortOrder};
  }
}

DateTime? _dateFromValue(Object? value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }

  return null;
}

int? _sortOrderFromValue(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }

  return null;
}
