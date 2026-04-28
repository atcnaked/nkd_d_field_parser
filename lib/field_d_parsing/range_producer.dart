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
  //final XRange?  nullRange = null;
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
    final XRange? xRange = xRange2From(idx, myTokenOrXRangeList);
    if (xRange == null) {
      continue;
    }
    //  print('found XRange: $xRange at index: $idx');
    // print('myTokenOrXRangeList before: $myTokenOrXRangeList before');
    myTokenOrXRangeList[idx - 1] = (null, null);
    myTokenOrXRangeList[idx] = (null, xRange);
    myTokenOrXRangeList[idx + 1] = (null, null);
    // print('myTokenOrXRangeList after: $myTokenOrXRangeList before');
  }
  print('');
  // do the dame for xRange4From

  /* 
  */
  // then create loneRangeFrom
  for (var i = 0; i < myTokenOrXRangeList.length; i++) {
    final tk = myTokenOrXRangeList[i].$1;
    if (tk == null) {
      continue;
    }
    final XRange xRange = loneRangeFrom(tk);
    myTokenOrXRangeList[i] = (null, xRange);
  }
  // checking that all token has been consumed
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

  // remove null,null
  // final List<(MyToken?, XRange?)> myTokenOrXRangeListNullsRemoved11 =      myTokenOrXRangeList.where((e) => e.$1 != null && e.$2 != null).toList();

  // disregarding null xRange (only found in null, null in theory)
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

class MonthDayRange extends XRange {
  MonthDayRange(super.startToken, super.endToken);
}

class WeekDayLyRange extends XRange {
  WeekDayLyRange(super.startToken, super.endToken);
}

class ErrorXRange extends XRange {
  final String message;
  ErrorXRange(super.startToken, super.endToken, this.message);

  @override
  String toString() {
    return 'ErrorXRange($message)';
  }
}
