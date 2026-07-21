import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/date_time_formatter.dart';
import '../../domain/entities/todo_task.dart';
import '../bloc/task_form_bloc.dart';
import '../bloc/task_form_event.dart';
import '../bloc/task_form_state.dart';
import '../bloc/tasks_bloc.dart';
import '../bloc/tasks_event.dart';
import '../bloc/tasks_state.dart';
import '../widgets/task_form_validators.dart';

class TaskFormPage extends StatelessWidget {
  const TaskFormPage({required this.task, super.key});

  final TodoTask? task;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TaskFormBloc(task),
      child: _TaskFormView(task: task),
    );
  }
}

class _TaskFormView extends StatefulWidget {
  const _TaskFormView({required this.task});

  final TodoTask? task;

  @override
  State<_TaskFormView> createState() => _TaskFormViewState();
}

class _TaskFormViewState extends State<_TaskFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );

    _titleController.addListener(() {
      context.read<TaskFormBloc>().add(
        TaskFormTitleChanged(_titleController.text),
      );
    });
    _descriptionController.addListener(() {
      context.read<TaskFormBloc>().add(
        TaskFormDescriptionChanged(_descriptionController.text),
      );
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate(DateTime? currentDate) async {
    final today = dateOnly(DateTime.now());
    final initialDate = currentDate != null && !isPastCalendarDate(currentDate)
        ? dateOnly(currentDate)
        : today;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 3650)),
    );

    if (!mounted || picked == null) {
      return;
    }

    context.read<TaskFormBloc>().add(TaskFormDueDateChanged(picked));
  }

  void _submit(TaskFormState formState) {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final task = widget.task;
    if (task == null) {
      context.read<TasksBloc>().add(TaskCreated(formState.input));
      return;
    }

    context.read<TasksBloc>().add(
      TaskUpdated(
        task.copyWith(
          title: formState.input.title,
          description: formState.input.description,
          priority: formState.input.priority,
          dueDate: formState.input.dueDate,
          status: formState.input.status,
          updatedAt: DateTime.now(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<TasksBloc, TasksState>(
      listenWhen: (previous, current) {
        return previous.mutationStatus != current.mutationStatus ||
            previous.actionError != current.actionError;
      },
      listener: (context, state) {
        if (state.mutationStatus == TasksMutationStatus.success) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.actionMessage ?? 'Saved.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          context.read<TasksBloc>().add(const TaskActionMessageCleared());
          Navigator.of(context).pop();
        }

        if (state.actionError != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.actionError!),
                behavior: SnackBarBehavior.floating,
              ),
            );
          context.read<TasksBloc>().add(const TaskActionMessageCleared());
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isEditing ? 'Edit task' : 'Create task')),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: BlocBuilder<TaskFormBloc, TaskFormState>(
                      builder: (context, formState) {
                        return Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Hero(
                                  tag: widget.task == null
                                      ? 'task-icon-new'
                                      : 'task-icon-${widget.task!.id}',
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.task_alt,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              TextFormField(
                                controller: _titleController,
                                textInputAction: TextInputAction.next,
                                maxLength: 100,
                                decoration: const InputDecoration(
                                  labelText: 'Title',
                                  prefixIcon: Icon(Icons.title),
                                ),
                                validator: TaskFormValidators.title,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _descriptionController,
                                minLines: 4,
                                maxLines: 7,
                                textInputAction: TextInputAction.newline,
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                  alignLabelWithHint: true,
                                  prefixIcon: Icon(Icons.notes_outlined),
                                ),
                                validator: TaskFormValidators.description,
                              ),
                              const SizedBox(height: 16),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final isWide = constraints.maxWidth >= 600;
                                  final priorityField =
                                      DropdownButtonFormField<TaskPriority>(
                                        initialValue: formState.priority,
                                        decoration: const InputDecoration(
                                          labelText: 'Priority',
                                          prefixIcon: Icon(Icons.flag_outlined),
                                        ),
                                        items: TaskPriority.values
                                            .map(
                                              (priority) => DropdownMenuItem(
                                                value: priority,
                                                child: Text(priority.label),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (priority) {
                                          if (priority == null) {
                                            return;
                                          }
                                          context.read<TaskFormBloc>().add(
                                            TaskFormPriorityChanged(priority),
                                          );
                                        },
                                      );
                                  final statusField =
                                      DropdownButtonFormField<TaskStatus>(
                                        initialValue: formState.status,
                                        decoration: const InputDecoration(
                                          labelText: 'Status',
                                          prefixIcon: Icon(Icons.timelapse),
                                        ),
                                        items: TaskStatus.values
                                            .map(
                                              (status) => DropdownMenuItem(
                                                value: status,
                                                child: Text(status.label),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (status) {
                                          if (status == null) {
                                            return;
                                          }
                                          context.read<TaskFormBloc>().add(
                                            TaskFormStatusChanged(status),
                                          );
                                        },
                                      );

                                  if (isWide) {
                                    return Row(
                                      children: [
                                        Expanded(child: priorityField),
                                        const SizedBox(width: 12),
                                        Expanded(child: statusField),
                                      ],
                                    );
                                  }

                                  return Column(
                                    children: [
                                      priorityField,
                                      const SizedBox(height: 12),
                                      statusField,
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              FormField<DateTime>(
                                key: ValueKey(
                                  formState.dueDate?.millisecondsSinceEpoch,
                                ),
                                initialValue: formState.dueDate,
                                validator: TaskFormValidators.dueDate,
                                builder: (field) {
                                  final value = field.value;
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () => _pickDueDate(value),
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Due Date',
                                        prefixIcon: const Icon(Icons.event),
                                        errorText: field.errorText,
                                      ),
                                      child: Text(
                                        value == null
                                            ? 'Select date'
                                            : value.toTaskDate(),
                                        style: theme.textTheme.bodyLarge,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              BlocBuilder<TasksBloc, TasksState>(
                                buildWhen: (previous, current) {
                                  return previous.mutationStatus !=
                                      current.mutationStatus;
                                },
                                builder: (context, tasksState) {
                                  final isSaving =
                                      tasksState.mutationStatus ==
                                      TasksMutationStatus.loading;

                                  return FilledButton.icon(
                                    onPressed: isSaving
                                        ? null
                                        : () => _submit(formState),
                                    icon: isSaving
                                        ? const SizedBox.square(
                                            dimension: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Icon(
                                            _isEditing
                                                ? Icons.save_outlined
                                                : Icons.add,
                                          ),
                                    label: Text(_isEditing ? 'Save' : 'Create'),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
