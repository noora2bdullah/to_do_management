import '../../../../core/utils/date_time_formatter.dart';

abstract final class TaskFormValidators {
  static String? title(String? value) {
    final title = value?.trim() ?? '';
    if (title.isEmpty) {
      return 'Title is required.';
    }
    if (title.length > 100) {
      return 'Title must be 100 characters or fewer.';
    }

    return null;
  }

  static String? description(String? value) {
    final description = value?.trim() ?? '';
    if (description.isEmpty) {
      return 'Description is required.';
    }

    return null;
  }

  static String? dueDate(DateTime? value) {
    if (value == null) {
      return 'Due date is required.';
    }
    if (isPastCalendarDate(value)) {
      return 'Due date cannot be in the past.';
    }

    return null;
  }
}
