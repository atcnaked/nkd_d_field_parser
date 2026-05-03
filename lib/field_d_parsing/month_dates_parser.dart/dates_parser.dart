import 'dart:math';

import '../range_v2_producer.dart';

(List<int>, String?) getDatesFrom(List<XRangeV2> dateTokens) {
  final res = <int>[];
  for (var element in dateTokens) {
    if (element is Date2Range) {
      final int? start = int.tryParse(element.startToken.word);
      final int? end = int.tryParse(element.endToken.word);
      //       if (start == null || end == null) {
      if (start == null || end == null) {
        return (
          res,
          'error, can not parse to int inside element: $element of dateTokens: $dateTokens',
        );
      }
      final enumerateds = <int>[];
      for (var i = start; i < end + 1; i++) {
        enumerateds.add(i);
      }
      res.addAll(enumerateds);
    } else if (element is LoneNumber) {
      final int? dateNb = int.tryParse(element.twoDigitToken.word);
      if (dateNb == null) {
        return (
          res,
          'error ,can not parse ${element.twoDigitToken.word} to int in $element of dateTokens: $dateTokens',
        );
      }
      res.add(dateNb);
    } else {
      return (
        res,
        '''error while producing dates from tokens list, a token provided 
  is not a date or a range of dates, it is of type ${element.runtimeType}, element:$element.
  At this moment the list of dates built was: $res. 
  The input dateTokens was: $dateTokens''',
      );
    }
  }
  return (res, null);
}


/* 

class Date2Range extends X2RangeV2 {
  Date2Range(super.startToken, super.endToken);
  @override
  String toString() {
    return 'Date2Range($startToken-$endToken)';
  }
}

/// range for 1 Number only
class LoneNumber 

 */