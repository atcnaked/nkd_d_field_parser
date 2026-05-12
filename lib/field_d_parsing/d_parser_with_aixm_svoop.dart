//static List<NotamSchedule> parse(String string, {required DateTime baseDate}) {

import 'd parser with aixm mod D field list.dart';
import 'd parser with aixm MOD v1.dart';

void svoop01() {
  final dtNow = DateTime.now();
  final dFields0 = ['H24'];
  final dFields1 = ['H24', '0000-2357'];
  final dFields2 = ['JAN 15 1430-FEB 28 SR PLUS30'];
  final dFields3 = ['H24', '0000-2357'];
  final dFields4 = ['SUN H24'];
  final dFields6 = ['13 H24'];

  final dFields7 = ['10 01 H24', 'FEB 07 JAN 02 H24'];
  final dFields8 = ['2000-0157'];
  final dFields10 = ['MON 1700 - MON 0300', 'MON 1000 - MON 1200'];
  final dFields9a = ['14 2301-17 2359  EXC 16','14 2301-17 2359  EXC FRI','13 2301-16 2359 ','14 2301-17 2359  EXC MAR'];
  final dFields9 = ['14 2301-17 2359 ','14 2301-17 2359  EXC MAR'];
  final dFields11 = ['0830-1100','1300-SS PLUS30'];
  final dFieldsError = ['0830-1600 EXC SAT'];

  final dCheckingListWOD = dCheckingString
      .split('D)')
      .map((e) => e.trim())
      .toList();

  final dCheckingList = [];
  for (var lineWithComma in dFields11) {
    final commaParts = lineWithComma.split(',').map((e) => e.trim()).toList();
    dCheckingList.addAll(commaParts);
  }

  String parsed = '';
  final len = dCheckingList.length;
  int counter = 1;
  try {
    for (var element in dFields11) {
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
    print('$e , while parsing: $parsed');
  }
}
