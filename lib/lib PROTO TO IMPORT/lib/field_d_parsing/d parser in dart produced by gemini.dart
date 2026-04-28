class TimeRange {
  final String start;
  final String end;
  final bool spansMidnight;

  TimeRange({required this.start, required this.end, this.spansMidnight = false});

  @override
  String toString() => '$start-$end${spansMidnight ? ' (Spans Midnight)' : ''}';
}

class NotamSchedule {
  final String rawActiveRules;
  final String? rawExceptions;
  final List<String> activeDaysOrDates;
  final List<TimeRange> activeTimes;
  final List<String> inactiveDaysOrDates; // The parsed EXC part

  NotamSchedule({
    required this.rawActiveRules,
    this.rawExceptions,
    required this.activeDaysOrDates,
    required this.activeTimes,
    required this.inactiveDaysOrDates,
  });

  @override
  String toString() {
    return 'NotamSchedule(\n  Actives: $activeDaysOrDates\n  Times: $activeTimes\n  Exceptions: $inactiveDaysOrDates\n)';
  }
}

class NotamScheduleParser {
  // 1. Core Dictionaries (Mapped from Ruby Constants)
  static const Map<String, int> operations = {'PLUS': 1, 'MINUS': -1};
  static const List<String> days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN', 'DAILY', 'DLY'];
  static const List<String> months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];

  // 2. Regex Patterns (Mapped directly from the Ruby DATE_RE, HOUR_RE, etc.)
  static const String _dateRe = r'(?:[0-2]\d|3[01])';
  static final String _dayRe = '(?:${days.join('|')})';
  static final String _monthRe = '(?:${months.join('|')})';
  static const String _hcodeRe = r'(?<hcode>H24|HJ|HN)';
  
  // Captures hours and minutes e.g., 0800
  static const String _hourRe = r'(?<hour>[01]\d|2[0-4])(?<minute>[0-5]\d)';
  static final String _operationsRe = '(?:${operations.keys.join('|')})';
  
  // Captures Sun Relative times e.g., SR PLUS30
  static final String _eventRe = '(?<event>SR|SS)(?:\\s(?<operation>$_operationsRe)(?<delta>\\d+))?';
  static final String _timeRe = '(?:$_hourRe|$_eventRe)';
  
  // Matches 0800-1700 or H24
  static final String _timeRangeRe = '(?:$_timeRe-$_timeRe|$_hcodeRe)';

  /// Cleans up the string just like the Ruby `cleanup` method
  static String _cleanup(String input) {
    return input
        .replaceAll(RegExp(r'\s+'), ' ') // collapse whitespaces
        .replaceAll(RegExp(r' *- *'), '-') // remove spaces around dashes
        .trim();
  }

  /// Main parsing function equivalent to `Schedule.parse`
  static NotamSchedule parse(String scheduleString) {
    final cleanStr = _cleanup(scheduleString);
    
    // Split into Active Rules and Exceptions
    final parts = cleanStr.split(RegExp(r' EXC '));
    final rulesStr = parts[0].trim();
    final exceptionsStr = parts.length > 1 ? parts[1].trim() : null;

    // Split rules into Date/Day part and Time part
    // The Ruby code does a complex split, but typically times are at the end.
    // We use our time range regex to find all time blocks.
    final timeMatches = RegExp(_timeRangeRe).allMatches(rulesStr).toList();
    
    if (timeMatches.isEmpty) {
      throw FormatException('No valid time ranges found in schedule block: $rulesStr');
    }

    // Extract times
    List<TimeRange> times = [];
    for (var match in timeMatches) {
      final timeString = match.group(0)!;
      if (timeString == 'H24' || timeString == 'HJ' || timeString == 'HN') {
        times.add(TimeRange(start: timeString, end: timeString));
      } else {
        final splitTime = timeString.split('-');
        if (splitTime.length == 2) {
          final start = splitTime[0];
          final end = splitTime[1];
          times.add(TimeRange(
            start: start, 
            end: end, 
            spansMidnight: _isAcrossMidnight(start, end)
          ));
        }
      }
    }

    // Extract Active Days/Dates (Everything before the first time match)
    final firstTimeIndex = timeMatches.first.start;
    final activeDaysRaw = rulesStr.substring(0, firstTimeIndex).trim();
    final activeDaysList = activeDaysRaw.isNotEmpty 
        ? activeDaysRaw.split(RegExp(r'[ ,]+')) 
        : ['DAILY'];

    // Extract Exception Days/Dates
    List<String> exceptionList = [];
    if (exceptionsStr != null) {
      exceptionList = exceptionsStr.split(RegExp(r'[ ,]+'));
    }

    return NotamSchedule(
      rawActiveRules: rulesStr,
      rawExceptions: exceptionsStr,
      activeDaysOrDates: activeDaysList,
      activeTimes: times,
      inactiveDaysOrDates: exceptionList,
    );
  }

  /// Checks if a time range crosses midnight (e.g., 2200-0500)
  /// Equivalent to the Ruby `across_midnight?` method
  static bool _isAcrossMidnight(String start, String end) {
    // Basic implementation for HHMM format. 
    // Note: To perfectly handle SR-SS crossing midnight requires a solar calculator.
    final hhmmRegex = RegExp(_hourRe);
    if (hhmmRegex.hasMatch(start) && hhmmRegex.hasMatch(end)) {
      final startInt = int.parse(start);
      final endInt = int.parse(end);
      return startInt > endInt;
    }
    return false; // Fallback for SR/SS strings
  }
}

// --- EXAMPLE USAGE ---
void main() {
  final testStrings = [
    "MON-FRI 0800 - 1700 EXC WED",
    "2200-0500", // Spans midnight test
    "JAN 01 0600-SR PLUS30, JAN 02 0800-1200 EXC JAN 02 0900-1000" // Complex
  ];

  for (var str in testStrings) {
    // Simulating the split by comma that you would do before calling the parser
    final blocks = str.split(', ');
    for (var block in blocks) {
      try {
        final schedule = NotamScheduleParser.parse(block);
        print('--- Parsed Block ---');
        print(schedule);
      } catch (e) {
        print('Error parsing "$block": $e');
      }
    }
  }
}