import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';

/// Which line the welcome-back card carries under its headline
/// (plan-local-habits §1 "Variants").
enum WelcomeBackVariant {
  /// No streak yet: "Today's puzzle is ready for you."
  newStreak,

  /// The flame is resting with its number kept.
  paused,

  /// A freeze covered the days away and the flame stayed lit.
  freezeKept,

  /// None of the above (not reachable with a gap of 2 or more): the
  /// headline alone, with no streak line.
  plain,
}

/// What an open or resume leaves in the settings.
class WelcomeBackOpen {
  const WelcomeBackOpen({required this.lastOpenDate, this.welcomeBackDate});

  /// The high-water mark to store.
  final LocalDate lastOpenDate;

  /// The date a card belongs to, or null (none, or one cleared).
  final LocalDate? welcomeBackDate;
}

/// Welcome back (local habit 1, plan-local-habits §1): a quiet card on Home
/// for a player who has been away, never a pop-up and never a loss.
///
/// Pure, beside `LoginGiftRules`. `WelcomeBackTracker` applies [onOpen] on
/// each start and resume; `WelcomeBackCubit` asks [shows] and [variantOf].
/// No clock read, no `Random`: dates come in (CLAUDE.md rule 7).
abstract final class WelcomeBackRules {
  /// The least gap Remote Config may set: with 2 days or more away at least
  /// one day was missed, so a lit flame on return always means a freeze
  /// covered it (see [variantOf]).
  static const int minDays = 2;

  /// The most (a card after two months away is the outer bound).
  static const int maxDays = 60;

  /// [days] clamped to [minDays]..[maxDays]; the admin's malformed or
  /// out-of-range value is bent, never thrown on (CLAUDE.md rule 6).
  static int clampDays(int days) => days.clamp(minDays, maxDays);

  /// `welcome_back_days`, clamped.
  static int gapOf(RemoteConfigService remoteConfig) =>
      clampDays(remoteConfig.value(RemoteConfigKeys.welcomeBackDays));

  /// An open or resume on [today], reading what was stored before anything
  /// is written ([storedLastOpen] and [storedWelcomeBack] are the settings'
  /// raw strings; missing or unparsable reads as none).
  ///
  /// - [WelcomeBackOpen.lastOpenDate] is `max(stored, today)`: a high-water
  ///   mark, so a clock wound back neither writes an earlier date nor lets a
  ///   later forward step count the wound-back stretch as a gap.
  /// - A gap of [gapDays] or more (today minus stored) makes the card belong
  ///   to today. A first launch (nothing stored) is never a gap, and a clock
  ///   wound back changes nothing.
  /// - A card's date from an earlier day is kept as stored: [shows] needs
  ///   `== today`, so it is inert, and the next gap or dismissal replaces it.
  static WelcomeBackOpen onOpen({
    required LocalDate today,
    required String? storedLastOpen,
    required String? storedWelcomeBack,
    required int gapDays,
  }) {
    final last = LocalDate.tryParse(storedLastOpen);
    final card = LocalDate.tryParse(storedWelcomeBack);
    if (last == null) {
      return WelcomeBackOpen(lastOpenDate: today, welcomeBackDate: card);
    }
    if (today < last) {
      return WelcomeBackOpen(lastOpenDate: last, welcomeBackDate: card);
    }
    final away = last.daysUntil(today);
    return WelcomeBackOpen(
      lastOpenDate: today,
      welcomeBackDate: away >= clampDays(gapDays) ? today : card,
    );
  }

  /// The card shows today: it belongs to today, the Daily is unlocked and
  /// today's puzzle isn't solved yet.
  static bool shows({
    required LocalDate today,
    required LocalDate? welcomeBackDate,
    required bool unlocked,
    required bool solvedToday,
  }) => welcomeBackDate == today && unlocked && !solvedToday;

  /// The variant for [status].
  ///
  /// With a gap of 2 or more at least one day went by unsolved. The daily
  /// service then leaves a lit flame lit only when a freeze covered that
  /// day (and records it in `frozen`); otherwise the flame is paused. So
  /// `lit` here implies a freeze, and "a freeze kept your flame" is true.
  static WelcomeBackVariant variantOf(DailyStatus status) {
    if (status.streak == 0) return WelcomeBackVariant.newStreak;
    if (!status.lit) return WelcomeBackVariant.paused;
    if (status.frozen.isNotEmpty) return WelcomeBackVariant.freezeKept;
    return WelcomeBackVariant.plain;
  }
}
