import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_widgets.dart';
import '../bloc/task_form_bloc.dart';
import '../bloc/task_form_state.dart';
import '../bloc/tasks_bloc.dart';
import '../bloc/tasks_state.dart';

class TaskFormActionBar extends StatelessWidget {
  const TaskFormActionBar({
    required this.isEditing,
    required this.onSubmit,
    super.key,
  });

  final bool isEditing;
  final ValueChanged<TaskFormState> onSubmit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: colorScheme.brightness == Brightness.dark ? 0.36 : 0.1,
              ),
              blurRadius: 20,
              offset: const Offset(0, -8),
              spreadRadius: -10,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: BlocBuilder<TasksBloc, TasksState>(
            buildWhen: (previous, current) {
              return previous.mutationStatus != current.mutationStatus;
            },
            builder: (context, tasksState) {
              final isSaving =
                  tasksState.mutationStatus == TasksMutationStatus.loading;

              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isSaving
                          ? null
                          : () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close),
                      label: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: AppFilledActionButton(
                      isLoading: isSaving,
                      onPressed: () =>
                          onSubmit(context.read<TaskFormBloc>().state),
                      icon: Icon(isEditing ? Icons.save_outlined : Icons.add),
                      label: Text(isEditing ? 'Save' : 'Create'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
