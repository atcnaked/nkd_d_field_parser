import 'package:flutter_test/flutter_test.dart';
import 'package:nkd_d_field_parser/field_d_parsing/month_dates_parser.dart/dates_parser.dart'
    show getDatesFrom, enumeratedsFrom;
import 'package:nkd_d_field_parser/field_d_parsing/month_dates_parser.dart/month_parser.dart'
    show datesByMonth;
import 'package:nkd_d_field_parser/field_d_parsing/my_token_class_tokenizer.dart';
import 'package:nkd_d_field_parser/field_d_parsing/range_v2_producer.dart';

// (List<(String, String)>?, String?) datesByMonth(String? source) {

void main() {
  test('getDatesFrom(Date2Range)', () async {
    final d2r1_2 = Date2Range(TwoDigitToken('1'), TwoDigitToken('2'));
    final d2r20_22 = Date2Range(TwoDigitToken('20'), TwoDigitToken('22'));
    final d2r29_31 = Date2Range(TwoDigitToken('29'), TwoDigitToken('31'));
    ///////////////////////////////////////////////////
    List<XRangeV2> dateTokens = [d2r1_2];
    (List<int>?, String?) actual = getDatesFrom(dateTokens);
    (List<int>?, String?) expected = ([1, 2], null);
    expect(actual.$2, expected.$2);
    expect(actual.$1, expected.$1);

    ///////////////////////////////////////////////////
    dateTokens = [d2r20_22];
    actual = getDatesFrom(dateTokens);
    expected = ([20, 21, 22], null);
    expect(actual.$2, expected.$2);
    expect(actual.$1, expected.$1);

    ///////////////////////////////////////////////////
    dateTokens = [d2r1_2, d2r20_22];
    actual = getDatesFrom(dateTokens);
    expected = ([1, 2, 20, 21, 22], null);
    expect(actual.$2, expected.$2);
    expect(actual.$1, expected.$1);

    ///////////////////////////////////////////////////
    dateTokens = [d2r1_2, d2r20_22, d2r29_31];
    actual = getDatesFrom(dateTokens);
    expected = ([1, 2, 20, 21, 22,29,30,31], null);
    expect(actual.$2, expected.$2);
    expect(actual.$1, expected.$1);
    
    ///////////////////////////////////////////////////
    dateTokens = [ d2r29_31];
    actual = getDatesFrom(dateTokens);
    expected = ([29,30,31], null);
    expect(actual.$2, expected.$2);
    expect(actual.$1, expected.$1);
  });
  test('getDatesFrom(LoneNumber)', () async {
    final one = LoneNumberRange(TwoDigitToken('1'));
    final two = LoneNumberRange(TwoDigitToken('2'));
    final lt20 = LoneNumberRange(TwoDigitToken('20'));
    final lt31 = LoneNumberRange(TwoDigitToken('31'));
    ///////////////////////////////////////////////////
    List<XRangeV2> dateTokens = [one];
    (List<int>?, String?) actual = getDatesFrom(dateTokens);
    (List<int>?, String?) expected = ([1], null);
    expect(actual.$2, expected.$2);
    expect(actual.$1, expected.$1);
    ///////////////////////////////////////////////////
    dateTokens = [one, two];
    actual = getDatesFrom(dateTokens);
    expected = ([1, 2], null);
    expect(actual.$2, expected.$2);
    expect(actual.$1, expected.$1);

    ///////////////////////////////////////////////////
    dateTokens = [one, two, lt20, lt31];
    actual = getDatesFrom(dateTokens);
    expected = ([1, 2, 20, 31], null);
    expect(actual.$2, expected.$2);
    expect(actual.$1, expected.$1);
  });

  test('enumeratedsFrom', () async {
    expect(enumeratedsFrom(1, 1), [1]);
    expect(enumeratedsFrom(0, 1), [0, 1]);
    expect(enumeratedsFrom(0, 2), [0, 1, 2]);
    expect(enumeratedsFrom(1, 2), [1, 2]);
    expect(enumeratedsFrom(3, 7), [3, 4, 5, 6, 7]);
    expect(enumeratedsFrom(28, 31), [28, 29, 30, 31]);
    final List<int> actual = enumeratedsFrom(0, 1);
    final List<int> expected = [0, 1];
  });
  test('validation test', () async {
    // test('datesByMonth of MAY 01', () async {
    // final (List<int>, String?) res= getDatesFrom( []) ;
    // final (List<(String, String)>?, String?) res = datesByMonth('MAY 01');
    final actual = 'AAA';
    final expected = 'AAA';
    //  print('TEST: actual: $actual');
    // Verify that our counter starts at 0.
    expect(actual, expected);
    // expect(res.$1!.first.$1, 'MAY');
  });
}
