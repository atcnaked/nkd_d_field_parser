import '../range_v2_producer.dart';

const List<String> weekDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
const Map<String,int> numberOfweekDays = {'MON': 1, 'TUE': 2, 'WED': 3, 'THU': 4, 'FRI': 5, 'SAT':6, 'SUN':7};


/// the days of the week as numbers (MON =1, SUN=7) that are active
/// 
/// dayTokens must be a list of WeekDayLyRange or LoneWeekDayRange (else error)
(List<int>?, String?) getDatesFrom(List<XRangeV2> dayTokens) {
  if (dayTokens.isEmpty) {
    return (null, 'error in getDatesFrom, argument dateTokens is empty');
  }
  final res = <int>[];
  for (var element in dayTokens) {
    if (element is WeekDayLyRange) {
    final List<String>? daysToAdd=  getDaysBetween(element.start.word, element.end.word);

      if (daysToAdd == null ) {
        return (
          res,
          'error, can not parse days inside element: $element of dateTokens: $dayTokens',
        );
      }
      final List<int> enumerateds = daysToAdd.map((e)=>numberOfweekDays[e]! ).toList();
      res.addAll(enumerateds);
    } else if (element is LoneWeekDayRange) {
      final int nb = numberOfweekDays[element]!;
      
      res.add(nb);
      }
     else {
      return (
        res,
        '''error while producing days from tokens list, a token provided 
  may not be a day or a range of days, it is of type ${element.runtimeType}, element:$element.
  At this moment the list of dates built was: $res. 
  The input dateTokens was: $dayTokens''',
      );
    }
  }
  return (res, null);
}



















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

/// the weekdays from start to end (both included). Null if start = end
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
