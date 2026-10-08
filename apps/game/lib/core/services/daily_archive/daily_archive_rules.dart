import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';

/// The last days' dailies, playable (local habit 3, plan-local-habits §3,
/// §7.5c): which past dates the Daily offers.
///
/// Pure, beside `WelcomeBackRules`: dates come in, no clock read (CLAUDE.md
/// rule 7). The window is today − N … today − 1; it exists only once the
/// Daily is unlocked, never from the install date.
abstract final class DailyArchiveRules {
  /// The most days back Remote Config may set.
  static const int maxDays = 28;

  /// [days] clamped to 0–[maxDays]; 0 turns the archive off. A bad value is
  /// bent, never thrown on (CLAUDE.md rule 6).
  static int clampDays(int days) => days.clamp(0, maxDays);

  /// `daily_archive_days`, clamped (a value of the wrong type already reads
  /// as its default, 7).
  static int daysOf(RemoteConfigService remoteConfig) =>
      clampDays(remoteConfig.value(RemoteConfigKeys.dailyArchiveDays));

  /// The playable dates, oldest first: today − [days] … today − 1.
  static List<LocalDate> window(LocalDate today, int days) {
    final n = clampDays(days);
    return [for (var back = n; back >= 1; back--) today.addDays(-back)];
  }

  /// [date] may be started: inside the [window] and the Daily is
  /// [unlocked]. Today and the future are not past days.
  static bool isPlayable(
    LocalDate date,
    LocalDate today, {
    required bool unlocked,
    required int days,
  }) {
    if (!unlocked) return false;
    final n = clampDays(days);
    return date < today && date >= today.addDays(-n);
  }

  /// [archive] without an `inProgress` board whose date left the window.
  /// Run when the Daily page loads, never mid-game. `played` is a record
  /// and is never pruned here.
  static DailyArchive prune(DailyArchive archive, LocalDate today, int days) {
    final saved = archive.inProgress;
    if (saved == null) return archive;
    final request = saved.request;
    final date = request is PastDailyPlay ? _tryDate(request.yyyymmdd) : null;
    final n = clampDays(days);
    final keep = date != null && date < today && date >= today.addDays(-n);
    return keep ? archive : archive.copyWith(inProgress: null);
  }

  static LocalDate? _tryDate(int yyyymmdd) {
    try {
      return LocalDate.fromYyyymmdd(yyyymmdd);
    } on ArgumentError {
      return null;
    }
  }
}
