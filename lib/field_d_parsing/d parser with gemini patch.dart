static List<dynamic> _datesFrom(String string, DateTime baseDate) {
    if (string.isEmpty) return [];
    List<dynamic> array = [];
    
    int index = 0;
    while (index < string.length) {
      // Get the true remaining string to calculate skipped spaces
      final remainingNotTrimmed = string.substring(index);
      final remaining = remainingNotTrimmed.trimLeft();
      
      if (remaining.isEmpty) break;

      // Calculate exactly how many spaces we just skipped
      final spacesSkipped = remainingNotTrimmed.length - remaining.length;

      // 1. Check for Date Range (Matches: "01-05" OR "30-FEB 02")
      final rangeMatch = RegExp(
        '^(?<from>$dateRe)-(?:(?<month>$monthRe) )?(?<to>$dateRe)'
        ).firstMatch(remaining);
      if (rangeMatch != null) {
        final fromDay = int.parse(rangeMatch.namedGroup('from')!);
        final toDay = int.parse(rangeMatch.namedGroup('to')!);
        final monthStr = rangeMatch.namedGroup('month');
        
        final startMonth = baseDate.month;
        final endMonth = monthStr != null ? months[monthStr]! : baseDate.month;

        array.add(AixmRange(
          AixmDate(DateTime(baseDate.year, startMonth, fromDay)),
          AixmDate(DateTime(baseDate.year, endMonth, toDay))
        ));
        
        // Advance the reading head: skipped spaces + length of the matched regex
        index += spacesSkipped + rangeMatch.end;
        continue;
      }

      // 2. Check for Single Date (Matches: "15" or "01")
      final dateMatch = RegExp('^(?<day>$dateRe)').firstMatch(remaining);
      if (dateMatch != null) {
         array.add(AixmDate(DateTime(
          baseDate.year, baseDate.month, int.parse(dateMatch.namedGroup('day')!))));
         
         // Advance the reading head
         index += spacesSkipped + dateMatch.end;
         continue;
      }

      // 3. Check for Month Context Shift (Matches: "JAN" or "FEB")
      final monthMatch = RegExp('^(?<month>$monthRe)').
      firstMatch(remaining);
      if (monthMatch != null) {
         final newMonth = months[monthMatch.namedGroup('month')!]!;
         baseDate = DateTime(baseDate.year, newMonth, 1);
         
         // Advance the reading head
         index += spacesSkipped + monthMatch.end;
         continue;
      }

      throw FormatException('Unrecognized date formatting at: $remaining');
    }
    
    return array;
  }











