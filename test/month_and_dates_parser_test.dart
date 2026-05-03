import 'package:flutter_test/flutter_test.dart';
import 'package:nkd_d_field_parser/field_d_parsing/month_dates_parser.dart/dates_parser.dart'
    show getDatesFrom;
import 'package:nkd_d_field_parser/field_d_parsing/month_dates_parser.dart/month_parser.dart'
    show datesByMonth;
import 'package:nkd_d_field_parser/field_d_parsing/range_v2_producer.dart';

// (List<(String, String)>?, String?) datesByMonth(String? source) {

void main() {
  //List<XRangeV2> dateTokens = [];
  test('datesByMonth of MAY 01', () async {
    // final (List<int>, String?) res= getDatesFrom( []) ;
    final (List<(String, String)>?, String?) res = datesByMonth('MAY 01');
    print('TEST: res: $res');
    // Verify that our counter starts at 0.
    expect(res.$1!.first.$1, 'MAY');
  });
}
