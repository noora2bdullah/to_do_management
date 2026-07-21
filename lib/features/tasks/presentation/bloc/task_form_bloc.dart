import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/todo_task.dart';
import 'task_form_event.dart';
import 'task_form_state.dart';

final class TaskFormBloc extends Bloc<TaskFormEvent, TaskFormState> {
  TaskFormBloc(TodoTask? task) : super(TaskFormState.fromTask(task)) {
    on<TaskFormTitleChanged>(
      (event, emit) => emit(state.copyWith(title: event.title)),
    );
    on<TaskFormDescriptionChanged>(
      (event, emit) => emit(state.copyWith(description: event.description)),
    );
    on<TaskFormPriorityChanged>(
      (event, emit) => emit(state.copyWith(priority: event.priority)),
    );
    on<TaskFormStatusChanged>(
      (event, emit) => emit(state.copyWith(status: event.status)),
    );
    on<TaskFormDueDateChanged>(
      (event, emit) => emit(state.copyWith(dueDate: event.dueDate)),
    );
  }
}
