// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'my_token_class_tokenizer.dart';
import 'parser1.dart';

(List<XRange>?, String?) gatherAndProduceRange(List<MyToken> tokenizeds) {
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
  final List<(MyToken?, XRange?)> myTokenOrXRangeList = tokenizeds
      // if you do not do (e, null) as (MyToken?, XRange?) then the type of the list is (MyToken, Null) meading to error:
      // _TypeError (type '(Null, Null)' is not a subtype of type '(MyToken, Null)' of 'value')
      .map((e) => (e, null) as (MyToken?, XRange?))
      .toList();
  /* 
  if (hyphenIndexes.isEmpty) {
    print('TODO HyphenIndexes isEmpty=> no nedd');
  }
   */
  for (var idx in hyphenIndexes) {
    if (0 <= idx - 2 && idx + 2 < myTokenOrXRangeList.length) {
      final MonthDayRange? xRange4 = xRange4From(idx, myTokenOrXRangeList);

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
    final XRange? xRange2 = xRange2From(idx, myTokenOrXRangeList);
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
    final XRange xRange = loneRangeFrom(tk);
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
  final List<XRange> xRanges = myTokenOrXRangeList
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
MonthDayRange? xRange4From(int idx, List<(MyToken?, XRange?)> myTokenOrXRangeList) {
  if (idx - 2 < 0 || myTokenOrXRangeList.length <= idx + 2) {
    return null;
  }

  final prev2 = myTokenOrXRangeList[idx - 2].$1;
  final prev1 = myTokenOrXRangeList[idx - 1].$1;
  final next1 = myTokenOrXRangeList[idx + 1].$1;
  final next2 = myTokenOrXRangeList[idx + 2].$1;
  /* 
   */
  if (prev2 is! MonthToken ||
      prev1 is! TwoDigitToken ||
      next1 is! MonthToken ||
      next2 is! TwoDigitToken) {
    return null;
  }
  // useless but avoid null checks
  /* 
  if (prev2 == null || prev1 == null || next1 == null || next2 == null) {
    return null;
  } */
  return MonthDayRange(
    prev2,
    next2,
    startMonthToken: prev2,
    startDayToken: prev1,
    endMonthToken: next1,
    endDayToken: next2,
  );
}

/// returns the XRange of 2 values (before and after index) in provided List. Null if Not possible.
XRange? xRange2From(int idx, List<(MyToken?, XRange?)> myTokenOrXRangeList) {
  final prev = myTokenOrXRangeList[idx - 1].$1;
  final next = myTokenOrXRangeList[idx + 1].$1;

  if (prev == null || next == null) {
    return null;
  }
  final XRange? xRange = myXRange2From(prev, next);

  return xRange;
}

/// returns the XRange of 1 values. Error if Not possible.
XRange loneRangeFrom(MyToken theToken) {
  if (theToken is TwoDigitToken) {
    return Date2Range(theToken, theToken);
  }
  if (theToken is MonthToken) {
    return MonthRange(theToken, theToken);
  }
  if (theToken is WeekDayLyToken) {
    return WeekDayLyRange(theToken, theToken);
  }
  return ErrorXRange(
    theToken,
    theToken,
    'incorrect type error: ${theToken.runtimeType}',
  );
}

/// returns the XRange of 2 values. Null if Not possible.
XRange? myXRange2From(MyToken prev, MyToken next) {
  if (prev is TimeToken && next is TimeToken) {
    return TimeRange(prev, next);
  }
  if (prev is TwoDigitToken && next is TwoDigitToken) {
    return Date2Range(prev, next);
  }
  if (prev is MonthToken && next is MonthToken) {
    return MonthRange(prev, next);
  }
  if (prev is WeekDayLyToken && next is WeekDayLyToken) {
    return WeekDayLyRange(prev, next);
  }
  return null;
}

sealed class XRange {
  final MyToken startToken;
  final MyToken endToken;

  XRange(this.startToken, this.endToken);
  @override
  String toString() {
    return 'XRange($startToken-$endToken)';
  }
}

class TimeRange extends XRange {
  TimeRange(super.startToken, super.endToken);
}

class Date2Range extends XRange {
  Date2Range(super.startToken, super.endToken);
}

class MonthRange extends XRange {
  MonthRange(super.startToken, super.endToken);
}

/// use month as start end Token and repeat them in the fields
class MonthDayRange extends XRange {
  final MyToken startMonthToken;
  final MyToken startDayToken;

  final MyToken endMonthToken;
  final MyToken endDayToken;
  MonthDayRange(
    super.startToken,
    super.endToken, {
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

class WeekDayLyRange extends XRange {
  WeekDayLyRange(super.startToken, super.endToken);
}

/// used to describe errors.
///
/// repeat the Token is there is only one to fill the fields
class ErrorXRange extends XRange {
  final String message;
  ErrorXRange(super.startToken, super.endToken, this.message);

  @override
  String toString() {
    return 'ErrorXRange($message)';
  }
}
