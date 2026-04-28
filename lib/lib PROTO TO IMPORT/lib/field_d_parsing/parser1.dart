// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'examples_var.dart';
import 'my_token_class_tokenizer.dart';
import 'range_producer.dart';

void parseLines() {
  // adding space around hyphens so that they are isolated after sanitization
  final exD1Hyphen = examplesL6.replaceAll(RegExp(r'-'), ' - ');
  final sanitized = exD1Hyphen.replaceAll(RegExp(r' +'), ' ');

  //final OneLine = exD1.replaceAll(RegExp(r'\n'), '');

  final lines = sanitized.split(RegExp(r'\n'));

  for (var line in lines) {
    print('\nhandling line: $line');
    final trimmed = line.trim();
    final blocks = trimmed.split(', ');
    //  print('parsing blocks: $blocks');
    final blockUnits = <BlockUnit>[];
    for (var block in blocks) {
      final BlockUnit blockUnit;
      final splt = block.split('EXC');
      if (splt.length == 1) {
        blockUnit = BlockUnit.fromParams(
          rulesP: block.trim(),
          exclusionP: null,
        );
      } else if (splt.length == 2) {
        blockUnit = BlockUnit.fromParams(
          rulesP: splt[0].trim(),
          exclusionP: splt[1].trim(),
        );
      } else {
        throw Exception(
          'splitted block after EXC split should have length 1 or 2, found ${splt.length}, \noriginal block: $block ',
        );
      }
      blockUnits.add(blockUnit);

      // print(trimmed);
    }

    for (var indexedBlockUnit in blockUnits.indexed) {
      final int length = blockUnits.length;
      final int idx = indexedBlockUnit.$1;
      final BlockUnit blockUnit = indexedBlockUnit.$2;
      print('\n=> blockUnit ${idx + 1}/$length: $blockUnit');
      print('tokenizing blockUnit.rulesAsList: ${blockUnit.rulesAsList}');
      final tokenizedRules = tokenize(blockUnit.rulesAsList);
      print(
        'tokenizing blockUnit.exclusionAsList: ${blockUnit.exclusionAsList}',
      );
      final tokenizedExclusions = blockUnit.exclusionAsList.isNotEmpty
          ? tokenize(blockUnit.exclusionAsList)
          : (<MyToken>[], null);
      if (tokenizedRules.$2 != null) {
        print('${tokenizedRules.$2}, tokens: ${tokenizedRules.$1}');
        continue;
      }
      if (tokenizedExclusions.$2 != null) {
        print('${tokenizedExclusions.$2}, tokens: ${tokenizedExclusions.$1}');
        continue;
      }

      print('tokenizedRules.1=>${tokenizedRules.$1.join(' ')}');
      print('tokenizedExclusions.1=>${tokenizedExclusions.$1.join(' ')}');
      // gathering and producing range

      final (List<XRange>?, String?) xRangesResult = gatherAndProduceRange(
        tokenizedRules.$1,
      );

      if (xRangesResult.$2 != null) {
        print('error in gatherAndProduceRange: ${xRangesResult.$2}');
      }
      print('\n(recall) handling line: $line');

      print('OK gatherAndProduceRange: ${xRangesResult.$1}');
    }
  }
}

/// some rules with an optional exclusion
///
/// parameters must not have been sanitized with simple space
class BlockUnit {
  final String rules;
  final String exclusion;
  final List<String> rulesAsList;
  final List<String> exclusionAsList;

  BlockUnit.fromParams({required String rulesP, required String? exclusionP})
    : rules = rulesP.trim(),
      exclusion = exclusionP == null ? '' : exclusionP.trim(),
      rulesAsList = rulesP.trim().split(' '),
      exclusionAsList = exclusionP == null ? [] : exclusionP.split(' ');
  BlockUnit({
    required this.rules,
    required this.exclusion,
    required this.rulesAsList,
    required this.exclusionAsList,
  });

  @override
  String toString() => 'BlockUnit(rules: $rules, exclusion: $exclusion)';
}

/* 

1. The Core Limitations

    Maximum Length: Under OPADD rules, Item D is explicitly not allowed to exceed 200 characters. If a schedule is too complex to fit, the originator is supposed to split it into two separate NOTAMs.

    Time Format: OPADD enforces a strict HHMM (UTC) format for times.

    "End of Day": OPADD mandates the use of 2359 for the end of the day. You will not see 2400 in a compliant European NOTAM D field (unlike AIPs, which sometimes use 2400).

2. The Three Standardized OPADD Schedule Types

OPADD (and the AIXM Digital NOTAM event specification it aligns with) recognizes exactly three types of schedules for Item D. When parsing French SIA NOTAMs, you are almost guaranteed to be parsing one of these formats (or a combination):
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
