// ignore_for_file: public_member_api_docs, sort_constructors_first
class ParseResult {

final List<DateTS> dateTss;

  ParseResult({
    required this.dateTss,
  });




  @override
  String toString() => 'ParseResult(dateTss: $dateTss)';
}

class DateTS {
  final DateTime date;
 final List<DateTime> timeSlots;
  DateTS({
    required this.date,
    required this.timeSlots,
  });
}


ParseResult dParse(String dField) {
  return ParseResult(dateTss: []);
}

