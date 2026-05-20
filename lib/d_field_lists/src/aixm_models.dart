
/* 
That is a great architectural question. Using `List<dynamic>` was a direct side-effect of 
translating from Ruby (which is dynamically typed and doesn't care if you mix single objects and ranges in the same array).

In the strict, statically-typed world of Dart, those `dynamic` lists will ultimately hold a 
mix of **Single Points** and **Ranges**.

If you want to refactor `dynamic` into strongly typed Dart (which is highly recommended for 
Flutter UI rendering), here are the exact concrete types that those lists hold at runtime:

### 1. The Core AIXM Wrapper Types

To handle the data properly, the parser relies on three core "Point" types and one "Range" type. 
You likely have (or need) classes that look something like this:

* **`AixmDate`:** A wrapper around a specific `DateTime` (e.g., `March 5, 2024`).
* **`AixmDay`:** A wrapper around a day of the week (e.g., `1` for Monday, `7` for Sunday).
* **`AixmTime`:** A wrapper around a specific clock time or sun event (e.g., `08:00`, `SR`, `SS`).
* **`AixmRange`:** A generic class holding a `start` and `end` of the same type (e.g., a range of 
Dates, a range of Days, or a range of Times).

---

### 2. What `actives` holds

The `actives` list represents the days or dates the NOTAM is active. It will hold:

* **`AixmDate`:** For single dates (e.g., `05` -> March 5).
* **`AixmRange` (of `AixmDate`):** For date ranges (e.g., `01-05` -> March 1 to March 5).
* **`AixmDay`:** For single days (e.g., `WED`).
* **`AixmRange` (of `AixmDay`):** For day ranges (e.g., `MON-FRI`).
* **`String` (The "DAILY" token):** If the D field skipped days entirely and started with a time (e.g., `0800-1700`).

### 3. What `times` holds

The `times` list represents the hours the schedule is active during the `actives` days. It will hold:

* **`AixmRange` (of `AixmTime`):** This is the most common. It holds the time blocks (e.g., `0800-1700` or `SR-SS`).
* **`AixmTime`:** For single specific times (e.g., `1200`). *Note: This is very rare in OPADD, but the parser supports 
it for specific point-in-time events.*
* **`String` (The "H24" token):** If the schedule is continuous for the full 24-hour period.

### 4. What `inactives` holds

The `inactives` list represents the `EXC` (Exceptions) block. It holds exactly the same types as `actives`, just 
applied as a subtraction filter:

* **`AixmDate` / `AixmRange` (of `AixmDate`)** (e.g., `EXC MAR 25-27`)
* **`AixmDay` / `AixmRange` (of `AixmDay`)** (e.g., `EXC SAT SUN`)

---

### How to remove `dynamic` in Dart (The "Pro" Way)

If you want to get rid of `List<dynamic>` and make your Dart compiler happy, 
the best approach is to create a base abstract class (e.g., `AixmTimeElement`) that all these classes extend.

```dart
abstract class AixmTimeElement {}

class AixmDate extends AixmTimeElement { ... }
class AixmDay extends AixmTimeElement { ... }
class AixmTime extends AixmTimeElement { ... }
class AixmRange<T extends AixmTimeElement> extends AixmTimeElement { ... }
class AixmToken extends AixmTimeElement { 
  final String value; // For "DAILY" or "H24"
}

```

Then, you can strictly type your parser variables:

* `List<AixmTimeElement> actives;`
* `List<AixmTimeElement> times;`
* `List<AixmTimeElement> inactives;`

This makes your Flutter UI code much safer, as you can use Dart's pattern matching 
(`if (active is AixmRange) { ... } else if (active is AixmDate) { ... }`) to draw the exact right blocks on your calendar!
 */










class AixmTime {
  final String? time;
  final String? event; // 'sunrise' or 'sunset'
  final int delta; // PLUS/MINUS minutes

  const AixmTime.literal(this.time) : event = null, delta = 0;
  const AixmTime.event(this.event, {this.delta = 0}) : time = null;

  static const beginningOfDay = AixmTime.literal('00:00');
  static const endOfDay = AixmTime.literal(
    '23:59',
  ); // AIXM uses 24:00 internally, but 23:59 is standard for Dart

  @override
  String toString() =>
      time ?? '$event${delta != 0 ? ' ${delta > 0 ? '+' : ''}$delta' : ''}';
}

class AixmDate {
  final DateTime date;
  AixmDate(this.date);

  AixmDate get next => AixmDate(date.add(const Duration(days: 1)));
  AixmDate get prev => AixmDate(date.subtract(const Duration(days: 1)));

  @override
  String toString() =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AixmDate && date == other.date;
  @override
  int get hashCode => date.hashCode;
}

class AixmDay {
  final String dayName;
  const AixmDay(this.dayName);

  static const any = AixmDay('any');
  @override
  String toString() => dayName;
}

class AixmRange<T> {
  final T start;
  final T end;
  const AixmRange(this.start, this.end);
  @override
  String toString() => '$start..$end';
}
