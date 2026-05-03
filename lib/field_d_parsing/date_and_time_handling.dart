import 'package:flutter/material.dart' show TimeOfDay, DateUtils;

const TimeOfDay myTime = TimeOfDay(hour: 14, minute: 30);
DateTime combineDateAndTime(DateTime date, TimeOfDay time) {
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

DateTime now = DateTime.now(); // Contains date AND time

// Strips the time, leaving you with DateTime(year, month, day, 0, 0, 0)
DateTime dateOnly = DateUtils.dateOnly(now);

// Creating a date-only object from scratch
DateTime specificDate = DateTime(2023, 10, 25); // Time defaults to midnight

/* 
It is incredibly common to want to do exactly what you are describing. Unlike some other languages, Dart's core library doesn't have dedicated `Date` or `Time` classes, which is why everyone reaches for `DateTime` first. 

However, in the **Flutter** ecosystem, there is a very standard way to handle this to avoid the exact headache you are anticipating.

Here is the standard approach:

### 1. For Time Only: Use `TimeOfDay`
Flutter actually has a built-in class specifically for this called `TimeOfDay`. It stores exactly what you need: an `hour` and a `minute`, and nothing else.

It is part of the Flutter framework (specifically `flutter/material.dart`), so it is optimized for UI elements like time pickers.

```dart
import 'package:flutter/material.dart';

// Creating a time object for 2:30 PM
const TimeOfDay myTime = TimeOfDay(hour: 14, minute: 30);

// You can easily get the formatted string based on the user's locale
String formatted = myTime.format(context); 
```

### 2. For Date Only: Normalized `DateTime`
For the date part, you **do** use the `DateTime` class, but the standard practice is to "normalize" it by zeroing out the time fields (setting them to midnight). 

If you leave the time fields as they are, you will inevitably run into bugs when comparing two dates (e.g., `date1 == date2` will return `false` if they are the same day but were created at different times of day).

Flutter provides a handy utility class called `DateUtils` to strip the time away safely:

```dart
import 'package:flutter/material.dart';

DateTime now = DateTime.now(); // Contains date AND time

// Strips the time, leaving you with DateTime(year, month, day, 0, 0, 0)
DateTime dateOnly = DateUtils.dateOnly(now); 

// Creating a date-only object from scratch
DateTime specificDate = DateTime(2023, 10, 25); // Time defaults to midnight
```

### Summary of Best Practices
* **Need just the time?** Use `TimeOfDay`. It is lightweight, compares easily, and integrates perfectly with `showTimePicker`.
* **Need just the date?** Use `DateTime`, but always pass it through `DateUtils.dateOnly()` before storing or comparing it. 
* **Need to combine them later?** You can easily merge them back together when you need to send a full timestamp to a database:

```dart
DateTime combineDateAndTime(DateTime date, TimeOfDay time) {
  return DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
}
```
 */
