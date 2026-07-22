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
import '../widgets/task_form_action_bar.dart';
import '../widgets/task_form_panel.dart';

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
    FocusManager.instance.primaryFocus?.unfocus();
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
    FocusManager.instance.primaryFocus?.unfocus();
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
        appBar: AppBar(
          notificationPredicate: (_) => false,
          title: Text(_isEditing ? 'Edit task' : 'Create task'),
        ),
        bottomNavigationBar: TaskFormActionBar(
          isEditing: _isEditing,
          onSubmit: _submit,
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding = constraints.maxWidth >= 720
                      ? 24.0
                      : 16.0;

                  return Scrollbar(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        10,
                        horizontalPadding,
                        24,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: TaskFormPanel(
                            isEditing: _isEditing,
                            task: widget.task,
                            titleController: _titleController,
                            descriptionController: _descriptionController,
                            onPickDueDate: _pickDueDate,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
