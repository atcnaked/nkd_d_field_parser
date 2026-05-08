//static List<NotamSchedule> parse(String string, {required DateTime baseDate}) {

import 'd parser with aixm mod D field list.dart';
import 'd parser with aixm MOD produced by gemini.dart';

void svoop01() {
  final dtNow = DateTime.now();
  final dFields0 = ['H24'];
  final dFields1 = ['H24', '0000-2357'];
  final dFields2 = ['JAN 15 1430-FEB 28 SR PLUS30'];
  final dFields3 = ['H24', '0000-2357'];
  final dFields4 = ['SUN H24'];
  final dFieldsError = ['0830-1600 EXC SAT'];

  final dCheckingList = dCheckingString
      .split('D)')
      .map((e) => e.trim())
      .toList();
String parsed ='';
final len = dCheckingList.length;
int counter = 1;
  try {
    for (var element in dCheckingList) {
       parsed = element;
       if (element.isEmpty) {
         continue;
       }
      final List<NotamSchedule> res = NotamSchedule.parse(
        element,
        baseDate: dtNow,
      );

      print('svoop01 parsing $counter/$len: $element=> $res');
      counter++;
    }
  } catch (e) {
    print('parsing: $parsed, e: $e');
  }
}
