 // 1. Constants
   import 'package:nkd_d_field_parser/d_field_lists/src/aixm_models.dart';

const Map<String, String> events = {'SR': 'sunrise', 'SS': 'sunset'};
   const Map<String, AixmTime> eventHours = {
    'sunrise': AixmTime.literal('06:00'),
    'sunset': AixmTime.literal('18:00'),
  };
   const Map<String, int> operations = {'PLUS': 1, 'MINUS': -1};
   const Map<String, int> months = {
    'JAN': 1,
    'FEB': 2,
    'MAR': 3,
    'APR': 4,
    'MAY': 5,
    'JUN': 6,
    'JUL': 7,
    'AUG': 8,
    'SEP': 9,
    'OCT': 10,
    'NOV': 11,
    'DEC': 12,
  };
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

  // 2. Regex Patterns with capture groups
   const String dateRe = r'(?:[0-2]\d|3[01])';
   final String dayRe = '(?:${days.keys.join('|')})';
   final String monthRe = '(?:${months.keys.join('|')})';
   const String hcodeRe = r'(?<hcode>H24|HJ|HN)';
   const String hourRe = r'(?<hour>[01]\d|2[0-4])(?<minute>[0-5]\d)';
   final String operationsRe = '(?:${operations.keys.join('|')})';
   final String eventRe =
      '(?<event>SR|SS)(?:\\s(?<operation>$operationsRe)(?<delta>\\d+))?';
   final String timeRe = '(?:$hourRe|$eventRe)';
   final String timeRangeRe = '(?:$timeRe-$timeRe|$hcodeRe)';
   final String datetimeRe =
      '(?:(?<month>$monthRe) )?(?<date>$dateRe) (?<time>$timeRe)';
   final String datetimeRangeRe = '$datetimeRe-$datetimeRe';

  // 2. Regex Patterns no named capture groups (= NoCG)
   const String hcodeReNoCG = r'(H24|HJ|HN)';
   const String hourReNoCG = r'([01]\d|2[0-4])([0-5]\d)';
   final String eventReNoCG = '(SR|SS)(?:\\s($operationsRe)(\\d+))?';
   final String timeReNoCG = '(?:$hourReNoCG|$eventReNoCG)';
   final String timeRangeReNoCG =
      '(?:$timeReNoCG-$timeReNoCG|$hcodeReNoCG)';

   final String datetimeReNoCG =
      '(?:($monthRe) )?($dateRe) ($timeReNoCG)';
   final String datetimeRangeReNoCG = '$datetimeReNoCG-$datetimeReNoCG';

  // AI fix: to Match "MON 1000-FRI 1200"
   final String dayTimeRangeRe =
      '(?<startDay>$dayRe) (?<startTime>$timeReNoCG)-(?<endDay>$dayRe) (?<endTime>$timeReNoCG)';
  //

   const AixmRange<AixmTime> h24 = AixmRange(
    AixmTime.beginningOfDay,
    AixmTime.endOfDay,
  );

   final AixmRange<AixmTime> hj = AixmRange(
    AixmTime.event('sunrise'),
    AixmTime.event('sunset'),
  );
   final AixmRange<AixmTime> hn = AixmRange(
    AixmTime.event('sunset'),
    AixmTime.event('sunrise'),
  );




