import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/models/reminder_settings.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/clock/system_clock.dart';
import 'package:nesty_game/core/services/home_widget/home_widget_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/features/daily/pages/daily_page.dart';
import 'package:nesty_game/features/daily/widgets/daily_locked_card.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/main_dev.dart' as app;

import '../test/l10n/locales/en.dart';
import 'support/board_probe.dart';
import 'support/phone_language.dart';
import 'support/seeded_save.dart';

/// The home-screen widget's data and link on a device (local habits stage 4,
/// plan-local-habits §4 "Tests"; stage 4 contract §1–§4): a seeded save,
/// `NESTY_FAKE_DATE`, and one scenario per run, chosen by
/// `--dart-define=NESTY_WIDGET_SCENARIO=<name>`:
///
/// - `ready` (the default): a 3-day streak lit through yesterday. Today's
///   entry is `ready`, streak 3.
/// - `solved`: the same save; the daily is played to its win, and the store
///   then reads today `solved`, streak 4.
/// - `paused`: a 4-day streak whose flame is out (a missed day, no freeze).
///   Today's entry is `paused`, streak 4.
/// - `locked`: Level 1 won, Level 2 not. The snapshot says `unlocked: false`.
///
/// Each scenario reads the store back through `HomeWidgetService.readBack()`
/// (the real channel, a debug build) and checks the snapshot (`v`, `scheme`
/// `nesty-dev`, eight days from today, today's `state` and `streak`, every
/// line non-empty and free of the respect rules' denied words), the store's
/// own facts (`storeInfo()`: iOS's App Group resolving, Android's prefs
/// file), then pushes the warm link `nesty-dev://daily` through the
/// binding's route information: the Daily opens, or with the Daily locked
/// nothing moves.
///
/// ```sh
/// cd apps/game
/// flutter drive --flavor dev --driver test_driver/integration_test.dart \
///   --target integration_test/home_widget_test.dart \
///   --dart-define=NESTY_FAKE_DATE=20260926 \
///   --dart-define=NESTY_WIDGET_SCENARIO=ready -d <device>
/// ```
///
/// `nesty-test --only widget` runs each scenario from a fresh install, then
/// the OS-side checks `flutter drive` can't do (the extension in the
/// installed app, the provider in `dumpsys appwidget`, the cold link). Not
/// here: placing the widget on a home screen and its pixels (a person, or
/// the cold-link screenshot). Screenshots are prefixed `w_`.
const _scenario = String.fromEnvironment(
  'NESTY_WIDGET_SCENARIO',
  defaultValue: 'ready',
);

/// The dev flavor's link scheme (contract §4) and App Group (contract §2).
const _scheme = 'nesty-dev';
const _iosGroup = 'group.com.futrix.nesty.dev';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'the home-screen widget: $_scenario',
    (tester) async {
      pinEnglishPhone(tester);
      final today = _fakeToday();
      await switch (_scenario) {
        'paused' => _seedPaused(today),
        'locked' => _seedLocked(),
        _ => _seedLit(today),
      };

      app.main();
      final board = Board(tester);
      final shots = _Shots(binding, tester);
      await tester.pumpUntil(
        () => find.byType(HomePage).evaluate().isNotEmpty,
        timeout: const Duration(seconds: 60),
        reason: 'Home for the seeded save (uninstall the app first)',
      );
      await tester.pumpFor(const Duration(milliseconds: 800));

      final expected = switch (_scenario) {
        'paused' => (state: 'paused', streak: 4),
        'locked' => (state: 'zero', streak: 0),
        _ => (state: 'ready', streak: 3),
      };
      // Unlocked, the dolls arrive in later writes once today's and
      // tomorrow's boards are generated (off the UI isolate): wait for both.
      final json = await _readStore(
        tester,
        reason: "the first snapshot with today's and tomorrow's dolls",
        until: _scenario == 'locked' ? null : _hasTwoDaysOfDolls,
      );
      _expectSnapshot(
        json,
        today: today,
        unlocked: _scenario != 'locked',
        state: expected.state,
        streak: expected.streak,
      );
      await _expectStoreInfo();
      await shots.take('w_${_scenario}_store');

      // The warm link: the app is running on Home.
      await _pushWidgetLink(binding, tester);
      if (_scenario == 'locked') {
        // Locked: nothing moves (contract §4, the lead's ruling).
        await tester.pumpFor(const Duration(seconds: 2));
        expect(find.byType(HomePage), findsOneWidget, reason: 'still on Home');
        expect(find.byType(DailyPage), findsNothing);
        expect(find.byType(DailyLockedCard), findsNothing);
        await shots.take('w_locked_warm_link');
      } else {
        await tester.pumpUntil(
          () => find.byType(DailyPage).evaluate().isNotEmpty,
          reason: 'the warm link opens the Daily',
        );
        await tester.pumpFor(const Duration(seconds: 1));
        await shots.take('w_${_scenario}_warm_link');
      }

      if (_scenario == 'solved') {
        await _playDailyToWin(tester, board);
        await shots.take('w_solved_win');
        final after = await _readStore(
          tester,
          reason: "today's entry solved",
          until: (j) => _today(j, today)['state'] == 'solved',
        );
        _expectSnapshot(
          after,
          today: today,
          unlocked: true,
          state: 'solved',
          streak: 4,
        );
        await shots.take('w_solved_store_after_win');
      }

      binding.reportData = {
        ...?binding.reportData,
        'home_widget': {
          'scenario': _scenario,
          'platform': Platform.operatingSystem,
        },
      };
      // ignore: avoid_print
      print('NESTY_WIDGET ${jsonEncode({'scenario': _scenario})}');
    },
    timeout: const Timeout(Duration(minutes: 8)),
  );
}

/// `NESTY_FAKE_DATE` as a date; the run fails without it, since the seeds
/// are dated against it.
LocalDate _fakeToday() {
  const define = SystemClock.fakeDateDefine;
  expect(
    define,
    isNotEmpty,
    reason: 'pass --dart-define=NESTY_FAKE_DATE=yyyymmdd (dev flavor)',
  );
  return LocalDate.fromYyyymmdd(int.parse(define));
}

const _noOffer = SeededSettings(reminder: ReminderSettings(offered: true));

/// Three days lit through yesterday: today's solve is day 4. Level 3 next,
/// so the daily is unlocked.
Future<void> _seedLit(LocalDate today) => seedSave(
  SaveDocument(
    currentLevel: 3,
    highestLevel: 3,
    coins: 880,
    daily: DailyProgress(
      streak: 3,
      lit: true,
      run: 3,
      lastDate: today.addDays(-1),
      done: [for (var back = 3; back >= 1; back--) today.addDays(-back)],
    ),
  ),
  settings: _noOffer,
);

/// Four days counted, the flame out, this week's freeze spent (as
/// `daily_states_test`'s `paused`).
Future<void> _seedPaused(LocalDate today) => seedSave(
  SaveDocument(
    currentLevel: 3,
    highestLevel: 3,
    coins: 880,
    daily: DailyProgress(
      streak: 4,
      freezeWeek: today.isoWeekKey,
      done: [for (var back = 6; back >= 3; back--) today.addDays(-back)],
    ),
  ),
  settings: _noOffer,
);

/// Level 1 won, Level 2 not: the Daily is locked.
Future<void> _seedLocked() => seedSave(
  const SaveDocument(currentLevel: 2, highestLevel: 2, coins: 880),
  settings: _noOffer,
);

/// Reads the store through the real channel until [until] holds (the app
/// publishes after its own work, off the first frame).
Future<Map<String, Object?>> _readStore(
  WidgetTester tester, {
  required String reason,
  bool Function(Map<String, Object?> json)? until,
}) async {
  final service = get<HomeWidgetService>();
  Map<String, Object?>? last;
  for (var i = 0; i < 60; i++) {
    final raw = await service.readBack();
    if (raw != null) {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, Object?>) {
        last = decoded;
        if (until == null || until(decoded)) return decoded;
      }
    }
    await tester.pumpFor(const Duration(milliseconds: 500));
  }
  fail('no snapshot in the store for: $reason (last: $last)');
}

bool _hasTwoDaysOfDolls(Map<String, Object?> json) {
  final days = (json['days'] as List?)?.cast<Map<String, Object?>>() ?? [];
  return days.length > 1 &&
      days.take(2).every((d) => (d['dolls'] as List?)?.isNotEmpty ?? false);
}

Map<String, Object?> _today(Map<String, Object?> json, LocalDate today) {
  final days = (json['days']! as List).cast<Map<String, Object?>>();
  return days.firstWhere(
    (d) => d['date'] == today.toIso(),
    orElse: () => const {},
  );
}

void _expectSnapshot(
  Map<String, Object?> json, {
  required LocalDate today,
  required bool unlocked,
  required String state,
  required int streak,
}) {
  expect(json['v'], 1, reason: 'schema v1');
  expect(json['scheme'], _scheme, reason: 'the dev flavor scheme');
  expect(json['lang'], 'en', reason: 'the pinned phone language');
  expect(json['unlocked'], unlocked, reason: 'the Daily is open or not');

  final days = (json['days']! as List).cast<Map<String, Object?>>();
  expect(days, hasLength(8), reason: 'today and the 7 days after');
  for (var i = 0; i < 8; i++) {
    expect(days[i]['date'], today.addDays(i).toIso(), reason: 'day $i');
  }
  expect(days.first['state'], state, reason: "today's state");
  expect(days.first['streak'], streak, reason: "today's streak");
  // Doll colours for today and tomorrow only, none while locked (D312).
  for (var i = 0; i < 8; i++) {
    final dolls = days[i]['dolls']! as List;
    expect(dolls.isNotEmpty, unlocked && i < 2, reason: 'day $i dolls: $dolls');
    for (final hex in dolls) {
      expect(hex, matches(RegExp(r'^#[0-9A-F]{6}$')), reason: 'day $i dolls');
    }
  }

  final locked = json['locked']! as Map<String, Object?>;
  final lines = <String>[
    for (final key in ['title', 'small', 'medium', 'a11y'])
      locked[key]! as String,
    for (final day in days)
      for (final key in ['label', 'title', 'sub', 'line', 'lineShort', 'a11y'])
        day[key]! as String,
    for (final day in days)
      if (day['labelShort'] case final String short) short,
  ];
  for (final line in lines) {
    expect(line.trim(), isNotEmpty, reason: 'a localized line is empty');
    // The respect rules (spec-prop §1.1): the same denied lists the ARB
    // tests use, on every string the widget can draw.
    expect(
      enRules.offences(enRules.denied, line),
      isEmpty,
      reason: '"$line" uses a denied word',
    );
  }
}

/// Where the store lives: iOS's App Group (and that it resolves, the risk
/// the plan wants verified on a simulator), Android's prefs file.
Future<void> _expectStoreInfo() async {
  final info = await get<HomeWidgetService>().storeInfo();
  expect(info, isNotNull, reason: 'a debug build answers storeInfo');
  if (Platform.isIOS) {
    expect(info!['group'], _iosGroup);
    expect(info['resolves'], isTrue, reason: 'the App Group container');
  } else {
    expect(info!['prefs'], 'nesty_widget');
  }
}

/// The widget's tap while the app runs: the platform hands Flutter a route
/// information, which `deepLinkBuilder` sees as a warm link.
Future<void> _pushWidgetLink(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
) async {
  // The message the platform embedder sends for a link (the engine's
  // `flutter/navigation` channel), so the real observers and `deepLinkBuilder`
  // run.
  const codec = JSONMethodCodec();
  unawaited(
    binding.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/navigation',
      codec.encodeMethodCall(
        const MethodCall('pushRouteInformation', <String, Object?>{
          'location': '$_scheme://daily',
          'state': null,
        }),
      ),
      (_) {},
    ),
  );
  await tester.pumpFor(const Duration(milliseconds: 500));
}

/// Plays today's daily to its win with the solver's own hints, from the
/// Daily screen's Play (as `daily_states_test`'s).
Future<void> _playDailyToWin(WidgetTester tester, Board board) async {
  await tester.tap(find.text('Play'));
  await tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isNotEmpty &&
        board.game.geometry != null &&
        board.game.skin != null,
    timeout: const Duration(seconds: 30),
    reason: "today's daily with its skin",
  );
  await board.waitIdle();
  await tester.pumpFor(const Duration(milliseconds: 1200));
  final hintButton = find.text('Hint');
  for (var i = 0; i < 40; i++) {
    for (
      var shown = board.state.intro;
      shown != null;
      shown = board.state.intro
    ) {
      await tester.pumpFor(const Duration(milliseconds: 400));
      await tester.tap(find.text('Got it'));
      await tester.pumpUntil(
        () => board.state.intro != shown,
        reason: 'the ${shown.name} intro card dismissed',
      );
    }
    if (board.state.status != GameplayStatus.playing) break;
    await board.waitIdle();
    if (board.state.status != GameplayStatus.playing) break;
    await tester.pumpUntil(
      () => hintButton.hitTestable().evaluate().isNotEmpty,
      reason: 'Hint uncovered',
    );
    await tester.tap(hintButton);
    await tester.pumpUntil(
      () => board.state.hint != null,
      timeout: const Duration(seconds: 15),
      reason: 'a hint',
    );
    final hint = board.state.hint!;
    await board.move(hint.from, hint.to);
  }
  await board.waitForWinOverlay();
  await tester.pumpFor(const Duration(milliseconds: 1500));
}

final class _Shots {
  _Shots(this._binding, this._tester);

  final IntegrationTestWidgetsFlutterBinding _binding;
  final WidgetTester _tester;
  bool _converted = false;

  Future<void> take(String name) async {
    if (Platform.isAndroid && !_converted) {
      await _binding.convertFlutterSurfaceToImage();
      _converted = true;
    }
    await _tester.pump();
    final bytes = await _binding.takeScreenshot(name);
    expect(bytes, isNotEmpty, reason: name);
  }
}
