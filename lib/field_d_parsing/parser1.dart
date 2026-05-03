// ignore_for_file: public_member_api_docs, sort_constructors_first
//import 'decoded_rules.dart';
import 'examples_var.dart';
import 'my_token_class_tokenizer.dart';
import 'range_producer.dart';
//import 'range_v2_producer.dart';

 parseLines() {
  // adding space around hyphens so that they are isolated after sanitization
  final exD1Hyphen = examplesValid1.replaceAll(RegExp(r'-'), ' - ');
  final sanitized = exD1Hyphen.replaceAll(RegExp(r' +'), ' ');

  //final OneLine = exD1.replaceAll(RegExp(r'\n'), '');

  final lines = sanitized.split(RegExp(r'\n'));

  for (var line in lines) {
    print('\nhandling line: $line');
    final trimmed = line.trim();
    final blockOrScheduleElements = trimmed.split(', ');
    //  print('parsing blocks: $blocks');
    final blockUnitsOrScheduleElements = <BlockUnitOrScheduleElement>[];
    for (var blockOrScheduleElement in blockOrScheduleElements) {
      final BlockUnitOrScheduleElement blockUnitOrScheduleElement;
      final splt = blockOrScheduleElement.split('EXC');
      if (splt.length == 1) {
        blockUnitOrScheduleElement = BlockUnitOrScheduleElement.fromParams(
          rulesP: blockOrScheduleElement.trim(),
          exclusionP: null,
        );
      } else if (splt.length == 2) {
        blockUnitOrScheduleElement = BlockUnitOrScheduleElement.fromParams(
          rulesP: splt[0].trim(),
          exclusionP: splt[1].trim(),
        );
      } else {
        throw Exception(
          'splitted block after EXC split should have length 1 or 2, found ${splt.length}, \noriginal blockUnitOrScheduleElement: $blockOrScheduleElement ',
        );
      }
      blockUnitsOrScheduleElements.add(blockUnitOrScheduleElement);

      // print(trimmed);
    }

    for (var indexedBlockUnit in blockUnitsOrScheduleElements.indexed) {
      final int length = blockUnitsOrScheduleElements.length;
      final int idx = indexedBlockUnit.$1;
      final BlockUnitOrScheduleElement blockUnitOrScheduleElement = indexedBlockUnit.$2;
      print('\n=> blockUnitOrScheduleElement ${idx + 1}/$length: $blockUnitOrScheduleElement');
      print('tokenizing blockUnitOrScheduleElement.rulesAsList: ${blockUnitOrScheduleElement.rulesAsList}');
      final tokenizedRules = tokenize(blockUnitOrScheduleElement.rulesAsList);
      print(
        'tokenizing blockUnitOrScheduleElement.exclusionAsList: ${blockUnitOrScheduleElement.exclusionAsList}',
      );
      final tokenizedExclusions = blockUnitOrScheduleElement.exclusionAsList.isNotEmpty
          ? tokenize(blockUnitOrScheduleElement.exclusionAsList)
          : (<MyToken>[], null);
      if (tokenizedRules.$2 != null) {
        print('${tokenizedRules.$2}, tokens: ${tokenizedRules.$1}');
        continue;
      }
      if (tokenizedExclusions.$2 != null) {
        print('${tokenizedExclusions.$2}, tokens: ${tokenizedExclusions.$1}');
        continue;
      }

      print('List<MyToken> tokenizedRules = ${tokenizedRules.$1.join(' ')}');
      print(
        'List<MyToken> tokenizedExclusions = ${tokenizedExclusions.$1.join(' ')}',
      );

/* 
      final (List<XRangeV2>?, String?) xRangesLikeResult = gatherAndProduceRangeLikeV2(
        tokenizedRules.$1,
      );

      
      if (xRangesLikeResult.$2 != null) {
        print('error in gatherAndProduceRange: ${xRangesLikeResult.$2}');
      }
      print('\n(recall) handling line: $line');

      print('OK gatherAndProduceRange: ${xRangesLikeResult.$1}');

 */
//////////////////////////////
//////////////////////////////

      // gathering and producing range

      final (List<XRange>?, String?) xRangesResult = gatherAndProduceRange(
        tokenizedRules.$1,
      );

      if (xRangesResult.$2 != null) {
        print('error in gatherAndProduceRange: ${xRangesResult.$2}');
      }
      print('\n(recall) handling line: $line');

      print('OK gatherAndProduceRange: ${xRangesResult.$1}');

      // try to read List<XRange> from L to R
      // we need a context?
      final List<XRange> ranges =xRangesResult.$1!;
      if (ranges.isEmpty) {
        // NB: if the func return void the compiler refuses because it has to return void. 
        // if I remove void (so it becomes dynamic then now I can throw)
        return throw Exception('List<XRange> is empty');
      }
      final DateTime B = DateTime(2026);
      final DateTime C= DateTime(2026);
    //  final Map<DateTime,List<DateTime>> decodedRules = getDecodedOf(ranges,B,C);
//////////////////////////////
//////////////////////////////
//////////////////////////////
//////////////////////////////
      
    }
  }
}
/* 
"2.3.19.4:  Punctuation:
‘ , ’ (comma) for separation of the schedule elements:
- groups of dates or days to which the same time periods
apply.
- groups of time periods that all apply to the preceding and
qualifying dates or days"

=> schedule element = groups  dates or days + groups of time periods

=> a 'date' is:
- a day number, 
- a month followed by a day number, 
- NO ! :  a weekday

time period = 0800-1000
time periods = 0800-1000 1200-1300 1800-2030



=> however nothing distinguish between with or without date:
 0800-1000 and APR 1 0800- MAY 5 0200

 */

/* 
timeframe seems to be the notam validity (see below)

"
Item D) – Day/Time Schedule – Abbreviations and symbols used
Abbreviations and punctuation when used in Item D) shall be applied as described
in the following paragraphs.
Abbreviations for Dates and Times:
Year: The year shall not be inserted in Item D), as it is stated in Items B)
and C).
When the planned time schedule goes from one year into another,
the displayed data shall remain in chronological order; i.e.
December of this year shall precede January of next year.
Months: JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC

// EUROCONTROL Guidelines Operating Procedures AIS Dynamic Data (OPADD)
// Edition 4.1 Released Issue Page 41

Dates: 01 02 03 .... 29 30 31
Days: MON TUE WED THU FRI SAT SUN
Times: Written as 4 digits (e.g.: 1030)
Abbreviations for Time Periods and associated text:
‘EXC’ for designating a full day or a series of full days when the NOTAM
is NOT active.
Note: Full day exceptions are not allowed for timeframes spanning midnight.
Using ‘recurrent’ exceptions such as ‘except every Monday’ or ‘except
Saturdays and Sundays’ shall be avoided.
‘DAILY’ is optional, but recommended for activities applied every day from
Item B) to Item C) inclusive. The expression 'nightly' shall not be
used.
‘EVERY’ for a schedule on fixed days.
‘H24’ for the period 0000-2359 on the day/dates concerned. Not to be
used as a single entry.
‘SR’ and/or ‘SS’ if appropriate to indicate Sunrise or Sunset.
Punctuation:
‘ , ’ (comma) for separation of the schedule elements:
- groups of dates or days to which the same time periods
apply.
- groups of time periods that all apply to the preceding and
qualifying dates or days.
(refer to paragraph 2.3.19.5 for the recommended syntax
and paragraph 2.3.21.1 for clarification).
The use of the comma for enumeration is not allowed.
‘ - ’ (hyphen) means ‘TO’ or ‘FROM-TO’
Note: ‘ / ’ (oblique) shall not be used in Item D).
The use of the commas in Item D) is recommended as it helps both human and
system readability. If used, a comma shall be placed, always and only, after a time schedule
and only if the latter is immediately followed by a date
"




 */

/// some rules with an optional exclusion
///
/// parameters must not have been sanitized with simple space
class BlockUnitOrScheduleElement {
  final String rules;
  final String exclusion;
  final List<String> rulesAsList;
  final List<String> exclusionAsList;

  BlockUnitOrScheduleElement.fromParams({required String rulesP, required String? exclusionP})
    : rules = rulesP.trim(),
      exclusion = exclusionP == null ? '' : exclusionP.trim(),
      rulesAsList = rulesP.trim().split(' '),
      exclusionAsList = exclusionP == null ? [] : exclusionP.split(' ');
  BlockUnitOrScheduleElement({
    required this.rules,
    required this.exclusion,
    required this.rulesAsList,
    required this.exclusionAsList,
  });

  @override
  String toString() => 'BlockUnitOrScheduleElement(rules: $rules, exclusion: $exclusion)';
}

/* 

1. The Core Limitations

    Maximum Length: Under OPADD rules, Item D is explicitly not allowed to exceed 200 characters. If a schedule is too complex to fit, the originator is supposed to split it into two separate NOTAMs.

    Time Format: OPADD enforces a strict HHMM (UTC) format for times.

    "End of Day": OPADD mandates the use of 2359 for the end of the day. You will not see 2400 in a compliant European NOTAM D field (unlike AIPs, which sometimes use 2400).

2. The Three Standardized OPADD Schedule Types

OPADD (and the AIXM Digital NOTAM event specification it aligns with) recognizes exactly three types of schedules for Item D. 
When parsing French SIA NOTAMs, you are almost guaranteed to be parsing one of these formats (or a combination):
Type A: Daily Schedules

The simplest format. It indicates times that apply every day during the NOTAM's validity period.

    Format Example: 0900-1200 1700-2100

    Format Example: SR-1800 (Sun-relative)

    Format Example: 2200-0700 (Spanning past midnight)

    Format Example: 0700-2359 EXC DEC 25 JAN 01 (Daily with specific date exceptions)

Type B: Date-Based Schedules

This is where specific dates or date ranges are provided before the time.

    Format Example: OCT 01 0900-1500, OCT 03 1000-1200

    Format Example: SEP 09-16 0000-2359, SEP 18 SR-1800

Type C: Weekday-Based Schedules

This uses days of the week, either individually or in ranges.

    Format Example: MON-FRI 1300-SS

    Format Example: MON TUE WED THU FRI 1300-SS, SAT SUN 1300-1500

    Format Example: SUN 2300-0500 (Note how this implies crossing into Monday)

    Format Example: MON-FRI 0900-1700 EXC SEP 09

3. Syntax Quirks to Watch Out For

Even with OPADD, there are a few syntax rules your parser needs to handle:

    The Comma Separator: Different schedule blocks are separated by commas. E.g., MON-FRI 0900-1200, SAT SUN 1000-1100.

    Sun-Relative Times: SR (Sunrise) and SS (Sunset) are frequently used and can include offsets like PLUS30 or MINUS15.

    Spanning Midnight: If a time block is 2200-0500, the parser must know that 0500 applies to the following day. OPADD implies this logically if the end time is numerically smaller than the start time.

    The EXC Keyword: Exceptions (EXC) are heavily used. OPADD allows excluding specific dates (like EXC SEP 09), but usually discourages vague terms like "Holidays" in Item D because a computer cannot easily parse local holidays without a massive database.

Because the French SIA adheres to these EAD/OPADD guidelines, you can safely write your parsing logic (like the Python state machine we discussed previously) specifically to look for these three distinct patterns rather than trying to account for every weird edge case imaginable globally.

Whenever you have your specific SIA examples ready, we can put them through the wringer! Would you like to review how to handle the EXC logic in Python before you test your actual data?
 */
