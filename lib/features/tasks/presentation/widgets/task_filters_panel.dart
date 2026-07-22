import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_style.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/task_filters.dart';
import '../../domain/entities/todo_task.dart';
import '../bloc/tasks_bloc.dart';
import '../bloc/tasks_event.dart';
import '../bloc/tasks_state.dart';
import 'task_search_field.dart';
import 'task_visuals.dart';

class TaskFiltersPanel extends StatelessWidget {
  const TaskFiltersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TasksBloc, TasksState, TaskFilters>(
      selector: (state) => state.filters,
      builder: (context, filters) => _TaskFiltersContent(filters: filters),
    );
  }
}

class _TaskFiltersContent extends StatefulWidget {
  const _TaskFiltersContent({required this.filters});

  final TaskFilters filters;

  @override
  State<_TaskFiltersContent> createState() => _TaskFiltersContentState();
}

class _TaskFiltersContentState extends State<_TaskFiltersContent>
    with SingleTickerProviderStateMixin {
  static const _animationDuration = Duration(milliseconds: 220);

  bool _isExpanded = false;

  void _toggleFilters() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bloc = context.read<TasksBloc>();
    final filters = widget.filters;

    return DecoratedBox(
      decoration: AppTextStyle.raisedSurfaceDecoration(
        colorScheme,
        tintColor: colorScheme.primary,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Find work',
                    style: AppTextStyle.style16Bold.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: _isExpanded ? 'Hide filters' : 'Show filters',
                  onPressed: _toggleFilters,
                  icon: AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: _animationDuration,
                    curve: Curves.easeOutCubic,
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                ),
                if (filters.hasActiveFilters)
                  IconButton(
                    tooltip: 'Clear filters',
                    onPressed: () {
                      bloc
                        ..add(const TaskSearchChanged(''))
                        ..add(const TaskStatusFilterChanged(null))
                        ..add(const TaskPriorityFilterChanged(null))
                        ..add(const TaskSortChanged(TaskSortOption.manual));
                    },
                    icon: const Icon(Icons.filter_alt_off_outlined),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 760;
                final searchWidth = !_isExpanded
                    ? constraints.maxWidth
                    : isWide
                    ? (constraints.maxWidth * 0.34)
                          .clamp(280.0, 380.0)
                          .toDouble()
                    : constraints.maxWidth;
                final sectionWidth = isWide ? 292.0 : constraints.maxWidth;
                final sortWidth = isWide ? 360.0 : constraints.maxWidth;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    SizedBox(
                      width: searchWidth,
                      child: TaskSearchField(
                        query: filters.searchQuery,
                        onChanged: (query) =>
                            bloc.add(TaskSearchChanged(query)),
                      ),
                    ),
                    AnimatedSize(
                      duration: _animationDuration,
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topLeft,
                      child: _isExpanded
                          ? Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              children: [
                                SizedBox(
                                  width: sectionWidth,
                                  child: AppControlGroup(
                                    label: 'Status',
                                    child: _HorizontalFilterChips(
                                      children: [
                                        _filterChip(
                                          label: 'All',
                                          selected: filters.status == null,
                                          onSelected: () => bloc.add(
                                            const TaskStatusFilterChanged(null),
                                          ),
                                        ),
                                        ...TaskStatus.values.map(
                                          (status) => _filterChip(
                                            label: status.label,
                                            icon: taskStatusIcon(status),
                                            selected: filters.status == status,
                                            onSelected: () => bloc.add(
                                              TaskStatusFilterChanged(status),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: sectionWidth,
                                  child: AppControlGroup(
                                    label: 'Priority',
                                    child: _HorizontalFilterChips(
                                      children: [
                                        _filterChip(
                                          label: 'All',
                                          selected: filters.priority == null,
                                          onSelected: () => bloc.add(
                                            const TaskPriorityFilterChanged(
                                              null,
                                            ),
                                          ),
                                        ),
                                        ...TaskPriority.values.map(
                                          (priority) => _filterChip(
                                            label: priority.label,
                                            icon: Icons.flag_outlined,
                                            iconColor: taskPriorityColor(
                                              context,
                                              priority,
                                            ),
                                            selected:
                                                filters.priority == priority,
                                            onSelected: () => bloc.add(
                                              TaskPriorityFilterChanged(
                                                priority,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: sortWidth,
                                  child: AppControlGroup(
                                    label: 'Sort',
                                    child: AppSegmentedButton<TaskSortOption>(
                                      selectedValue: filters.sortOption,
                                      options: const [
                                        AppSegmentedOption<TaskSortOption>(
                                          value: TaskSortOption.manual,
                                          icon: Icon(Icons.drag_indicator),
                                          label: 'Manual',
                                        ),
                                        AppSegmentedOption<TaskSortOption>(
                                          value: TaskSortOption.dueDate,
                                          icon: Icon(Icons.event),
                                          label: 'Due',
                                        ),
                                        AppSegmentedOption<TaskSortOption>(
                                          value: TaskSortOption.createdDate,
                                          icon: Icon(Icons.schedule),
                                          label: 'Created',
                                        ),
                                      ],
                                      onChanged: (sortOption) {
                                        bloc.add(TaskSortChanged(sortOption));
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalFilterChips extends StatelessWidget {
  const _HorizontalFilterChips({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.only(right: 2),
        scrollDirection: Axis.horizontal,
        itemCount: children.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) => Center(child: children[index]),
      ),
    );
  }
}

Widget _filterChip({
  required String label,
  required bool selected,
  required VoidCallback onSelected,
  IconData? icon,
  Color? iconColor,
}) {
  return Builder(
    builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      final effectiveIconColor = selected
          ? colorScheme.onSecondaryContainer
          : iconColor ?? colorScheme.onSurfaceVariant;

      return ChoiceChip(
        visualDensity: VisualDensity.compact,
        showCheckmark: false,
        selected: selected,
        avatar: icon == null
            ? null
            : Icon(icon, size: 16, color: effectiveIconColor),
        label: Text(label),
        onSelected: (_) => onSelected(),
      );
    },
  );
}
