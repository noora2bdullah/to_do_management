import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../domain/entities/todo_task.dart';
import 'task_dashboard_header.dart';
import 'task_filters_panel.dart';
import 'task_list_summary.dart';
import 'tasks_sliver.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({
    required this.onRefresh,
    required this.onCreateTask,
    required this.onEditTask,
    required this.onDeleteTask,
    super.key,
  });

  final Future<void> Function() onRefresh;
  final VoidCallback onCreateTask;
  final ValueChanged<TodoTask> onEditTask;
  final ValueChanged<TodoTask> onDeleteTask;

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _isReorderModeEnabled = false;

  void _setReorderModeEnabled(bool value) {
    setState(() {
      _isReorderModeEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 720 ? 24.0 : 16.0;
        final bottomPadding = MediaQuery.paddingOf(context).bottom + 96;

        return RefreshIndicator(
          onRefresh: widget.onRefresh,
          notificationPredicate: _isTopEdgeScrollNotification,
          child: CustomScrollView(
            scrollCacheExtent: const ScrollCacheExtent.pixels(720),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  8,
                  horizontalPadding,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TaskDashboardHeader(
                            onCreateTask: widget.onCreateTask,
                          ),
                          const SizedBox(height: 16),
                          const TaskFiltersPanel(),
                          const SizedBox(height: 18),
                          TaskListSummary(
                            isReorderModeEnabled: _isReorderModeEnabled,
                            onReorderModeChanged: _setReorderModeEnabled,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              TasksSliver(
                horizontalPadding: horizontalPadding,
                bottomPadding: bottomPadding,
                maxWidth: 1120,
                isReorderModeEnabled: _isReorderModeEnabled,
                onCreateTask: widget.onCreateTask,
                onEditTask: widget.onEditTask,
                onDeleteTask: widget.onDeleteTask,
              ),
            ],
          ),
        );
      },
    );
  }
}

bool _isTopEdgeScrollNotification(ScrollNotification notification) {
  return defaultScrollNotificationPredicate(notification) &&
      notification.metrics.axis == Axis.vertical &&
      notification.metrics.extentBefore == 0;
}
