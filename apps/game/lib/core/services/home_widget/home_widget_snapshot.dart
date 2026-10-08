import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/app/localization_cubit/app_locale_resolver.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_projection.dart';
import 'package:nesty_game/l10n/app_localizations.dart';
import 'package:nesty_render/nesty_render.dart' show DollColorTokens;

/// What the home-screen widget shows, as one JSON string (stage 4 contract
/// §3, schema `v: 1`; plan-local-habits §4).
///
/// Everything that varies by day is in each day's entry and already
/// localized, because the phone can roll past midnight with the app closed;
/// native code only picks today's entry by date (no streak rule in Swift or
/// Kotlin, rule 2). Pure: [compose] reads nothing but its arguments, so the
/// bridge and the tests build the same snapshot.
@immutable
final class HomeWidgetSnapshot {
  const HomeWidgetSnapshot({
    required this.scheme,
    required this.lang,
    required this.unlocked,
    required this.locked,
    required this.days,
  });

  /// The schema version, bumped only with the native decoders.
  static const int version = 1;

  /// How many entries `days` holds: today … today + 7.
  static const int dayCount = 8;

  /// The most dolls an entry lists (the medium widget's cap).
  static const int maxDolls = 8;

  /// The flavor's URL scheme (`nesty`, `nesty-dev`, `nesty-stg`).
  final String scheme;

  /// The rendered language's code in storage style (`en`, `pt_BR`): native
  /// picks its face by it (Fredoka for Latin, the system face for tr, hi,
  /// ja).
  final String lang;

  /// The Daily is open (Level 2 won).
  final bool unlocked;

  final HomeWidgetLocked locked;

  /// Exactly [dayCount] entries, oldest first.
  final List<HomeWidgetDay> days;

  /// The snapshot for [days] (from `DailyService.projection`), written in
  /// the language [lang] resolves to.
  ///
  /// [dolls] holds the colours of the dates the app has already generated;
  /// a date missing from it gets `[]` and the views hide their doll row.
  /// [unlockLevel] is the level a locked widget names (`{level}`).
  factory HomeWidgetSnapshot.compose({
    required String lang,
    required String scheme,
    required bool unlocked,
    required int unlockLevel,
    required List<DailyDayProjection> days,
    Map<LocalDate, List<DollColor>> dolls = const {},
  }) {
    final locale = AppLocaleResolver.localeFor(lang);
    final l10n = lookupAppLocalizations(
      AppLocalizations.delegate.isSupported(locale)
          ? locale
          : AppLocaleResolver.localeFor(AppLocaleResolver.fallbackCode),
    );
    final tag = AppLocalizations.delegate.isSupported(locale)
        ? lang
        : AppLocaleResolver.fallbackCode;
    final weekdays = DateFormat('cccc', tag);
    final numbers = NumberFormat.decimalPattern(tag);

    return HomeWidgetSnapshot(
      scheme: scheme,
      lang: tag,
      unlocked: unlocked,
      locked: HomeWidgetLocked(
        title: l10n.widgetLockedTitle,
        small: l10n.widgetLockedSmall(unlockLevel),
        medium: l10n.widgetLockedMedium(unlockLevel),
        a11y: l10n.widgetLockedSemantics(unlockLevel),
      ),
      days: [
        for (final day in days)
          _dayEntry(
            day,
            l10n: l10n,
            weekdays: weekdays,
            numbers: numbers,
            dolls: dolls[day.date] ?? const [],
          ),
      ],
    );
  }

  static HomeWidgetDay _dayEntry(
    DailyDayProjection day, {
    required AppLocalizations l10n,
    required DateFormat weekdays,
    required NumberFormat numbers,
    required List<DollColor> dolls,
  }) {
    final yyyymmdd = day.date.yyyymmdd;
    final streak = day.streak;
    final (label, labelShort, line, lineShort, a11y) = switch (day.state) {
      DailyDayState.ready => (
        l10n.widgetStreakLabel(streak),
        null,
        l10n.widgetReady,
        l10n.widgetReadyShort,
        l10n.widgetReadySemantics(streak),
      ),
      DailyDayState.solved => (
        l10n.widgetStreakLabel(streak),
        null,
        l10n.widgetSolved,
        l10n.widgetSolvedShort,
        l10n.widgetSolvedSemantics(streak),
      ),
      DailyDayState.paused => (
        l10n.widgetStreakResting(streak),
        l10n.widgetStreakRestingShort,
        l10n.widgetReady,
        l10n.widgetReadyShort,
        l10n.widgetPausedSemantics(streak),
      ),
      DailyDayState.zero => (
        l10n.widgetFirstFlame,
        null,
        l10n.widgetReady,
        l10n.widgetReadyShort,
        l10n.widgetZeroSemantics,
      ),
    };
    return HomeWidgetDay(
      date: day.date,
      state: day.state,
      streak: streak,
      number: day.state == DailyDayState.zero ? null : numbers.format(streak),
      label: label,
      labelShort: labelShort,
      title: l10n.widgetPuzzleTitle(weekdays.format(day.date.startOfDay)),
      sub: l10n.dailyPuzzleInfo(
        DifficultyCurve.dailyParams(yyyymmdd).colors,
        l10n.tierName(DifficultyCurve.dailyTier(yyyymmdd).id),
      ),
      dolls: [for (final color in dolls.take(maxDolls)) hexOf(color)],
      line: line,
      lineShort: lineShort,
      a11y: a11y,
    );
  }

  /// `#RRGGBB` of a doll's `DollColor.base` (tokens.json `dollColor`).
  static String hexOf(DollColor color) {
    final value = DollColorTokens.of(color).base.toARGB32() & 0xFFFFFF;
    // Spelled by digit, not `toUpperCase`: no code changes the case of a
    // string (l10n.md §1.2), even a hex id.
    const digits = '0123456789ABCDEF';
    return '#${[for (var shift = 20; shift >= 0; shift -= 4) digits[(value >> shift) & 0xF]].join()}';
  }

  Map<String, Object?> toJson() => {
    'v': version,
    'scheme': scheme,
    'lang': lang,
    'unlocked': unlocked,
    'locked': locked.toJson(),
    'days': [for (final day in days) day.toJson()],
  };

  /// The one string the channel stores.
  String encode() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) =>
      other is HomeWidgetSnapshot && other.encode() == encode();

  @override
  int get hashCode => encode().hashCode;
}

/// The strings a locked widget (the Daily before Level 2 is won) draws,
/// with `{level}` filled.
@immutable
final class HomeWidgetLocked {
  const HomeWidgetLocked({
    required this.title,
    required this.small,
    required this.medium,
    required this.a11y,
  });

  final String title;
  final String small;
  final String medium;
  final String a11y;

  Map<String, Object?> toJson() => {
    'title': title,
    'small': small,
    'medium': medium,
    'a11y': a11y,
  };
}

/// One date of the widget: its look and every string, localized.
@immutable
final class HomeWidgetDay {
  const HomeWidgetDay({
    required this.date,
    required this.state,
    required this.streak,
    required this.number,
    required this.label,
    required this.labelShort,
    required this.title,
    required this.sub,
    required this.dolls,
    required this.line,
    required this.lineShort,
    required this.a11y,
  });

  final LocalDate date;
  final DailyDayState state;
  final int streak;

  /// The streak formatted in the rendered language; null for `zero`.
  final String? number;
  final String label;

  /// Set only for `paused` (`widgetStreakRestingShort`).
  final String? labelShort;
  final String title;
  final String sub;

  /// `#RRGGBB` per doll, puzzle order, at most 8; empty when not known.
  final List<String> dolls;
  final String line;
  final String lineShort;
  final String a11y;

  Map<String, Object?> toJson() => {
    'date': date.toIso(),
    'state': state.name,
    'streak': streak,
    'number': number,
    'label': label,
    'labelShort': labelShort,
    'title': title,
    'sub': sub,
    'dolls': dolls,
    'line': line,
    'lineShort': lineShort,
    'a11y': a11y,
  };
}
