import 'package:intl/intl.dart';

/// A [DateFormat] for a design token's CLDR date skeleton
/// (`habits.pastDay.winDateSkeleton` and the like).
///
/// intl reads a string as a skeleton only when it is one of its own
/// spellings (`DateFormat.MMMMEEEEd`'s 'MMMMEEEEd'); any other string is
/// taken as a pattern, so the token 'EEEEdMMMM' printed "Sunday1November".
/// A skeleton's field order carries no meaning (CLDR), so the fields are put
/// in intl's order first, and the locale then gives its own order and
/// punctuation ("Sunday, November 1", "Sonntag, 1. November").
DateFormat skeletonDateFormat(String skeleton, String locale) =>
    DateFormat(intlSkeleton(skeleton), locale);

/// [skeleton]'s fields in intl's order: year, quarter, month, weekday, day,
/// then the time fields. 'EEEEdMMMM' becomes 'MMMMEEEEd'.
String intlSkeleton(String skeleton) {
  final runs = [
    for (final match in RegExp(r'(.)\1*').allMatches(skeleton)) match[0]!,
  ];
  const order = 'yQMLEcdjHhms';
  int rank(String run) {
    final index = order.indexOf(run[0]);
    return index < 0 ? order.length : index;
  }

  // A stable sort: fields of the same rank keep their order.
  final indexed = [for (var i = 0; i < runs.length; i++) (i, runs[i])]
    ..sort((a, b) {
      final byRank = rank(a.$2).compareTo(rank(b.$2));
      return byRank != 0 ? byRank : a.$1.compareTo(b.$1);
    });
  return indexed.map((entry) => entry.$2).join();
}
