import 'package:collection/collection.dart'; // Used for sliceWhen equivalent

/// --- MOCK AIXM CLASSES ---
/// These classes mimic the behavior of the Ruby AIXM gem used in the original script
/// so that the parsing logic remains structurally identical.

class AixmTime {
  final String? time;
  final String? event; // 'sunrise' or 'sunset'
  final int delta; // PLUS/MINUS minutes

  const AixmTime.literal(this.time) : event = null, delta = 0;
  const AixmTime.event(this.event, {this.delta = 0}) : time = null;

  static const beginningOfDay = AixmTime.literal('00:00');
  static const endOfDay = AixmTime.literal('23:59'); // AIXM uses 24:00 internally, but 23:59 is standard for Dart

  @override
  String toString() => time ?? '$event${delta != 0 ? ' ${delta > 0 ? '+' : ''}$delta' : ''}';
}

class AixmDate {
  final DateTime date;
  AixmDate(this.date);

  AixmDate get next => AixmDate(date.add(const Duration(days: 1)));
  AixmDate get prev => AixmDate(date.subtract(const Duration(days: 1)));

  @override
  String toString() => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  
  @override
  bool operator ==(Object other) => identical(this, other) || other is AixmDate && date == other.date;
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


/// --- MAIN NOTAM SCHEDULE CLASS ---
/// Translated from NOTAM::Schedule

class NotamSchedule {
  // 1. Constants
  static const Map<String, String> events = {'SR': 'sunrise', 'SS': 'sunset'};
  static const Map<String, AixmTime> eventHours = {
    'sunrise': AixmTime.literal('06:00'), 
    'sunset': AixmTime.literal('18:00')
  };
  static const Map<String, int> operations = {'PLUS': 1, 'MINUS': -1};
  static const Map<String, int> months = {
    'JAN': 1, 'FEB': 2, 'MAR': 3, 'APR': 4, 'MAY': 5, 'JUN': 6, 
    'JUL': 7, 'AUG': 8, 'SEP': 9, 'OCT': 10, 'NOV': 11, 'DEC': 12
  };
  static const Map<String, String> days = {
    'MON': 'monday', 'TUE': 'tuesday', 'WED': 'wednesday', 'THU': 'thursday', 
    'FRI': 'friday', 'SAT': 'saturday', 'SUN': 'sunday', 'DAILY': 'any', 'DLY': 'any'
  };

  // 2. Regex Patterns
  static const String dateRe = r'(?:[0-2]\d|3[01])';
  static final String dayRe = '(?:${days.keys.join('|')})';
  static final String monthRe = '(?:${months.keys.join('|')})';
  static const String hcodeRe = r'(?<hcode>H24|HJ|HN)';
  static const String hourRe = r'(?<hour>[01]\d|2[0-4])(?<minute>[0-5]\d)';
  static final String operationsRe = '(?:${operations.keys.join('|')})';
  static final String eventRe = '(?<event>SR|SS)(?:\\s(?<operation>$operationsRe)(?<delta>\\d+))?';
  static final String timeRe = '(?:$hourRe|$eventRe)';
  static final String timeRangeRe = '(?:$timeRe-$timeRe|$hcodeRe)';
  static final String datetimeRe = '(?:(?<month>$monthRe) )?(?<date>$dateRe) (?<time>$timeRe)';
  static final String datetimeRangeRe = '$datetimeRe-$datetimeRe';

  static const AixmRange<AixmTime> h24 = AixmRange(AixmTime.beginningOfDay, AixmTime.endOfDay);
  static final AixmRange<AixmTime> hj = AixmRange(AixmTime.event('sunrise'), AixmTime.event('sunset'));
  static final AixmRange<AixmTime> hn = AixmRange(AixmTime.event('sunset'), AixmTime.event('sunrise'));

  // 3. Properties
  final List<dynamic> actives; // Array of AixmDate, AixmDay, or AixmRange
  final List<dynamic> times;   // Array of AixmTime or AixmRange<AixmTime>
  final List<dynamic> inactives; 
  final DateTime baseDate;

  NotamSchedule._({
    required this.actives,
    required this.times,
    required this.inactives,
    required this.baseDate,
  });

  @override
  String toString() {
    return 'NotamSchedule(actives: $actives, times: $times, inactives: $inactives)';
  }

  // --- PARSING LOGIC ---

  /// Parse the schedule part of a D item.
  static List<NotamSchedule> parse(String string, {required DateTime baseDate}) {
    final cleaned = _cleanup(string);
    final parts = cleaned.split(RegExp(r' EXC '));
    final rules = parts[0].trim();
    final exceptions = parts.length > 1 ? parts[1].trim() : '';
    
    // Force day to 1 as per Ruby logic `base_date.at(day: 1)`
    final normalizedBaseDate = DateTime(baseDate.year, baseDate.month, 1);

    if (RegExp('^$datetimeRangeRe\$').hasMatch(rules)) {
      return _parseDatetimes(rules, exceptions, normalizedBaseDate);
    } else if (RegExp('^($dayRe|$timeRangeRe)').hasMatch(rules)) {
      return _parseUnit(rules, exceptions, normalizedBaseDate, isDays: true);
    } else if (RegExp('^($dateRe|$monthRe)').hasMatch(rules)) {
      return _parseUnit(rules, exceptions, normalizedBaseDate, isDays: false);
    } else {
      throw FormatException('Unrecognized schedule: $rules');
    }
  }

  static String _cleanup(String string) {
    return string
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r' *- *'), '-')
        .trim();
  }


  // Handles: parse_days and parse_dates logic from Ruby
  static List<NotamSchedule> _parseUnit(String rules, String exceptions, DateTime baseDate, {required bool isDays}) {
    // Split on time range. In Dart, we use a regex match to find where the time starts
    final timeMatch = RegExp(timeRangeRe).firstMatch(rules);
    if (timeMatch == null) throw FormatException('No time found in rules');

    final rawActiveUnit = rules.substring(0, timeMatch.start).trim();
    final rawTimes = rules.substring(timeMatch.start).trim();

    final actives = isDays ? _daysFrom(rawActiveUnit) : _datesFrom(rawActiveUnit, baseDate);
    final times = _timesFrom(rawTimes);
    final inactives = isDays ? _datesFrom(exceptions, baseDate) : _daysFrom(exceptions);

    List<NotamSchedule> results = [];
    
    bool hasMidnightCross = times.any((t) => t is AixmRange<AixmTime> && _acrossMidnight(t));

    if (hasMidnightCross) {
      for (var time in times) {
        if (time is AixmRange<AixmTime> && _acrossMidnight(time)) {
          // Split block at midnight
          results.add(NotamSchedule._(
            actives: actives,
            times: [AixmRange(time.start, AixmTime.endOfDay)],
            inactives: inactives,
            baseDate: baseDate,
          ));
          // Dart equivalent of `actives.next` (shifting days forward)
          results.add(NotamSchedule._(
            actives: _shiftNext(actives),
            times: [AixmRange(AixmTime.beginningOfDay, time.end)],
            inactives: inactives,
            baseDate: baseDate,
          ));
        } else {
          results.add(NotamSchedule._(actives: actives, times: [time], inactives: inactives, baseDate: baseDate));
        }
      }
    } else {
      results.add(NotamSchedule._(actives: actives, times: times, inactives: inactives, baseDate: baseDate));
    }

    return results;
  }

  static List<NotamSchedule> _parseDatetimes(String rules, String exceptions, DateTime baseDate) {
    // 1. Split rules into 'from' and 'to' strings
    final parts = rules.split('-');
    if (parts.length != 2) {
      throw FormatException('Invalid datetime range format: $rules');
    }

    // 2. Parse the individual from and to datetime components
    final from = _datetimeFrom(parts[0].trim(), baseDate);
    final to = _datetimeFrom(parts[1].trim(), baseDate);

    // Calculate the delta in days (ignoring the exact time)
    final fromDateOnly = DateTime(from.date.year, from.date.month, from.date.day);
    final toDateOnly = DateTime(to.date.year, to.date.month, to.date.day);
    final delta = toDateOnly.difference(fromDateOnly).inDays;

    if (delta < 1) {
      throw FormatException('Invalid datetime range: delta is less than 1 day ($rules)');
    }

    // 3. Parse exceptions. Since active units are Dates, OPADD dictates exceptions must be Days.
    final inactives = _daysFrom(exceptions);

    final List<NotamSchedule> results = [];

    // Block 1: The Start Day (From start time until End of Day)
    results.add(NotamSchedule._(
      actives: [AixmDate(fromDateOnly)],
      times: [AixmRange(from.time, AixmTime.endOfDay)],
      inactives: inactives,
      baseDate: baseDate,
    ));

    // Block 2: The Middle Days (If there is more than 1 day difference)
    if (delta > 1) {
      final nextDay = fromDateOnly.add(const Duration(days: 1));
      final prevDay = toDateOnly.subtract(const Duration(days: 1));
      
      results.add(NotamSchedule._(
        actives: [AixmRange(AixmDate(nextDay), AixmDate(prevDay))],
        times: [h24], // h24 represents 00:00 to 23:59
        inactives: inactives,
        baseDate: baseDate,
      ));
    }

    // Block 3: The End Day (From Beginning of Day until end time)
    results.add(NotamSchedule._(
      actives: [AixmDate(toDateOnly)],
      times: [AixmRange(AixmTime.beginningOfDay, to.time)],
      inactives: inactives,
      baseDate: baseDate,
    ));

    return results;
  }

  /// Helper to extract both the Date and Time from a string like "JAN 01 0800" or "05 SR"
  static _ParsedDateTime _datetimeFrom(String string, DateTime baseDate) {
    final match = RegExp('^$datetimeRe\$').firstMatch(string);
    if (match == null) {
      throw FormatException('Unrecognized datetime: $string');
    }

    final monthStr = match.namedGroup('month');
    final dateStr = match.namedGroup('date');
    final timeStr = match.namedGroup('time');

    // If month is omitted (e.g. "05 0800"), use the baseDate's month
    final month = monthStr != null ? months[monthStr]! : baseDate.month;
    final day = int.parse(dateStr!);
    
    final date = DateTime(baseDate.year, month, day);
    final time = _timeFrom(timeStr!);

    return _ParsedDateTime(date, time);
  }



/* 
  static List<NotamSchedule> _parseDatetimes(String rules, String exceptions, DateTime baseDate) {
    // Simplified representation for datetime ranges
    throw UnimplementedError('parseDatetimes requires full DateTime range parsing implementation.');
  }
 */
  // --- TOKEN EXTRACTORS ---
static List<dynamic> _datesFrom(String string, DateTime baseDate) {
    if (string.isEmpty) return [];
    List<dynamic> array = [];
    
    int index = 0;
    while (index < string.length) {
      // Get the remaining string and strip leading spaces
      final remaining = string.substring(index).trimLeft();
      if (remaining.isEmpty) break;

      // 1. Check for Date Range (with optional month shift inside!)
      // Matches: "01-05" OR "30-FEB 02"
      final rangeMatch = RegExp('^(?<from>$dateRe)-(?:(?<month>$monthRe) )?(?<to>$dateRe)').firstMatch(remaining);
      if (rangeMatch != null) {
        final fromDay = int.parse(rangeMatch.namedGroup('from')!);
        final toDay = int.parse(rangeMatch.namedGroup('to')!);
        final monthStr = rangeMatch.namedGroup('month');
        
        final startMonth = baseDate.month;
        // If the range has a month (e.g. 30-FEB 02), shift the end month!
        final endMonth = monthStr != null ? months[monthStr]! : baseDate.month;

        array.add(AixmRange(
          AixmDate(DateTime(baseDate.year, startMonth, fromDay)),
          AixmDate(DateTime(baseDate.year, endMonth, toDay))
        ));
        
    
        // Advance the index by the length of the matched string
        index += remaining.length - remaining.substring(rangeMatch.end).length;
        continue;
      }

      // 2. Check for Single Date
      // Matches: "15" or "01"
      final dateMatch = RegExp('^(?<day>$dateRe)').firstMatch(remaining);
      if (dateMatch != null) {
         array.add(AixmDate(DateTime(baseDate.year, baseDate.month, int.parse(dateMatch.namedGroup('day')!))));
         index += remaining.length - remaining.substring(dateMatch.end).length;
         continue;
      }

      // 3. Check for Month (The Context Shift)
      // Matches: "JAN" or "FEB"
      final monthMatch = RegExp('^(?<month>$monthRe)').firstMatch(remaining);
      if (monthMatch != null) {
         final newMonth = months[monthMatch.namedGroup('month')!]!;
         // Shift the baseDate forward to this new month!
         baseDate = DateTime(baseDate.year, newMonth, 1);
         index += remaining.length - remaining.substring(monthMatch.end).length;
         continue;
      }

      throw FormatException('Unrecognized date formatting at: $remaining');
    }
    
    return array;
  }

/// v1, deos not handle month shifts
  static List<dynamic> _datesFrom_v1(String string, DateTime baseDate) {
    if (string.isEmpty) return [];
    List<dynamic> array = [];
    
    // Simplistic tokenizing for dates: 01-05 or 04
    final tokens = string.split(' ');
    for (var token in tokens) {
      if (token.contains('-')) {
        final parts = token.split('-');
        if (parts.length == 2 && RegExp(dateRe).hasMatch(parts[0]) && RegExp(dateRe).hasMatch(parts[1])) {
           array.add(AixmRange(
             AixmDate(DateTime(baseDate.year, baseDate.month, int.parse(parts[0]))),
             AixmDate(DateTime(baseDate.year, baseDate.month, int.parse(parts[1])))
           ));
        }
      } else if (RegExp('^$dateRe\$').hasMatch(token)) {
        array.add(AixmDate(DateTime(baseDate.year, baseDate.month, int.parse(token))));
      } else if (months.containsKey(token)) {
         baseDate = DateTime(baseDate.year, months[token]!, 1);
      }
    }
    return array;
  }

  static List<dynamic> _daysFrom(String string) {
    if (string.isEmpty) return [AixmDay.any];
    List<dynamic> array = [];
    
    final tokens = string.split(' ');
    for (var token in tokens) {
      final parts = token.split('-');
      if (parts.length == 2) {
        array.add(AixmRange(AixmDay(days[parts[0]]!), AixmDay(days[parts[1]]!)));
      } else {
        array.add(AixmDay(days[parts[0]]!));
      }
    }
    return array;
  }

  static List<dynamic> _timesFrom(String string) {
    // Split by spaces that are NOT preceded by PLUS/MINUS
    final tokens = string.split(RegExp(r' (?!(?:PLUS|MINUS))'));
    return tokens.map((t) => _timeRangeFrom(t)).toList();
  }

  static dynamic _timeRangeFrom(String string) {
    final hcodeMatch = RegExp('^$hcodeRe\$').firstMatch(string);
    if (hcodeMatch != null) {
      final hcode = hcodeMatch.namedGroup('hcode');
      if (hcode == 'H24') return h24;
      if (hcode == 'HJ') return hj;
      if (hcode == 'HN') return hn;
    }

    final parts = string.split('-');
    if (parts.length == 2) {
      return AixmRange(_timeFrom(parts[0]), _timeFrom(parts[1]));
    }
    return _timeFrom(string);
  }

  static AixmTime _timeFrom(String string) {
    final hourMatch = RegExp('^$hourRe\$').firstMatch(string);
    if (hourMatch != null) {
      final h = hourMatch.namedGroup('hour');
      final m = hourMatch.namedGroup('minute');
      return AixmTime.literal('$h:$m');
    }

    final eventMatch = RegExp('^$eventRe\$').firstMatch(string);
    if (eventMatch != null) {
      final event = eventMatch.namedGroup('event');
      final operation = eventMatch.namedGroup('operation');
      final delta = eventMatch.namedGroup('delta');
      
      int deltaInt = 0;
      if (operation != null && delta != null) {
        deltaInt = (operations[operation] ?? 1) * int.parse(delta);
      }
      return AixmTime.event(events[event], delta: deltaInt);
    }
    throw FormatException('Unrecognized time format: $string');
  }

  // --- HELPERS ---

  static bool _acrossMidnight(AixmRange<AixmTime> range) {
    // Simplified logic: Since we don't have a solar resolver in Dart,
    // we only check literal times for midnight crosses (e.g. 22:00 > 05:00)
    final from = range.start.time;
    final to = range.end.time;
    
    if (from != null && to != null) {
       final fromMinutes = int.parse(from.split(':')[0]) * 60 + int.parse(from.split(':')[1]);
       final toMinutes = int.parse(to.split(':')[0]) * 60 + int.parse(to.split(':')[1]);
       return fromMinutes > toMinutes;
    }
    return false; // Cannot statically determine if SR/SS crosses midnight
  }

  static List<dynamic> _shiftNext(List<dynamic> activeArray) {
    return activeArray.map((entry) {
      if (entry is AixmDate) return entry.next;
      if (entry is AixmRange<AixmDate>) return AixmRange(entry.start.next, entry.end.next);
      return entry; // Shifting days of week requires complex enum mapping omitted for brevity
    }).toList();
  }

  
}


class _ParsedDateTime {
  final DateTime date;
  final AixmTime time;
  
  _ParsedDateTime(this.date, this.time);
}
