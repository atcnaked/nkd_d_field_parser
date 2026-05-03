
import 'package:flutter_test/flutter_test.dart';
import 'package:nkd_d_field_parser/field_d_parsing/month_dates_parser.dart/dates_parser.dart' show getDatesFrom;
import 'package:nkd_d_field_parser/field_d_parsing/range_v2_producer.dart' ;


void main() {

List<XRangeV2> dateTokens = [];
  test('Counter increments smoke test1', () async {



// final (List<int>, String?) res= getDatesFrom( []) ;
 (var: list, var err) res= getDatesFrom( []) ;

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
