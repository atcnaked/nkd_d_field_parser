// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

/// decode position like 4337N00120W041
///
/// Latitude : 5 chars, DMS, CCCCN ou S (Ex 4853N)
/// Longitude : 6 chars, DMS,CCCCCE ou W (Ex 00325W)
/// dist 3 numbers
DDcoords? getDDcoordsFromQAndIndicator( String indicator, String input) {
  final String area = input.trim();
  // print('getImpactedArea in area: $area');

  if (area.length < 11) {
    print('area.length = ${area.length} < 11 in $area');
    return null;
  }
  final latString = area.substring(0, 5);
  final longString = area.substring(5, 11);
 // final distString = area.substring(11);

  final dMSLat = getDMSLatOf(latString);

  if (dMSLat == null) {
    print('adMSLat == null  in $area');
    return null;
  }
  final dMSLong = getDMSLongOf(longString);

  if (dMSLong == null) {
    print('dMSLong == null  in $area');
    return null;
  }
  final centerLat = getDDfromDMS(dMSLat.$1, dMSLat.$2, dMSLat.$3, dMSLat.$4);
  final centerLong = getDDfromDMS(
    dMSLong.$1,
    dMSLong.$2,
    dMSLong.$3,
    dMSLong.$4,
  );/* 
  final int? dist = int.tryParse(distString);
  if (dist == null || dist < 0) {
    return null;
  } */

  return DDcoords( originalString: area, longitude: centerLong, latitude: centerLat, indicator: indicator);
}

class DDcoords {
  final String indicator;
  final String originalString;

  final double longitude;
  final double latitude;
  DDcoords({
    required this.indicator,
    required this.originalString,
    required this.longitude,
    required this.latitude,
  });



  @override
  String toString() {
    return '($indicator, at $originalString, long: $longitude, lat: $latitude)';
  }
}

/// DMS latitude : 4 digits and N or S (Ex 4853N)
(int, int, double, String)? getDMSLatOf(String latString) {
  final int deg;
  final int min;
  try {
    deg = int.parse(latString.substring(0, 2));
    min = int.parse(latString.substring(2, 4));
  } catch (e) {
    print('');
    return null;
  }
  if (deg < 0 || min < 0) {
    print('');
    return null;
  }
  final ns = latString.substring(4);
  if (ns != 'N' && ns != 'S') {
    print('');
    return null;
  }
  return (deg, min, 0.0, ns);
}

/// DMS longitude : 5 digits and E or W
(int, int, double, String)? getDMSLongOf(String latString) {
  final int deg;
  final int min;
  try {
    deg = int.parse(latString.substring(0, 3));
    min = int.parse(latString.substring(3, 5));
  } catch (e) {
    return null;
  }

  if (deg < 0 || min < 0) {
    return null;
  }
  final ns = latString.substring(5);
  if (ns != 'E' && ns != 'W') {
    return null;
  }
  return (deg, min, 0.0, ns);
}

/// Convert Degrees, Minutes, Seconds to Decimal Degrees
double getDDfromDMS(
  int degrees,
  int minutes,
  double seconds,
  String direction,
) {
  double dd = degrees + minutes / 60 + seconds / (60 * 60);
  if (direction == "S" || direction == "W") {
    dd = dd * -1;
  }
  return double.parse(dd.toStringAsFixed(6));
}
