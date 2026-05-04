// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'my_token_class_tokenizer.dart';


/// take a rule of a schedule element and convert token combination into ranges in several pass.
(List<XRangeV2>?, String?) gatherAndProduceRangeLikeV2(List<MyToken> tokenizeds) {
  if (tokenizeds.isEmpty) {
    return (
      null,
      'XRange production error: a list of XRange can not be produced from an empty list of token',
    );
  }
  if (tokenizeds.first is HyphenToken || tokenizeds.last is HyphenToken) {
    return (
      null,
      'XRange production error: the first or the last token is an HyphenToken in list: $tokenizeds',
    );
  }




  if (tokenizeds.length < 3) {
    final res = tokenizeds.map((e) => loneRangeFrom(e)).toList();
    return (res, null);
  }
  // now tokenizeds.length >=3
  final List<int> hyphenIndexes = tokenizeds.indexed
      .where((itk) => itk.$2 is HyphenToken)
      .map((e) => e.$1)
      .toList();
  // this List<(MyToken?, XRange?)> will be (MyToken,null) at the beginning and (null,XRange) or (null,null) at the end of the process
  
  
  // a map of source token to XRange. 
  // some transformed token will be transformed into null as they will be taken into account inside another 
  
  final List<(MyToken?, XRangeV2?)> myTokenOrXRangeList = tokenizeds
      // if you do not do (e, null) as (MyToken?, XRange?) then the type of the list is (MyToken, Null) leading to error:
      // _TypeError (type '(Null, Null)' is not a subtype of type '(MyToken, Null)' of 'value')
      .map((e) => (e, null) as (MyToken?, XRangeV2?))
      .toList();
  /* 
  if (hyphenIndexes.isEmpty) {
    print('TODO HyphenIndexes isEmpty=> no nedd');
  }
   */
  for (var idx in hyphenIndexes) {
    if (0 <= idx - 2 && idx + 2 < myTokenOrXRangeList.length) {
      final X4Range? xRange4 = xRange4From(idx, myTokenOrXRangeList);

      /// if there is a MonthDay pattern we create the XRange and proceed with next loop
      if (xRange4 != null) {
        myTokenOrXRangeList[idx - 2] = (null, null);
        myTokenOrXRangeList[idx - 1] = (null, null);
        myTokenOrXRangeList[idx] = (null, xRange4);
        myTokenOrXRangeList[idx + 1] = (null, null);
        myTokenOrXRangeList[idx + 2] = (null, null);
        continue;
      }
    }

    /// if there is a twin pattern we create the XRange
    final X2RangeV2? xRange2 = xRange2From(idx, myTokenOrXRangeList);
    if (xRange2 == null) {
      continue;
    }
    //  print('found XRange: $xRange at index: $idx');
    // print('myTokenOrXRangeList before: $myTokenOrXRangeList before');
    myTokenOrXRangeList[idx - 1] = (null, null);
    myTokenOrXRangeList[idx] = (null, xRange2);
    myTokenOrXRangeList[idx + 1] = (null, null);
    // print('myTokenOrXRangeList after: $myTokenOrXRangeList before');
  }
  print('');
  // then create loneRange From remaining
  for (var i = 0; i < myTokenOrXRangeList.length; i++) {
    final tk = myTokenOrXRangeList[i].$1;
    if (tk == null) {
      continue;
    }
    final XRangeV2 xRange = loneRangeFrom(tk);
    myTokenOrXRangeList[i] = (null, xRange);
  }
  // proto: checking that all token has been consumed
  final List<int> indexesMyTokenNotEmpty = myTokenOrXRangeList.indexed
      .where((pair) => pair.$2.$1 != null)
      .map((pair) => pair.$1)
      .toList()
      .toList();
  if (indexesMyTokenNotEmpty.isNotEmpty) {
    return (
      [],
      'error:  token at index $indexesMyTokenNotEmpty has not been consummed while producing the Ranges\nmyTokenOrXRangeList: $myTokenOrXRangeList',
    );
  }

  // keeping only xRange
  final List<XRangeV2> xRanges = myTokenOrXRangeList
      .where((e) => e.$2 != null)
      .map((e) => e.$2!)
      .toList();

  // checking that no ErrorRange
  final List<int> indexesErrorXRange = xRanges.indexed
      .where((pair) => pair.$2 is ErrorXRange)
      .map((pair) => pair.$1)
      .toList();
  if (indexesErrorXRange.isNotEmpty) {
    return (
      [],
      'error: ErrorXRange at index $indexesErrorXRange. \nxRanges: $xRanges',
    );
  }

  return (xRanges, null);
}

/// returns the MonthDay XRange of 4 values (before and after index) in provided List. Null if Not possible.
///
/// Null if element at index idx +/-2 do not exist.
X4Range? xRange4From(int idx, List<(MyToken?, XRangeV2?)> myTokenOrXRangeList) {
  if (idx - 2 < 0 || myTokenOrXRangeList.length <= idx + 2) {
    return null;
  }

  final prev2 = myTokenOrXRangeList[idx - 2].$1;
  final prev1 = myTokenOrXRangeList[idx - 1].$1;
  final next1 = myTokenOrXRangeList[idx + 1].$1;
  final next2 = myTokenOrXRangeList[idx + 2].$1;
  /* 
   */
  if ((prev2 is TwoDigitToken || prev2 is WeekDayLyToken) &&
      prev1 is HourToken &&
      (next1 is TwoDigitToken || next1 is WeekDayLyToken) &&
      next2 is HourToken) {
    return DayOrWeekDayHourRange(
      startDToken: prev2!,
      startHToken: prev1,
      endDToken: next1!,
      endHToken: next2,
    );
  }

  if (prev2 is MonthToken && prev1 is TwoDigitToken && next1 is MonthToken ||
      next2 is TwoDigitToken) {
    return MonthDayRange(
      startMonthToken: prev2!,
      startDayToken: prev1!,
      endMonthToken: next1!,
      endDayToken: next2!,
    );
  }
  return null;
}

/// returns the XRange of 2 values (before and after index) in provided List. Null if Not possible.
X2RangeV2? xRange2From(int idx, List<(MyToken?, XRangeV2?)> myTokenOrXRangeList) {
  final prev = myTokenOrXRangeList[idx - 1].$1;
  final next = myTokenOrXRangeList[idx + 1].$1;

  if (prev == null || next == null) {
    return null;
  }
  final X2RangeV2? xRange = myXRange2From(prev, next);

  return xRange;
}

/// returns the XRange of 1 values. Error if Not possible.
XRangeV2 loneRangeFrom(MyToken theToken) {
  if (theToken is TwoDigitToken) {
    return Date2Range(theToken, theToken);
  }
  if (theToken is MonthToken) {
    return MonthRange(theToken);
  }
  if (theToken is WeekDayLyToken) {
    return WeekDayLyRange(theToken as WeekDayLyToken, theToken as WeekDayLyToken);
  }
  return ErrorXRange(theToken, 'incorrect type error: ${theToken.runtimeType}');
}
/* 
/// returns the XRange of 2 values. Null if Not possible.
X2Range? myXRange2From(MyToken prev, MyToken next) {
  if (prev is TimeToken && next is TimeToken) {
    return TimePeriod(prev, next);
  }
  if (prev is TwoDigitToken && next is TwoDigitToken) {
    return Date2Range(prev, next);
  } /* 
  if (prev is MonthToken && next is MonthToken) {
    return MonthRange(prev, next);
  } */
  if (prev is WeekDayLyToken && next is WeekDayLyToken) {
    return WeekDayLyRange(prev, next);
  }
  return null;
}
 */
sealed class XRangeV2 {}

sealed class X1RangeV2 extends XRangeV2 {}

sealed class X4Range extends XRangeV2 {}

sealed class X2RangeV2 extends XRangeV2 {

}

/// the ultimate purpose is to produce a Map date YMD => List TP.
/// The D field decoding can lead to two (or three) general things can allow that: 
/// - List of ActiveDatesTimePeriod = List of YMD H - YMD H
///       from there you can build the Map by slicing by day
/// - a List of YMD paired with a List of TP (called ?? DatesXTPs)
///       from there you can also build the Map by doing a cross product
/// those approach are general and do not yet take into account the EXC part 
/// (which is expected to be a List of Dates)
/// - a List of WeekDays 
/// - a List of excluded dates 




/// ActiveDatesTimePeriod are TP that start and end on different days
sealed class ActiveDatesTimePeriod extends XRangeV2 {}

 class WeekDayLyTokenTimePeriod extends ActiveDatesTimePeriod {

  final WeekDayLyToken startWeekDay;
  final HourToken startHour;
  final WeekDayLyToken endWeekDay;
  final HourToken endHour;

  WeekDayLyTokenTimePeriod(this.startWeekDay, this.startHour, this.endWeekDay, this.endHour);

 }
 /// MonthDatesTimePeriod have an optional months that will be found later with the context
 /// 
 /// if a month is null it means it must be infered from context
 /// Year will always be from context
 class MonthDatesTimePeriod extends ActiveDatesTimePeriod {
  final MonthToken? startMonth ;
  final TwoDigitToken startDayNumber;
  final HourToken startHour;
  final MonthToken? endMonth;
  final TwoDigitToken endDayNumber;
  final HourToken endHour;

  MonthDatesTimePeriod(this.startMonth, this.startDayNumber, this.startHour, this.endMonth, this.endDayNumber, this.endHour);

}
/* 
/// use month as start end Token and repeat them in the fields
class DayOrWeekDayHourRange extends X4Range {
  final MyToken startDToken;
  final HourToken startHToken;
  final MyToken endDToken;
  final HourToken endHToken;
  DayOrWeekDayHourRange({
    required this.startDToken,
    required this.startHToken,
    required this.endDToken,
    required this.endHToken,
  }); 

  @override
  String toString() {
    return 'DayOrWeekDayHourRange($startDToken $startHToken -> $endDToken $endHToken)';
  }
}
  */

/// TP TimePeriod represents 0800-1000. 
/// To be used with DatesSelector in order to produce Lis
class TimePeriod extends XRangeV2 {
  final HourToken startHour;
  final HourToken endHour;
TimePeriod(this.startHour, this.endHour);
  @override
  String toString() {
    return 'TP($startHour-$endHour)';
  }
}
/* 
/// TP TimePeriod represents 0800-1000
class TimePeriod extends XRangeV2 {
  final HourToken startToken;
  final HourToken endToken;
  TimePeriod({
    required this.startToken,
    required this.endToken,
  });

  @override
  String toString() {
    return 'TP($startToken-$endToken)';
  }
} */

/// range build from days of 1 or 2 digits.
///
/// When it deals with one day, use set endToken = startToken
class Date2Range extends X2RangeV2 {
  
  final TwoDigitToken start;
  final TwoDigitToken end;
    Date2Range(this.start, this.end);

  @override
  String toString() {
    return 'Date2Range($start-$end)';
  }
}

/// range for 1 Number only
class LoneNumber extends X1RangeV2 {
  final TwoDigitToken twoDigitToken;

  LoneNumber(this.twoDigitToken);
  @override
  String toString() {
    return 'LoneNumber($twoDigitToken)';
  }
}
/// range for 1 month only
class MonthRange extends X1RangeV2 {
  final MonthToken monthToken;
  MonthRange(this.monthToken);
  @override
  String toString() {
    return 'MonthRange($monthToken)';
  }
}



/// use month as start end Token and repeat them in the fields
class MonthDayRange extends X4Range {
  final MyToken startMonthToken;
  final MyToken startDayToken;

  final MyToken endMonthToken;
  final MyToken endDayToken;
  MonthDayRange({
    required this.startMonthToken,
    required this.startDayToken,
    required this.endMonthToken,
    required this.endDayToken,
  });

  @override
  String toString() {
    return 'MonthDayRange($startMonthToken $startDayToken -> $endMonthToken $endDayToken)';
  }
}

/// range for 1 weekday only
class LoneWeekDayRange extends X1RangeV2 {
  final WeekDayLyToken weekDayLyToken;

  LoneWeekDayRange(this.weekDayLyToken);
  @override
  String toString() {
    return 'LoneWeekDayRange($weekDayLyToken)';
  }
}

/// a range build from WeekDayLyToken
class WeekDayLyRange extends X2RangeV2 {
  final WeekDayLyToken start;
  final WeekDayLyToken end;
  WeekDayLyRange(this.start, this.end);
  @override
  String toString() {
    return 'WeekDayLyRange($start-$end)';
  }
}

/// used to describe errors.
///
/// repeat the Token is there is only one to fill the fields
class ErrorXRange extends XRangeV2 {
  final MyToken token;

  final String message;
  ErrorXRange(this.token, this.message);

  @override
  String toString() {
    return 'ErrorXRange($message, token: $token)';
  }
}
