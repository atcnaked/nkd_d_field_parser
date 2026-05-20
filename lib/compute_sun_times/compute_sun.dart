// approx !  import 'package:daylight/daylight.dart';
import 'package:spa/spa.dart';

import 'function_from_notam_parse.dart';

computeSrSszz() {
  print('TODO compute SR SS');
}

void computeSrSs() {
  final DDcoords? lflnDDcoords = getDDcoordsFromQAndIndicator('LFLN','4624N00401E');
  final DDcoords? lflcDDcoords = getDDcoordsFromQAndIndicator('LFLC','4547N00310E');
  final DDcoords? lfpgDDcoords = getDDcoordsFromQAndIndicator('LFPG','4901N00233E');
  final DDcoords? pointDDcoords = lflnDDcoords;
  if (pointDDcoords == null) {
    // print('london = const DaylightLocation(51.5072, 0.1276)');
    print('DDcoords: is null');
    return;
  }
  print('DDcoords: $pointDDcoords');
  
  final nowUTC = DateTime.now().toUtc();
  print('nowUTC: $nowUTC');
  var spaSunInformation = spaCalculate(
    SPAParams(
      time: nowUTC,
      longitude: pointDDcoords.longitude,
      latitude: pointDDcoords.latitude,
      elevation: 0,
    ), 
  );
  final sunriseDec = spaSunInformation.sunrise;
  final sunsetDec = spaSunInformation.sunset;

  final sunriseDecDt = convertDecimalHoursToDateTime(sunriseDec!, nowUTC)!;
  final sunsetDecDt = convertDecimalHoursToDateTime(sunsetDec!, nowUTC)!;
  print(
    '${pointDDcoords.indicator} spa SR: ${sunriseDecDt.formatStandard()} / ${spaSunInformation.sunrise}',
  );
  print(
    '${pointDDcoords.indicator} spa SS: ${sunsetDecDt.formatStandard()} / ${spaSunInformation.sunset}',
  );
}

extension on DateTime {
  String formatStandard() {
    return '${this.hour.toString().padLeft(2, '0')}:${this.minute.toString().padLeft(2, '0')}:${this.second.toString().padLeft(2, '0')}';
  }
}

calcSpa() {
  var output = spaCalculate(
    SPAParams(
      time: DateTime(2019, 7, 2, 22),
      longitude: -83.045753,
      latitude: 42.331429,
      elevation: 191,
    ),
  );
  print('sunrise: ${output.sunrise}');

  print('zenith: ${output.zenith}');
  print('azimuth_astro: ${output.azimuthAstro}');
  print('azimuth: ${output.azimuth}');
  print('incidence: ${output.incidence}');
  print('suntransit: ${output.sunTransit}');
  print('sunrise: ${output.sunrise}');
  print('sunset: ${output.sunset}');
}

/// spa conv
DateTime? convertDecimalHoursToDateTime(
  double decimalHours,
  DateTime baseDate, {
  bool nullIfMoreThan24Hours = false,
}) {
  /*
Precision: Dart's double has a 53-bit mantissa, which safely holds numbers up to about 9 quadrillion. 
Since the maximum microseconds in a day is 86.4 billion (86,400,000,000), we completely sidestep 
floating-point precision limits. Using .round() ensures you don't lose a fraction of a microsecond during the math.

Timezone Safe: The function checks baseDate.isUtc. If you pass a UTC date, it returns a UTC date. 
If you pass a Local date, it returns a Local date.

Rollover Safe: If for some reason your decimalHours exceeds 24 (e.g., 25.5), Dart's add() 
method intelligently rolls the date forward to the next day rather than crashing or throwing an invalid time exception 
 */

  // 1 hour = 60 * 60 * 1,000,000 = 3,600,000,000 microseconds
  const int microsecondsPerHour = 3600000000;

  // Multiply and round to integer to maintain precise microsecond accuracy
  int totalMicroseconds = (decimalHours * microsecondsPerHour).round();

  // Create a duration from the calculated microseconds
  Duration timeOfDay = Duration(microseconds: totalMicroseconds);

  // Strip existing time from baseDate to start at exactly midnight,
  // making sure to respect the original object's timezone (Local or UTC).
  DateTime midnight = baseDate.isUtc
      ? DateTime.utc(baseDate.year, baseDate.month, baseDate.day)
      : DateTime(baseDate.year, baseDate.month, baseDate.day);

  // Add the duration to our clean midnight date
  final res = midnight.add(timeOfDay);

// if 
  if (nullIfMoreThan24Hours) {
    if (baseDate.day != res.day) {
      return null;
    }
  }

  return res;
}

/* 

https://api.sunrise-sunset.org/json?lat=46.4&lng=4.016667&date=2026-05-18
 */