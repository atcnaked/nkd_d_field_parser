const List<String> weekDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

/// allows to get the weekdays between any pair of days.
const List<String> weekDaysLoop = [
  ...weekDays,
  ...weekDays,
  'dummyForIndexExcess',
];

const Map<String, String> days = {
  'MON': 'monday',
  'TUE': 'tuesday',
  'WED': 'wednesday',
  'THU': 'thursday',
  'FRI': 'friday',
  'SAT': 'saturday',
  'SUN': 'sunday',
  'DAILY': 'any',
  'DLY': 'any',
};

final String dayRe = '(?:${days.keys.join('|')})';

/// the weekdays from start to end (both included)
List<String>? getDaysBetween(String start, String end) {
  if (start == end) {
    return null;
  }

  final startIndex = weekDaysLoop.indexWhere((e) => start == e);
  final endIndex = weekDaysLoop.indexWhere((e) => end == e);
  if (startIndex == -1 || endIndex == -1) {
    return null;
  }
  return weekDaysLoop.sublist(startIndex, endIndex + 1);
}
