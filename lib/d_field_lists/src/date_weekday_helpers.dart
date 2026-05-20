
  // Helper to map 1 to "MON", 2 to "TUE", etc.
   String dayIntToWeekday(int intDay) {
    const map = {
      1: 'MON',
      2: 'TUE',
      3: 'WED',
      4: 'THU',
      5: 'FRI',
      6: 'SAT',
      7: 'SUN',
    };
    final res = map[intDay];
    if (res == null) {
      throw Exception(
        'could not get corresponding day from intDay: $intDay in _dayStringToWeekday',
      );
    }
    return res;
  }



  // Helper to find all days strictly between a start and end day
  // e.g., MON (1) to FRI (5) returns [2, 3, 4] (TUE, WED, THU)
  // e.g., FRI (5) to TUE (2) returns [6, 7, 1] (SAT, SUN, MON)
   List<int> getIntermediateWeekdays(int start, int end) {
    final List<int> days = [];
    int current =
        (start % 7) + 1; // Step forward 1 day (wrapping Sunday(7) to Monday(1))

    while (current != end) {
      days.add(current);
      current = (current % 7) + 1;
    }

    return days;
  }



  // Helper to map "MON" to 1, "TUE" to 2, etc.
   int dayStringToWeekday(String weekDay) {
    const map = {
      'MON': 1,
      'TUE': 2,
      'WED': 3,
      'THU': 4,
      'FRI': 5,
      'SAT': 6,
      'SUN': 7,
    };
    return map[weekDay] ?? 1;
  }


  // Helper to find the exact DateTime of the next occurring specific weekday
   DateTime nextWeekday(DateTime from, int targetWeekday) {
    int distance = targetWeekday - from.weekday;
    if (distance < 0) {
      distance += 7; // It's next week
    }
    return from.add(Duration(days: distance));
  }







