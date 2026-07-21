extension AppDateTimeFormatter on DateTime {
  String toTaskDate() {
    final month = _monthNames[monthIndex];
    return '$month $day, $year';
  }

  String toTaskDateTime() {
    final hourValue = hourOfPeriod == 0 ? 12 : hourOfPeriod;
    final minuteValue = minute.toString().padLeft(2, '0');
    final meridiem = hour >= 12 ? 'PM' : 'AM';

    return '${toTaskDate()} at $hourValue:$minuteValue $meridiem';
  }

  int get monthIndex => month - 1;

  int get hourOfPeriod => hour % 12;
}

DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

bool isPastCalendarDate(DateTime date) {
  final today = dateOnly(DateTime.now());
  return dateOnly(date).isBefore(today);
}

const _monthNames = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
