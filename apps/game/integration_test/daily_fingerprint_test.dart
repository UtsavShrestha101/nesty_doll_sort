import 'dart:async' show unawaited;
import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/daily/daily_service.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/main_dev.dart' as app;

import 'support/board_probe.dart';
import 'support/fingerprint.dart';

/// The daily-puzzle cross-device parity check (plan-m3.md "Verification":
/// "golden fingerprints for 28 consecutive dates ... The dev flavor's
/// `NESTY_FAKE_DATE` puzzle gives the same fingerprint on the iOS simulator
/// and the Android emulator."; m3-design §16).
///
/// ```sh
/// cd apps/game
/// flutter drive --flavor dev --driver test_driver/integration_test.dart \
///   --target integration_test/daily_fingerprint_test.dart \
///   --dart-define=NESTY_FAKE_DATE=20260926 -d <device>
/// ```
///
/// Run with the same define on two devices/platforms, the `reportData`
/// `fingerprint` must come back byte-for-byte equal — the actual
/// acceptance goal (see `Fingerprint`'s own doc comment for why that is a
/// canonical JSON string, not the core goldens' `Hash64` digest).
///
/// This reaches `GameplayRoute` directly with the define's
/// `PlayRequest.daily`,
/// bypassing Home's Daily tile lock: that lock is a UI-only gate
/// (`DailyState.status.unlocked`, m3-design §8.3), never enforced by
/// `LevelResolver` or the route itself, and this checks only what it is
/// for — `IsolateLevelGeneratorService`/`Generator.generateWithRetries`
/// producing the same level for the same seed on the device (spec §7.5,
/// §18 M3) — not the unlock flow, which is `daily_cubit_test.dart`'s and
/// `playthrough_test.dart`'s job.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    "opens today's daily and reports its level fingerprint",
    (tester) async {
      app.main();
      final board = Board(tester);

      await tester.pumpUntil(
        () => find.byType(HomePage).evaluate().isNotEmpty,
        timeout: const Duration(seconds: 60),
        reason: 'Home',
      );
      await tester.pumpFor(const Duration(milliseconds: 500));

      // `GameplayState.levelNumber` (`entry.order`) is the date itself for a
      // daily (`GameplayBloc._entryOf`'s `DailyPlay(:final yyyymmdd) =>
      // yyyymmdd`), so `waitForLevel` can wait on it directly.
      const date = int.fromEnvironment('NESTY_FAKE_DATE');
      expect(
        date,
        isNot(0),
        reason: 'run with --dart-define=NESTY_FAKE_DATE=yyyymmdd',
      );
      // The app's own clock follows the define (`SystemClock`), so this is
      // the request Daily's Play would open today.
      expect(get<DailyService>().todayRequest, const PlayRequest.daily(date));
      final home = tester.element(find.byType(HomePage));
      unawaited(
        home.router.push(GameplayRoute(request: const PlayRequest.daily(date))),
      );
      await board.waitForLevel(date, settle: const Duration(milliseconds: 500));

      final level = board.session!.level;
      expect(level.seed, isNotNull, reason: 'a generated level always has one');

      final data = {
        'date': date,
        'levelId': level.id,
        'generatorVersion': level.generatorVersion,
        'seed': level.seed,
        'fingerprint': Fingerprint.ofLevel(level),
      };
      binding.reportData = {'dailyFingerprint': data};
      // ignore: avoid_print
      print('NESTY_DAILY ${jsonEncode(data)}');
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
