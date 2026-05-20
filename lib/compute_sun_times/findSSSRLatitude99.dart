import 'package:spa/spa.dart';

void findSSSRLatitude() {
  // converting 99 min into decimal hours
  final nineteenMinutesDecimalHours = 99 / 60;
  print('nineteenMinutesDecimalHours: $nineteenMinutesDecimalHours');

  print('find Latitude with constraints on SR and SS and 99 min');
  double lat = 0.0;
  final june21 = DateTime(2026, 1, 20).toUtc();
  print('june21: $june21');

  double? sunriseDec = 0;
  double? sunsetDec = 0;
  while (lat < 89) {
    var spaSunInformation = spaCalculate(
      SPAParams(time: june21, longitude: 0, elevation: 0, latitude: lat),
    );
    sunriseDec = spaSunInformation.sunrise;
    sunsetDec = spaSunInformation.sunset;
    if (sunriseDec == null ||
        sunsetDec == null ||
        sunriseDec < 0 ||
        sunsetDec < 0 ||
        sunriseDec >= 24 ||
        sunsetDec >= 24) {
      print(
        'sunriseDec, sunsetDec == null or <0 for lat: $lat (sunsetDec: $sunriseDec, sunriseDec: $sunsetDec)',
      );
      break;
    }

    final sRMintwilight = sunriseDec - nineteenMinutesDecimalHours;
    final sSMaxtwilight = sunsetDec + nineteenMinutesDecimalHours;
    if (sRMintwilight < 0 || sSMaxtwilight >= 24) {
      print(
        'sRMintwilight < 0 || sSMaxtwilight >= 24 for lat: $lat (sRMintwilight: $sRMintwilight, sSMaxtwilight: $sSMaxtwilight)',
      );
      break;
    }

    print(
      'lat: $lat =>sunsetDec: $sunriseDec, sunriseDec: $sunsetDec, sRMintwilight: $sRMintwilight, sSMaxtwilight: $sSMaxtwilight',
    );
    lat += 0.1;
  }
  print('if +-99min =1.65 hour, reached for lat: 63.6 at date 2026-05-20');
}
