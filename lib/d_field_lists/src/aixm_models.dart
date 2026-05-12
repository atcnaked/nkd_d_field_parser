
class AixmTime {
  final String? time;
  final String? event; // 'sunrise' or 'sunset'
  final int delta; // PLUS/MINUS minutes

  const AixmTime.literal(this.time) : event = null, delta = 0;
  const AixmTime.event(this.event, {this.delta = 0}) : time = null;

  static const beginningOfDay = AixmTime.literal('00:00');
  static const endOfDay = AixmTime.literal(
    '23:59',
  ); // AIXM uses 24:00 internally, but 23:59 is standard for Dart

  @override
  String toString() =>
      time ?? '$event${delta != 0 ? ' ${delta > 0 ? '+' : ''}$delta' : ''}';
}

class AixmDate {
  final DateTime date;
  AixmDate(this.date);

  AixmDate get next => AixmDate(date.add(const Duration(days: 1)));
  AixmDate get prev => AixmDate(date.subtract(const Duration(days: 1)));

  @override
  String toString() =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AixmDate && date == other.date;
  @override
  int get hashCode => date.hashCode;
}

class AixmDay {
  final String dayName;
  const AixmDay(this.dayName);

  static const any = AixmDay('any');
  @override
  String toString() => dayName;
}

class AixmRange<T> {
  final T start;
  final T end;
  const AixmRange(this.start, this.end);
  @override
  String toString() => '$start..$end';
}
