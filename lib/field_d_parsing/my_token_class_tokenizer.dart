// ignore_for_file: public_member_api_docs, sort_constructors_first
// tokenizer.dart

/* * 1. Define the Sealed Classes
 * * Using a sealed class ensures that we can use exhaustive pattern matching 
 * (like switch statements) later on. The compiler will know exactly which 
 * subclasses exist.
 */
sealed class MyToken {
  final String word;

  MyToken(this.word);
}

sealed class IntermediateToken extends MyToken {
  IntermediateToken(super.word);
}

class HourOrYearToken extends IntermediateToken {
  HourOrYearToken(super.word);

  @override
  String toString() => 'HourOrYearToken($word)';
}

/// Represents a 1 or 2- digit number
class TwoDigitToken extends MyToken {
  TwoDigitToken(super.word);

  @override
  String toString() => 'TwoDigitToken($word)';
}

// LUN...SAT, SUN and DAILY
class WeekDayLyToken extends MyToken {
  WeekDayLyToken(super.word);

  @override
  String toString() => 'WeekDayLyToken($word)';
}

class MonthToken extends MyToken {
  MonthToken(super.word);

  @override
  String toString() => 'MonthToken($word)';
}

class HyphenToken extends MyToken {
  HyphenToken(super.word);

  @override
  String toString() => 'HyphenToken($word)';
}

class YearToken extends MyToken {
  YearToken(super.word);

  @override
  String toString() => 'YearToken($word)';
}

class ErrorToken extends MyToken {
  ErrorToken(super.word);

  @override
  String toString() => 'ErrorToken(word: $word)';
}

/// used to handle indexes side effects at end list
class DummyToken extends MyToken {
  DummyToken() : super('');

  @override
  String toString() =>
      'DummyToken('
      ')';
}

class PlusToken extends IntermediateToken {
  PlusToken(super.word);
  //;:paramm.length==1?super.(paramm.substring(4)) :paramm.substring(4);

  @override
  String toString() => 'PlusToken($word)';
}

class MinusToken extends IntermediateToken {
  MinusToken(super.word);

  @override
  String toString() => 'MinusToken($word)';
}

class SunriseIntermediateToken extends IntermediateToken {
  SunriseIntermediateToken(super.word);

  @override
  String toString() => 'SunriseIntermediateToken($word)';
}

class SunsetIntermediateToken extends IntermediateToken {
  SunsetIntermediateToken(super.word);

  @override
  String toString() => 'SunsetIntermediateToken($word)';
}

class SrSsToken extends TimeToken {
  final String event;
  final String sign;
  final String minute;

  SrSsToken(
    super.word, {
    required this.event,
    required this.sign,
    required this.minute,
  });

  @override
  String toString() => int.parse(minute) == 0
      ? 'SrSsToken($event)'
      : 'SrSsToken($event $sign $minute)';
}

sealed class TimeToken extends MyToken {
  TimeToken(super.word);
}

class HourToken extends TimeToken {
  HourToken(super.word);

  @override
  String toString() => 'HourToken($word)';
}

class HCodeToken extends MyToken {
  HCodeToken(super.word);

  @override
  String toString() => 'HCodeToken($word)';
}

/*
 * 2. Create a Token Rule Helper
 * * This class binds a regular expression to a builder function that 
 * constructs the appropriate Token subclass when a match is found.
 */
class TokenRule {
  final RegExp regex;
  final MyToken Function(String match) builder;

  // The constructor automatically wraps the pattern in ^ and $
  // to ensure the regex matches the entire string, not just a substring.
  TokenRule(String pattern, this.builder) : regex = RegExp('^$pattern\$');
}

// 1. Constants
const Map<String, String> events = {'SR': 'sunrise', 'SS': 'sunset'};
/*   const Map<String, AixmTime> eventHours = {
    'sunrise': AixmTime.literal('06:00'), 
    'sunset': AixmTime.literal('18:00')
  }; */
const Map<String, int> operations = {'PLUS': 1, 'MINUS': -1};
const Map<String, int> months = {
  'JAN': 1,
  'FEB': 2,
  'MAR': 3,
  'APR': 4,
  'MAY': 5,
  'JUN': 6,
  'JUL': 7,
  'AUG': 8,
  'SEP': 9,
  'OCT': 10,
  'NOV': 11,
  'DEC': 12,
};
const Map<String, String> days = {
  'MON': 'monday',
  'TUE': 'tuesday',
  'WED': 'wednesday',
  'THU': 'thursday',
  'FRI': 'friday',
  'SAT': 'saturday',
  'SUN': 'sunday',
  'DAILY': 'any',
  'DLY': 'any',
};

// 2. Regex Patterns
const String dateRe = r'(?:[0-2]\d|3[01])';
const String yearAnd4digitsRe = r'(?:\d\d\d\d)';
final String dayRe = '(?:${days.keys.join('|')})';
final String monthRe = '(?:${months.keys.join('|')})';
const String hcodeRe = r'(?<hcode>H24|HJ|HN)';
const String hourRe = r'(?<hour>[01]\d|2[0-4])(?<minute>[0-5]\d)';
final String operationsRe = '(?:${operations.keys.join('|')})';
final String eventRe =
    '(?<event>SR|SS)(?:\\s(?<operation>$operationsRe)(?<delta>\\d+))?';
final String timeRe = '(?:$hourRe|$eventRe)';
final String timeRangeRe = '(?:$timeRe-$timeRe|$hcodeRe)';
final String datetimeRe =
    '(?:(?<month>$monthRe) )?(?<date>$dateRe) (?<time>$timeRe)';
final String datetimeRangeRe = '$datetimeRe-$datetimeRe';
/*
 * 3. Define the Rules
 * * This list determines the priority of our tokens. The tokenizer will 
 * check each string against these rules in order.
 */
final tokenRules = <TokenRule>[
  // Rule for days: matches 1 or 2 digits and converts the match to an int.
  TokenRule(r'\d\d?', (match) => TwoDigitToken(match)),

  // Rule for words: matches alphabetic characters.
  TokenRule('$dateRe', (match) => TwoDigitToken(match)),
  TokenRule('$dayRe', (match) => WeekDayLyToken(match)),
  TokenRule('$monthRe', (match) => MonthToken(match)),
  TokenRule(r'-', (match) => HyphenToken(match)),
  // TokenRule('$yearRe', (match) => YearToken(match)),
  TokenRule(r'PLUS\d\d', (match) => PlusToken(match)),
  TokenRule(r'MINUS\d\d', (match) => MinusToken(match)),
  TokenRule(r'SR', (match) => SunriseIntermediateToken(match)),
  TokenRule(r'SS', (match) => SunsetIntermediateToken(match)),
  // TokenRule('$hourRe', (match) => HourToken(match)),
  TokenRule('$hcodeRe', (match) => HCodeToken(match)),
  TokenRule('$yearAnd4digitsRe', (match) => HourOrYearToken(match)),
  TokenRule(r'.*', (match) => ErrorToken(match)),
];

(List<MyToken>, String?) tokenize(List<String> inputs) {
  final iRes = intermediateTokenize(inputs);
  if (iRes.$2 != null) {
    return iRes;
  }
  print('iRes.1: ${iRes.$1.join(' ')}');
  return fullTokenize(iRes.$1);
}

(List<MyToken>, String?) fullTokenize(List<MyToken> tokens) {
  final List<MyToken> res = [];
  final List<YearToken> yearTokenErrorList = [];

  // IntermediateToken? previousSrOrSr;
  if (tokens.isEmpty) {
    return ([], null);
  }
  if (tokens.length == 1) {
    final token = tokens.first;
    if (token is IntermediateToken) {
      return (
        [token],
        'error, List contains one element of type IntermediateToken, epecting MyToken, token: $token',
      );
    }

    return ([token], null);
  }
  bool previousOperationConsumedBothToken = false;
  final List<MyToken> tokensWithDummy = [...tokens, DummyToken()];
  for (var i = 0; i < tokensWithDummy.length - 1; i++) {
    // final pair = ();
    final token = tokensWithDummy[i];
    final nextToken = tokensWithDummy[i + 1];

    if (previousOperationConsumedBothToken) {
      previousOperationConsumedBothToken = false;
      continue;
    }

    // dealing with  SS or SR +/- case
    if (nextToken is MinusToken || nextToken is PlusToken) {
      if (token is! SunriseIntermediateToken &&
          token is! SunsetIntermediateToken) {
        return (
          res,
          'error in parsing, expecting SunriseIntermediateToken or SunriseIntermediateToken before a plus minus Token, found $token',
        );
      }

      final sign = nextToken is MinusToken ? '-' : '+';
      final minute = nextToken is MinusToken
          ? nextToken.word.substring(5)
          : nextToken.word.substring(4);
      final SrSsToken srSsToken = SrSsToken(
        '${token.word}$sign${nextToken.word}',
        event: token.word,
        sign: sign,
        minute: minute, //nextToken.word,
      );
      res.add(srSsToken);

      previousOperationConsumedBothToken = true;
      continue;
    }
    // dealing with simple SS or SR (as +/- case was handle before)
    if (token is SunriseIntermediateToken || token is SunsetIntermediateToken) {
      final SrSsToken srSsToken = SrSsToken(
        '${token.word}',
        event: token.word,
        sign: '+',
        minute: '0', //nextToken.word,
      );
      res.add(srSsToken);

      previousOperationConsumedBothToken = false;
      continue;
    }

    // tell between year and hours: 4 digits beside an hyphen is an hour
    if (token is HourOrYearToken) {
      if (nextToken is HyphenToken) {
        res.add(HourToken(token.word));
      } else {
        final yearToken = YearToken(token.word);
        res.add(yearToken);
        yearTokenErrorList.add(yearToken);
      }
      previousOperationConsumedBothToken = false;
      continue;
    }

    if (token is HyphenToken) {
      res.add(token);

      if (nextToken is HourOrYearToken) {
        res.add(HourToken(nextToken.word));
        previousOperationConsumedBothToken = true;
        continue;
      } else {
        // decision will be made at next iteration
        previousOperationConsumedBothToken = false;
        continue;
      }
    }

    res.add(token);
    previousOperationConsumedBothToken = false;
    continue;
  }
  if (yearTokenErrorList.isNotEmpty) {
    final errorTokenMessage =
        '''finalizing token parsing error: ${yearTokenErrorList.length} ErrorToken found for words: ${yearTokenErrorList.join(', ')}. 
This parser does not allow year in the D field.
Tokens where the error occured: ${tokens.join(', ')}. 
         Result of this conversion: $res''';
    return (res, errorTokenMessage);
  }

  return (res, null);
}

/// either tokenized List with null or partial tokenized List with error
(List<MyToken>, String?) intermediateTokenize(List<String> inputs) {
  final List<MyToken> res = [];
  final List<String> wordErrors = [];
  String errorTokenMessage = '';
  for (var word in inputs) {
    if (word.isEmpty) {
      final index = inputs.indexed.firstWhere((element) => element.$2.isEmpty);
      return (
        [],
        'the list of inputs words contains an empty String which is at index: $index of the list: $inputs',
      );
    }
    try {
      // bool hasError = false;
      // Iterate through all defined rules.
      for (final rule in tokenRules) {
        // final regePattern = rule.regex.pattern;
        // If the regex matches the input string exactly...
        if (rule.regex.hasMatch(word)) {
          // ...use the builder to create and return the specific Token.
          final token = rule.builder(word);
          res.add(token);
          if (token is ErrorToken) {
            wordErrors.add(word);
            errorTokenMessage =
                'intermediate token parsing error: ${wordErrors.length} ErrorToken found for words: ${wordErrors.join(', ')}';
          }
          break;
        }
      } /* 
      if (res.isEmpty) {
        return ([], 'list is empty');
      } */
    } catch (e) {
      final errorMessage2 = errorTokenMessage == ''
          ? ''
          : '\nWhen this error occured, there was a $errorTokenMessage';
      return (res, 'error while parsing: $e$errorMessage2');
    }
  }
  if (wordErrors.isEmpty) {
    return (res, null);
  } else {
    return (res, errorTokenMessage);
  }
}
/* 
/*
 * 5. Main Execution
 * * A simple test to demonstrate how the tokenizer works in practice.
 */
void main() {
  // Our raw list of strings, where each string is exactly one token.
  final rawStrings = ['12', 'January', '5', 'Friday'];

  try {
    // Convert the list of strings into a list of Tokens.
    final tokens = tokenize(rawStrings);

    // Print the list of generated tokens.
    print('Tokens generated: \n$tokens\n');

    // Example of exhaustive pattern matching using Dart 3 switch.
    print('Evaluating tokens:');
    for (final token in tokens) {
      switch (token) {
        case DayToken(day: final d):
          // Extracted the 'day' integer field into 'd'.
          print(' -> It is day $d');
        case WeekDayLyToken(word: final w):
          // Extracted the 'word' string field into 'w'.
          print(' -> The word is $w');
      }
    }
  } catch (e) {
    print(e);
  }
}
 */