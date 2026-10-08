import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// The first day of the week for the month grid (docs/plans/
/// plan-local-habits.md "Shared pieces"), from `intl`'s
/// `DateSymbols.FIRSTDAYOFWEEK`.
///
/// The app's rendered locale drops the region (`en_GB` renders as `en`,
/// whose week starts on Sunday), so the phone's first preferred locale
/// whose language is the rendered one decides (`en_GB` -> Monday), else the
/// rendered language itself, else Monday.
///
/// The symbols come from the date data `GlobalMaterialLocalizations`
/// already loads into `intl` for every locale Flutter knows (`en_GB`,
/// `en_IN`, `es_MX`, `pt_PT` …), so this adds no data to the app; a region
/// Flutter doesn't know falls back to its language.
abstract final class WeekStart {
  /// [DateTime.monday] ... [DateTime.sunday].
  static int of(String renderedCode, List<Locale> deviceLocales) {
    final language = _language(renderedCode);
    final candidates = <String>[
      for (final locale in deviceLocales)
        if (locale.languageCode == language) locale.toString(),
      renderedCode,
    ];
    for (final candidate in candidates) {
      final first = _firstDay(candidate);
      if (first != null) return first;
    }
    return DateTime.monday;
  }

  static String _language(String code) => code.split(RegExp('[_-]')).first;

  // intl counts 0 = Monday; DateTime counts 1 = Monday.
  static int? _firstDay(String locale) {
    try {
      final index = DateFormat.d(locale).dateSymbols.FIRSTDAYOFWEEK;
      return DateTime.monday + index % 7;
    } on Object {
      return null;
    }
  }
}
