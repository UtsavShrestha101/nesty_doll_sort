import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart' show Tier;
import 'package:nesty_game/core/models/play_entry.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/repository/fake_level_resolver.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_projection.dart';
import 'package:nesty_game/core/services/daily/fake_daily_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/home_widget/fake_home_widget_service.dart';
import 'package:nesty_game/core/services/home_widget/home_widget_bridge.dart';
import 'package:nesty_game/core/services/home_widget/home_widget_snapshot.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';

import '../../../helpers/level_fixtures.dart';

/// `HomeWidgetBridge` (stage 4; plan-local-habits §4): a write on each
/// trigger (start, resume, the daily's changes, a language change), none
/// when the snapshot is the one already stored, and never a throw.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeClock clock;
  late FakeDailyService daily;
  late FakeDatabaseService settings;
  late FakeHomeWidgetService widget;
  late FakeLevelResolver resolver;
  late FakeSaveService save;
  late HomeWidgetBridge bridge;

  PlayEntry entry(LocalDate date, String color) => PlayEntry(
    request: PlayRequest.daily(date.yyyymmdd),
    level: levelFrom(tutorialLevelJson.replaceAll('red', color)),
    tier: Tier.hard,
    levelVersion: 1,
    rewardCoins: 50,
    themeId: 'ch01',
  );

  /// Lets the bridge's async work (date symbols, the generator's answer, a
  /// queued second run) finish.
  Future<void> idle() async {
    for (var i = 0; i < 6; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  Map<String, Object?> last() =>
      jsonDecode(widget.lastJson!) as Map<String, Object?>;

  Future<void> build({bool unlocked = true}) async {
    clock = FakeClock(now: DateTime(2026, 10, 8, 12));
    daily = _CountingDaily(clock)..unlocked = unlocked;
    save = FakeSaveService();
    settings = FakeDatabaseService();
    widget = FakeHomeWidgetService();
    final today = clock.today();
    resolver = FakeLevelResolver(
      FakeLevelRepository(),
      FakeSaveService(),
      FakeRemoteConfigService(),
      generated: {
        PlayRequest.daily(today.yyyymmdd): entry(today, 'navy'),
        PlayRequest.daily(today.addDays(1).yyyymmdd): entry(
          today.addDays(1),
          'orange',
        ),
        PlayRequest.daily(today.addDays(2).yyyymmdd): entry(
          today.addDays(2),
          'green',
        ),
      },
    );
    bridge = HomeWidgetBridge(
      widget,
      daily,
      settings,
      resolver,
      clock,
      save,
      scheme: 'nesty-dev',
      deviceLocales: () => const [Locale('en', 'US')],
    );
  }

  tearDown(() async {
    await bridge.dispose();
    await settings.close();
  });

  test(
    'start writes the snapshot, then once more when the dolls arrive',
    () async {
      await build();
      bridge.start();
      await idle();
      expect(widget.published, hasLength(2));
      final first = jsonDecode(widget.published.first) as Map<String, Object?>;
      final days = first['days']! as List;
      expect((days.first as Map)['dolls'], isEmpty);
      final json = last();
      expect(json['v'], 1);
      expect(json['scheme'], 'nesty-dev');
      expect(json['lang'], 'en');
      expect(json['unlocked'], isTrue);
      final lastDays = json['days']! as List;
      expect((lastDays[0] as Map)['dolls'], ['#2F3E8F']);
      expect((lastDays[1] as Map)['dolls'], ['#F2893B']);
      expect((lastDays[2] as Map)['dolls'], isEmpty, reason: 'two days only');
    },
  );

  test('skips a snapshot identical to the last stored', () async {
    await build();
    bridge.start();
    await idle();
    final count = widget.published.length;
    await bridge.publish();
    await bridge.publish();
    await idle();
    expect(widget.published, hasLength(count));
  });

  test('start is idempotent', () async {
    await build();
    bridge
      ..start()
      ..start();
    await idle();
    expect(widget.published, hasLength(2));
  });

  test('writes on a daily change', () async {
    await build();
    bridge.start();
    await idle();
    final count = widget.published.length;
    daily.status = daily.status.copyWith(streak: 6, lit: true);
    await idle();
    expect(widget.published.length, count + 1);
    final days = last()['days']! as List;
    expect((days.first as Map)['streak'], 6);
  });

  test('writes on a language change, in that language', () async {
    await build();
    bridge.start();
    await idle();
    final count = widget.published.length;
    await settings.setLanguage('de');
    await idle();
    expect(widget.published.length, count + 1);
    expect(last()['lang'], 'de');
    final days = last()['days']! as List;
    expect((days.first as Map)['title'], 'Rätsel vom Donnerstag');
  });

  test(
    'writes on resume when the day moved, and not when nothing did',
    () async {
      await build();
      bridge.start();
      await idle();
      var count = widget.published.length;
      bridge.didChangeAppLifecycle(AppLifecycleState.resumed);
      await idle();
      expect(widget.published, hasLength(count), reason: 'same facts');

      bridge.didChangeAppLifecycle(AppLifecycleState.paused);
      clock.setDate(clock.today().addDays(1));
      bridge.didChangeAppLifecycle(AppLifecycleState.paused);
      await idle();
      expect(widget.published, hasLength(count), reason: 'only resume writes');

      bridge.didChangeAppLifecycle(AppLifecycleState.resumed);
      await idle();
      expect(widget.published.length, greaterThan(count));
      count = widget.published.length;
      final days = last()['days']! as List;
      expect((days.first as Map)['date'], '2026-10-09');
      expect((days.first as Map)['dolls'], ['#F2893B']);
    },
  );

  test('writes when the save unlocks the Daily, before any screen refreshes '
      'it', () async {
    await build(unlocked: false);
    bridge.start();
    await idle();
    expect(last()['unlocked'], isFalse);
    final count = widget.published.length;
    // Level 2 won: the save changes; DailyService.changes never fires here.
    daily.unlocked = true;
    save.addCoins(1);
    await idle();
    expect(widget.published.length, greaterThan(count));
    expect(last()['unlocked'], isTrue);
  });

  test('a save change the widget cannot show composes nothing', () async {
    await build();
    bridge.start();
    await idle();
    final counting = daily as _CountingDaily;
    final composed = counting.projections;
    // Coins, and today's board in progress (every move saves it).
    save.addCoins(5);
    save.writeDaily(
      save.document.daily.copyWith(inProgress: _inProgress(clock.today())),
    );
    await idle();
    expect(counting.projections, composed);
    // A solve does.
    save.writeDaily(save.document.daily.copyWith(streak: 1, lit: true));
    await idle();
    expect(counting.projections, greaterThan(composed));
  });

  test('a locked Daily writes unlocked: false and asks for no dolls', () async {
    await build(unlocked: false);
    bridge.start();
    await idle();
    expect(widget.published, hasLength(1));
    expect(last()['unlocked'], isFalse);
    final days = last()['days']! as List;
    expect((days.first as Map)['dolls'], isEmpty);
    expect((last()['locked']! as Map)['small'], 'Opens after Level 2');
  });

  test('a store that fails is tried again at the next trigger', () async {
    await build();
    widget.next = false;
    bridge.start();
    await idle();
    final failed = widget.published.length;
    expect(failed, greaterThan(0));
    widget.next = true;
    await bridge.publish();
    await idle();
    expect(widget.published.length, failed + 1);
    await bridge.publish();
    await idle();
    expect(widget.published.length, failed + 1, reason: 'now stored');
  });

  test('never throws, whatever the service does', () async {
    await build();
    bridge = HomeWidgetBridge(
      _ThrowingWidget(),
      daily,
      settings,
      resolver,
      clock,
      save,
      scheme: 'nesty',
      deviceLocales: () => const [Locale('en')],
    );
    bridge.start();
    await idle();
    await expectLater(bridge.publish(), completes);
  });

  test('a generator that finds nothing is asked again later', () async {
    await build();
    resolver.generated.clear();
    bridge.start();
    await idle();
    final json = last();
    expect(((json['days']! as List).first as Map)['dolls'], isEmpty);
    final today = clock.today();
    resolver.generated[PlayRequest.daily(today.yyyymmdd)] = entry(
      today,
      'navy',
    );
    await bridge.publish();
    await idle();
    expect((((last()['days']!) as List).first as Map)['dolls'], ['#2F3E8F']);
  });

  test('stops after dispose', () async {
    await build();
    bridge.start();
    await idle();
    final count = widget.published.length;
    await bridge.dispose();
    daily.status = daily.status.copyWith(streak: 9, lit: true);
    await settings.setLanguage('fr');
    await idle();
    expect(widget.published, hasLength(count));
  });
}

class _ThrowingWidget extends FakeHomeWidgetService {
  @override
  Future<bool> publish(HomeWidgetSnapshot snapshot) =>
      throw StateError('the platform is gone');
}

/// Counts [projection] calls: each composed snapshot asks for one.
class _CountingDaily extends FakeDailyService {
  _CountingDaily(super.clock);

  int projections = 0;

  @override
  List<DailyDayProjection> projection(LocalDate from, int days) {
    projections++;
    return super.projection(from, days);
  }
}

InProgressLevel _inProgress(LocalDate date) => InProgressLevel(
  request: PlayRequest.daily(date.yyyymmdd),
  levelId: 'daily-${date.yyyymmdd}',
  levelVersion: 1,
  session: const {},
);
