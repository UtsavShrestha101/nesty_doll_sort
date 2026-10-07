import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/streak_daily_service.dart';
import 'package:nesty_game/core/services/login_gift/login_gift_reward.dart';
import 'package:nesty_game/core/services/login_gift/login_gift_rules.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/save/save_document.dart';

/// [LoginGiftRules] (plan-login-gift §7.5b; D268): the track counts claims,
/// not dates (a gap of 1, 3 or 30 days keeps the day), one claim per local
/// date, no claim earlier than the latest date seen (a clock wound back,
/// or forward then back), the wrap after Day 7, locked until the Daily,
/// and Remote Config's track with its fallback (rule 6).
void main() {
  final monday = LocalDate(2026, 10, 5);
  const track = LoginGiftRules.defaultTrack;

  /// A player past Level 2, so the gift is unlocked.
  SaveDocument unlocked([LoginGiftProgress gift = const LoginGiftProgress()]) =>
      SaveDocument(
        currentLevel: StreakDailyService.unlockAtHighestLevel,
        highestLevel: StreakDailyService.unlockAtHighestLevel,
        loginGift: gift,
      );

  /// Claims on [date] as `SaveService.claimLoginGift` does: the grant, and
  /// the document after it (unchanged when there is no grant).
  (LoginGiftGrant?, SaveDocument) claim(SaveDocument doc, LocalDate date) {
    final grant = LoginGiftRules.grantFor(doc, date, track);
    if (grant == null) return (null, doc);
    return (
      grant,
      doc.copyWith(loginGift: LoginGiftRules.claimed(doc.loginGift, date)),
    );
  }

  group('the track', () {
    test('the default is the approved one (Q182c), and Day 7 is the big '
        'one', () {
      expect(track, const [
        LoginGiftReward(coins: 20),
        LoginGiftReward(coins: 30),
        LoginGiftReward(hints: 1),
        LoginGiftReward(coins: 40),
        LoginGiftReward(coins: 50),
        LoginGiftReward(hints: 1),
        LoginGiftReward(coins: 100, slots: 1),
      ]);
      expect(track, hasLength(LoginGiftRules.trackLength));
    });

    test('Remote Config\'s default parses to exactly the default track', () {
      final parsed = LoginGiftRules.parseTrack(
        RemoteConfigKeys.loginGiftTrack.defaultValue,
      );
      expect(parsed, track);
      expect(parsed, isNot(same(track)), reason: 'read, not fallen back');
    });

    test('a well-formed override is read, absent fields as 0 and whole '
        'doubles as ints', () {
      final parsed = LoginGiftRules.parseTrack(
        '[{"coins":5},{"coins":6.0},{"hints":2},{"slots":1},'
        '{"coins":1,"hints":1,"slots":1},{"coins":0,"hints":3},'
        '{"coins":500}]',
      );
      expect(parsed, const [
        LoginGiftReward(coins: 5),
        LoginGiftReward(coins: 6),
        LoginGiftReward(hints: 2),
        LoginGiftReward(slots: 1),
        LoginGiftReward(coins: 1, hints: 1, slots: 1),
        LoginGiftReward(hints: 3),
        LoginGiftReward(coins: 500),
      ]);
    });

    test('anything malformed falls back to the whole default track', () {
      const day = '{"coins":10}';
      String days(int n) => '[${List.filled(n, day).join(',')}]';
      for (final raw in [
        '',
        'not json',
        '{"coins":20}',
        '[]',
        days(6),
        days(8),
        '[${List.filled(6, day).join(',')},{"coins":-1}]',
        '[${List.filled(6, day).join(',')},{"coins":1.5}]',
        '[${List.filled(6, day).join(',')},{"coins":"20"}]',
        '[${List.filled(6, day).join(',')},{}]',
        '[${List.filled(6, day).join(',')},{"coins":0}]',
        '[${List.filled(6, day).join(',')},{"skin":"ocean"}]',
        '[${List.filled(6, day).join(',')},{"coins":5,"spin":1}]',
        '[${List.filled(6, day).join(',')},7]',
        '[${List.filled(6, day).join(',')},null]',
      ]) {
        expect(LoginGiftRules.parseTrack(raw), same(track), reason: raw);
      }
    });

    test('trackOf reads login_gift_track, with the fallback', () {
      final config = FakeRemoteConfigService();
      expect(LoginGiftRules.trackOf(config), track);

      config.setOverride(
        RemoteConfigKeys.loginGiftTrack,
        '[${List.filled(7, '{"hints":1}').join(',')}]',
      );
      expect(
        LoginGiftRules.trackOf(config),
        List.filled(7, const LoginGiftReward(hints: 1)),
      );

      config.setOverride(RemoteConfigKeys.loginGiftTrack, '[1,2,3]');
      expect(LoginGiftRules.trackOf(config), same(track));
    });
  });

  group('the day', () {
    test('counts claims: Day 1 first, Day 7 at six claims, then Day 1 '
        'again', () {
      expect(
        [
          for (var claims = 0; claims < 15; claims++)
            LoginGiftRules.dayOf(claims),
        ],
        [1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 4, 5, 6, 7, 1],
      );
    });

    test('gaps of 1, 3 and 30 days keep the next day: a missed day never '
        'moves the track back (rule 6)', () {
      for (final gap in [1, 3, 30]) {
        var doc = unlocked();
        LoginGiftGrant? grant;
        // Two claims on consecutive days: Day 1, Day 2.
        (grant, doc) = claim(doc, monday);
        expect(grant?.day, 1);
        (grant, doc) = claim(doc, monday.addDays(1));
        expect(grant?.day, 2);
        // Then [gap] days with no claim: the next is still Day 3.
        (grant, doc) = claim(doc, monday.addDays(1 + gap));
        expect(grant?.day, 3, reason: 'gap $gap');
        expect(grant?.reward, const LoginGiftReward(hints: 1));
        expect(doc.loginGift.claims, 3);
      }
    });

    test('a week of claims pays the whole track in order, then wraps to '
        'Day 1', () {
      var doc = unlocked();
      final paid = <LoginGiftReward>[];
      for (var i = 0; i < 8; i++) {
        final (grant, next) = claim(doc, monday.addDays(i));
        doc = next;
        expect(grant, isNotNull, reason: 'day ${i + 1}');
        expect(grant!.day, i % 7 + 1);
        expect(grant.claims, i + 1);
        expect(grant.date, monday.addDays(i));
        paid.add(grant.reward);
      }
      expect(paid.take(7), track);
      expect(paid.last, track.first);
      expect(doc.loginGift.claims, 8);
    });

    test('the grant pays the configured track\'s day', () {
      final custom = [
        for (var i = 1; i <= 7; i++) LoginGiftReward(coins: i * 100),
      ];
      final doc = unlocked(
        LoginGiftProgress(claims: 4, lastClaim: monday, latestSeen: monday),
      );
      final grant = LoginGiftRules.grantFor(doc, monday.addDays(1), custom);
      expect(grant?.day, 5);
      expect(grant?.reward, const LoginGiftReward(coins: 500));
    });
  });

  group('one claim per date', () {
    test('the same date twice claims once', () {
      var doc = unlocked();
      LoginGiftGrant? grant;
      (grant, doc) = claim(doc, monday);
      expect(grant, isNotNull);
      (grant, doc) = claim(doc, monday);
      expect(grant, isNull);
      expect(doc.loginGift.claims, 1);
      expect(LoginGiftRules.canClaim(monday, doc.loginGift), isFalse);
      expect(LoginGiftRules.canClaim(monday.addDays(1), doc.loginGift), isTrue);
    });

    test('a fresh progress can claim any date', () {
      expect(
        LoginGiftRules.canClaim(monday, const LoginGiftProgress()),
        isTrue,
      );
    });
  });

  group('the clock guard', () {
    test('a clock wound back claims nothing until the latest date seen '
        'comes round again', () {
      var doc = unlocked();
      LoginGiftGrant? grant;
      (grant, doc) = claim(doc, monday);
      expect(grant?.day, 1);
      // Back two days: earlier than the latest date seen.
      for (final back in [1, 2, 30]) {
        (grant, doc) = claim(doc, monday.addDays(-back));
        expect(grant, isNull, reason: '$back days back');
      }
      // The next real day claims Day 2: nothing was lost, only delayed.
      (grant, doc) = claim(doc, monday.addDays(1));
      expect(grant?.day, 2);
    });

    test('a clock wound forward, then back, borrows one gift and pays it '
        'back in time (plan "Risks")', () {
      var doc = unlocked();
      LoginGiftGrant? grant;
      (grant, doc) = claim(doc, monday);
      // Forward 5 days: one claim (Day 2).
      (grant, doc) = claim(doc, monday.addDays(5));
      expect(grant?.day, 2);
      // Back to the real dates: Tuesday to Saturday claim nothing, and
      // Saturday is the forward claim's own date.
      for (var i = 1; i <= 5; i++) {
        (grant, doc) = claim(doc, monday.addDays(i));
        expect(grant, isNull, reason: 'day +$i');
      }
      // Sunday, the first date after the latest seen, claims Day 3.
      (grant, doc) = claim(doc, monday.addDays(6));
      expect(grant?.day, 3);
      expect(doc.loginGift.claims, 3);
    });

    test('a date only seen (never claimed) still blocks an earlier one', () {
      final seen = LoginGiftRules.noted(
        const LoginGiftProgress(),
        monday.addDays(3),
      );
      expect(seen.latestSeen, monday.addDays(3));
      expect(seen.claims, 0);
      expect(LoginGiftRules.canClaim(monday, seen), isFalse);
      expect(LoginGiftRules.canClaim(monday.addDays(3), seen), isTrue);
    });

    test('noted raises latestSeen and never lowers it', () {
      final progress = LoginGiftProgress(
        claims: 2,
        lastClaim: monday,
        latestSeen: monday,
      );
      expect(
        LoginGiftRules.noted(progress, monday.addDays(-1)),
        same(progress),
      );
      expect(LoginGiftRules.noted(progress, monday), same(progress));
      expect(
        LoginGiftRules.noted(progress, monday.addDays(2)),
        progress.copyWith(latestSeen: monday.addDays(2)),
      );
    });

    test('claimed adds one claim, never lowers latestSeen', () {
      final progress = LoginGiftProgress(
        claims: 6,
        lastClaim: monday,
        latestSeen: monday.addDays(1),
      );
      final after = LoginGiftRules.claimed(progress, monday.addDays(1));
      expect(after.claims, 7);
      expect(after.lastClaim, monday.addDays(1));
      expect(after.latestSeen, monday.addDays(1));
    });
  });

  group('the unlock', () {
    test('locked until the Daily unlocks (Level 2 won)', () {
      expect(
        LoginGiftRules.isUnlocked(StreakDailyService.unlockAtHighestLevel - 1),
        isFalse,
      );
      expect(
        LoginGiftRules.isUnlocked(StreakDailyService.unlockAtHighestLevel),
        isTrue,
      );
      const fresh = SaveDocument();
      expect(LoginGiftRules.grantFor(fresh, monday, track), isNull);
      final levelTwo = fresh.copyWith(currentLevel: 2, highestLevel: 2);
      expect(LoginGiftRules.grantFor(levelTwo, monday, track), isNull);
      final levelTwoWon = fresh.copyWith(currentLevel: 3, highestLevel: 3);
      expect(LoginGiftRules.grantFor(levelTwoWon, monday, track)?.day, 1);
    });
  });
}
