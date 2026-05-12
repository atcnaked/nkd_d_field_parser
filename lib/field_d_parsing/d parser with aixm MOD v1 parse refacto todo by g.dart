static NotamParseResult _parseBlock(String blockString, DateTime baseDate, ParseContext context) {
    List<NotamSchedule> results = [];

    // --- STEP 1: SPLIT RULES AND EXCEPTIONS ---
    final parts = blockString.split(RegExp(r'\sEXC\s'));
    final rulesString = parts[0].trim();
    final exceptionsString = parts.length > 1 ? parts[1].trim() : '';

    if (rulesString.contains('EVERY')) {
      context.warn("Found 'EVERY' in rules. While common, OPADD prefers specific day/date declarations.");
      // You can implement string stripping here if needed
    }

    // --- STEP 2: DECOUPLED EXCEPTION PARSING ---
    List<dynamic> inactives = [];
    bool isExceptionDays = false;
    
    if (exceptionsString.isNotEmpty) {
      // Smart detection: Are these days or dates?
      if (RegExp(dayRe).hasMatch(exceptionsString)) {
        isExceptionDays = true;
        inactives = _daysFrom(exceptionsString);
      } else {
        inactives = _datesFrom(exceptionsString, baseDate, context.warnings);
      }
    }

    // --- STEP 3: PARSE THE RULES ---
    
    // Case A: Continuous Multi-Day Block (e.g. MON 1000 - FRI 1200)
    final dayTimeMatch = RegExp('^$dayTimeRangeRe\$').firstMatch(rulesString);
    if (dayTimeMatch != null) {
      if (inactives.isNotEmpty && !isExceptionDays) {
         context.warn("OPADD Readability Warning: Rules use Days, but Exceptions use Dates. This is valid but discouraged.");
      }
      return _parseDaytimeRange(dayTimeMatch, inactives, baseDate, context);
    }

    // Case B: Continuous Multi-Date Block (e.g. JAN 15 1430 - FEB 28 1200)
    if (RegExp('^$datetimeRangeReNoCG\$').hasMatch(rulesString)) {
      if (inactives.isNotEmpty && isExceptionDays) {
         context.warn("OPADD Readability Warning: Rules use Dates, but Exceptions use Days. This is valid but discouraged.");
      }
      return _parseDatetimes(rulesString, inactives, baseDate, context);
    }

    // Case C: Standard Schedule (Time + Days/Dates)
    // 1. Extract the time FIRST (as you suggested)
    final timeMatch = RegExp(timeRangeReNoCG).firstMatch(rulesString);
    
    String rawActiveUnit;
    List<dynamic> times;

    if (timeMatch == null) {
      context.warn('Malformed D field: Missing time range. Defaulting to H24.');
      rawActiveUnit = rulesString;
      times = [h24];
    } else {
      rawActiveUnit = rulesString.substring(0, timeMatch.start).trim();
      times = _timesFrom(rulesString.substring(timeMatch.start).trim());
    }

    // 2. Now determine what the active unit is (Days or Dates)
    List<dynamic> actives = [];
    
    if (rawActiveUnit.isEmpty) {
      // If there's no text before the time (e.g. "0800-1700"), it implies DAILY
      actives = [AixmDay.any]; 
    } 
    else if (RegExp('^($dayRe)').hasMatch(rawActiveUnit)) {
      // It's a Day rule (e.g., MON-FRI)
      if (inactives.isNotEmpty && !isExceptionDays) {
         context.warn("OPADD Readability Warning: Base schedule uses Days, but Exceptions use Dates.");
      }
      actives = _daysFrom(rawActiveUnit);
    } 
    else {
      // It's a Date rule (e.g., 01 03 05)
      if (inactives.isNotEmpty && isExceptionDays) {
         context.warn("OPADD Readability Warning: Base schedule uses Dates, but Exceptions use Days.");
      }
      actives = _datesFrom(rawActiveUnit, baseDate, context.warnings);
    }

    // --- STEP 4: PACKAGE AND RETURN ---
    // (Your existing midnight-cross logic goes here using `actives`, `times`, and `inactives`)
    results.addAll(_applyMidnightSplit(actives, times, inactives, baseDate));

    return NotamParseResult(schedules: results, warnings: context.warnings);
  }