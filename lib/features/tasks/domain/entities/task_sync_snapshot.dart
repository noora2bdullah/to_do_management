import 'package:equatable/equatable.dart';

import 'todo_task.dart';

final class TaskSyncSnapshot extends Equatable {
  const TaskSyncSnapshot({
    required this.tasks,
    required this.isFromCache,
    required this.hasPendingWrites,
  });

  final List<TodoTask> tasks;
  final bool isFromCache;
  final bool hasPendingWrites;

  bool get isSyncedWithServer => !isFromCache && !hasPendingWrites;

  @override
  List<Object?> get props => [tasks, isFromCache, hasPendingWrites];
}
