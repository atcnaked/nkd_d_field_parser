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

final String monthRe = '(?:${months.keys.join('|')})';

/// a list of records of a month followed by a string (expected to be interpreted as dates).
/// 
/// if no month found returns ([], null)
/// It can parse Month in isolated dates
(List<(String, String)>?, String?) datesByMonth(String input) {
 if (input.isEmpty) {
   return (null, 'erro in datesByMonth, input is empty');
 }
  final RegExp regex = RegExp(monthRe);

  final matches = regex.allMatches(input).toList();

  if (matches.isEmpty) {
    return ([], null);
  }
  final firstNonMatch = input.substring(0, matches.first.start).trim();
  if (firstNonMatch != '' ) {
    return (
      null,
      'error parsing datesByMonth, the input is expected to start by a month but it starts with $firstNonMatch. \nThe parsed input is $input',
    );
  }

  // 2. Loop through the matches to build the pairs
  final pairs = <(String, String)>[];

  for (var i = 0; i < matches.length; i++) {
    final currentMatch = matches[i];
    final month = currentMatch.group(0)!;

    // Find where the next match starts so we can extract the non-match in between.
    // If we are on the last match, the non-match goes to the end of the string.
    final endOfCurrentMatch = currentMatch.end;
    final startOfNextMatch = (i + 1 < matches.length)
        ? matches[i + 1].start
        : input.length;

    final nonMatchText = input.substring(endOfCurrentMatch, startOfNextMatch).trim();

    pairs.add((month, nonMatchText));
  }

  return (pairs, null);
}




/* 

  // Rebuilding the string
  String rebuiltString = originalString.splitMapJoin(
    numberRegex,
    // What to do with the parts that MATCH the regex
    onMatch: (Match m) => m.group(0)!, 
    // What to do with the parts that DON'T match (the text between matches)
    onNonMatch: (String nonMatch) => nonMatch, 
  );

  print(originalString == rebuiltString); // true
 */