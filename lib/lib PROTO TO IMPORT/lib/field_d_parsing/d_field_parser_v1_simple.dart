// ignore_for_file: public_member_api_docs, sort_constructors_first
/* 

The Three Standardized OPADD Schedule Types

OPADD (and the AIXM Digital NOTAM event specification it aligns with) recognizes exactly three types of 
schedules for Item D. When parsing French SIA NOTAMs, you are almost guaranteed to be parsing one of these 
formats (or a combination):
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

    Spanning Midnight: If a time block is 2200-0500, the parser must know that 0500 applies to the following day. 
    OPADD implies this logically if the end time is numerically smaller than the start time.

    The EXC Keyword: Exceptions (EXC) are heavily used. OPADD allows excluding specific dates (like EXC SEP 09), 
    but usually discourages vague terms like "Holidays" in Item D because a computer cannot easily parse local holidays 
    without a massive database. */

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

sealed class DPart {
  final String rule;
  DPart(this.rule);
}

class PartWithException extends DPart {
  final String exc;

  PartWithException(super.rule, {required this.exc});
}

class SimpleDPart extends DPart {
  SimpleDPart(super.rule);
}

DPart getDBlockFrom(String blockString) {
  final splt = blockString.split('EXC');
  if (splt.length == 1) {
    return SimpleDPart(blockString);
  }
  return PartWithException(splt[0], exc: splt[1]);
}

class DLine {
  final List<DPart> parts;
  DLine({required this.parts});
}

DLine? getDLineFrom(String dFieldStringFormatted) {
  try {
    final List<DPart> parts = dFieldStringFormatted
        .split(',')
        .map((e) => e.trim())
        .map((e) => getDBlockFrom(e))
        .toList();
    return DLine(parts: parts);
  } catch (e) {
    log(
      'while producing DLine from dFieldString: $dFieldStringFormatted\nTheError was: $e',
    );
    return null;
  }
}

bool isOne(int n) {
  return n == 1;
}
