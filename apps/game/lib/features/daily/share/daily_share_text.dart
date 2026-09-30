import 'package:intl/intl.dart';
import 'package:nesty_core/nesty_core.dart' show DollColor;
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

/// The spoiler-free facts the daily's Share text needs (copy.md G.6; phase 4
/// architecture §3.10, §6.6): the puzzle's date, its families' colours in
/// the order they appear on the board (`WinSummary.families`), the win's
/// moves, and the streak day the Daily screen shows with whether its flame
/// is lit (`DailyStatus.streak`, not paused).
///
/// The daily win card builds it (lane O places the button, lane D owns the
/// text): only the win knows the families' colours, so the Daily solved
/// card no longer shares (phase 4 decision on Q-P4-1).
typedef DailyShareData = ({
  LocalDate date,
  List<DollColor> families,
  int moves,
  int streakDay,
  bool streakLit,
});

/// The daily's Share text (spec-prop §10.2 #11; copy.md G.6; frames
/// 10.1–10.1c): three lines, the plain text `ShareService.shareText` hands
/// the OS share sheet.
///
/// Spoiler-free by construction: it names the day, one belly-symbol emoji
/// per family (`dailyShareGlyph`, so no two families look alike and nothing
/// depends on colour), the moves and the streak day. It never carries the
/// board, a slot id or a move list.
abstract final class DailyShareText {
  const DailyShareText._();

  /// One glyph is shown per family, up to this many, however many families
  /// a daily could ever have: a bound, not something today's difficulty
  /// curve reaches (m7-design P3.9).
  static const int maxGlyphs = 12;

  /// [data]'s text in [l10n]'s language, the date formatted for
  /// [localeName] (`Localizations.localeOf(context).toString()`) as copy.md's
  /// example "Sep 30" (`DateFormat.MMMd`). A streak of 0, or one that is
  /// paused, uses the no-streak line (G.6 `share_line_3_no_streak`).
  static String of(
    AppLocalizations l10n, {
    required String localeName,
    required DailyShareData data,
  }) {
    final date = DateFormat.MMMd(localeName).format(data.date.startOfDay);
    final glyphs = [
      for (final color in data.families.take(maxGlyphs))
        l10n.dailyShareGlyph(color.id),
    ].join(' ');
    return data.streakLit && data.streakDay > 0
        ? l10n.dailyShareText(date, glyphs, data.moves, data.streakDay)
        : l10n.dailyShareTextNoStreak(date, glyphs, data.moves);
  }
}
