import 'range_producer.dart';

Map<DateTime, List<DateTime>> getDecodedOf(
  List<XRange> ranges,
  DateTime b,
  DateTime c,
) {
  final List<DateTime> ruleDates;

  if (ranges.first is! TimeRange) {
    ruleDates = allDatesFrom(b, c);
  } else {
    ruleDates = [];
  }
  int year = b.year;
  int month = b.month;
  for (var xRange in ranges) {
// if TimeRange ...
// if date or date range
if (xRange is Date2Range) {
  ruleDates.add(datesFromDate2Range(xRange, year, month));
  continue;
}
if (xRange is MonthDayRange) {
  ruleDates.add(datesFromMonthDayRange(xRange, year, month));

}
if (xRange is WeekDayLyRange) {
  ruleDates.add(datesFromWeekDayLyRange(xRange, year, month));
}

  
}





  }
}

List<DateTime> allDatesFrom(DateTime b, DateTime c) {
}
