import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/welcome_back/welcome_back_rules.dart';

/// [WelcomeBackRules] (local habit 1, plan-local-habits §1): the gap, the
/// high-water mark, the show rule and the variants.
void main() {
  final today = LocalDate(2026, 10, 8);

  WelcomeBackOpen open({
    String? last,
    String? card,
    int gap = 2,
    LocalDate? on,
  }) => WelcomeBackRules.onOpen(
    today: on ?? today,
    storedLastOpen: last,
    storedWelcomeBack: card,
    gapDays: gap,
  );

  String ago(int days) => today.addDays(-days).toIso();

  group('the gap', () {
    for (final (days, card) in [
      (0, false),
      (1, false),
      (2, true),
      (3, true),
      (30, true),
    ]) {
      test('$days day(s) away: card ${card ? 'yes' : 'no'}', () {
        final result = open(last: ago(days));
        expect(result.welcomeBackDate, card ? today : isNull);
        expect(result.lastOpenDate, today);
      });
    }

    test('a first launch is never a gap', () {
      final result = open();
      expect(result.welcomeBackDate, isNull);
      expect(result.lastOpenDate, today);
    });

    test('an unparsable stored date reads as a first launch', () {
      final result = open(last: 'soon');
      expect(result.welcomeBackDate, isNull);
      expect(result.lastOpenDate, today);
    });

    test('the same day again keeps the card and never re-sets it', () {
      final result = open(last: today.toIso(), card: today.toIso());
      expect(result.welcomeBackDate, today);
    });

    test('a card from an older day is kept as stored (inert)', () {
      final old = today.addDays(-5);
      expect(open(last: ago(1), card: old.toIso()).welcomeBackDate, old);
    });
  });

  group('a clock wound back', () {
    test('changes nothing: no card, the high-water mark kept', () {
      final result = open(last: today.addDays(4).toIso());
      expect(result.lastOpenDate, today.addDays(4));
      expect(result.welcomeBackDate, isNull);
    });

    test('forward then back: the wound-back stretch is no gap', () {
      // Day 0 stored; the clock jumps 10 days (a card), then returns.
      final forward = open(last: ago(0), on: today.addDays(1));
      expect(forward.welcomeBackDate, isNull);
      final back = open(last: forward.lastOpenDate.toIso(), on: today);
      expect(back.lastOpenDate, today.addDays(1));
      expect(back.welcomeBackDate, isNull);
      // And the real next day is one day from the mark, not a gap.
      final next = open(last: back.lastOpenDate.toIso(), on: today.addDays(2));
      expect(next.welcomeBackDate, isNull);
    });
  });

  test('a resume on a new date after days away shows the card', () {
    final slept = open(last: ago(0), on: today.addDays(3));
    expect(slept.welcomeBackDate, today.addDays(3));
  });

  group('Remote Config', () {
    int gapWith(int value) {
      final rc = FakeRemoteConfigService()
        ..setOverride(RemoteConfigKeys.welcomeBackDays, value);
      return WelcomeBackRules.gapOf(rc);
    }

    test('2, 5, 0, 61 and the default', () {
      expect(gapWith(2), 2);
      expect(gapWith(5), 5);
      expect(gapWith(0), 2);
      expect(gapWith(-4), 2);
      expect(gapWith(61), 60);
      expect(WelcomeBackRules.gapOf(FakeRemoteConfigService()), 2);
    });

    test('a gap of 5 needs 5 days away', () {
      expect(open(last: ago(4), gap: 5).welcomeBackDate, isNull);
      expect(open(last: ago(5), gap: 5).welcomeBackDate, today);
    });

    test('a gap of 0 is bent to 2', () {
      expect(open(last: ago(1), gap: 0).welcomeBackDate, isNull);
      expect(open(last: ago(2), gap: 0).welcomeBackDate, today);
    });
  });

  group('shows', () {
    bool shows({LocalDate? card, bool unlocked = true, bool solved = false}) =>
        WelcomeBackRules.shows(
          today: today,
          welcomeBackDate: card,
          unlocked: unlocked,
          solvedToday: solved,
        );

    test('only for today, unlocked and unsolved', () {
      expect(shows(card: today), isTrue);
      expect(shows(), isFalse);
      expect(shows(card: today.addDays(-1)), isFalse);
      expect(shows(card: today, unlocked: false), isFalse);
      expect(shows(card: today, solved: true), isFalse);
    });
  });

  group('variantOf', () {
    DailyStatus status({
      int streak = 0,
      bool lit = false,
      List<LocalDate> frozen = const [],
    }) => DailyStatus(
      today: today,
      tier: Tier.easy,
      colors: 4,
      unlocked: true,
      streak: streak,
      lit: lit,
      frozen: frozen,
    );

    test('no streak, paused, freeze kept and plain', () {
      expect(
        WelcomeBackRules.variantOf(status()),
        WelcomeBackVariant.newStreak,
      );
      expect(
        WelcomeBackRules.variantOf(status(streak: 4)),
        WelcomeBackVariant.paused,
      );
      expect(
        WelcomeBackRules.variantOf(
          status(streak: 4, lit: true, frozen: [today.addDays(-1)]),
        ),
        WelcomeBackVariant.freezeKept,
      );
      expect(
        WelcomeBackRules.variantOf(status(streak: 4, lit: true)),
        WelcomeBackVariant.plain,
      );
    });
  });
}
