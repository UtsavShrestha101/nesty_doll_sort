import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/clock/system_clock.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/chest/chest_reward_sequence.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/login_gift/cubit/login_gift_cubit.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_button.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_day_tile.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_sheet.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_tally.dart';
import 'package:nesty_game/l10n/app_localizations.dart';
import 'package:nesty_game/main_dev.dart' as app;

import 'support/board_probe.dart';
import 'support/phone_language.dart';
import 'support/seeded_save.dart';

/// The daily gift on a device (plan-login-gift section 7.5b, frames 13.1 to
/// 13.6; the D169 rule): a seeded save, `NESTY_FAKE_DATE`, and one scenario
/// per run, chosen by `--dart-define=NESTY_GIFT_SCENARIO=<name>`:
///
/// - `ready` (the default): 3 claims, the last 3 days ago (a gap that moves
///   nothing back). Home's gift button wears its dot; the sheet shows Days
///   1-3 done, Day 4 (40 coins) today, none marked missed; Claim flies the
///   coins to Home's pill (+40); the sheet turns to "Tomorrow: 50 coins";
///   closed, the button is at rest.
/// - `claimed`: 2 claims, the last today. No dot; the sheet's claimed line
///   and "Tomorrow: 1 hint", Day 3 plain, no Claim button.
/// - `day7`: 6 claims, the last yesterday. Claim on Day 7 closes the sheet
///   and the chest opens CLOSED with +100 coins and +1 slot shown; Open;
///   Collect leaves the pill at +100 and one more slot; reopened, all seven
///   days are done and "Tomorrow: 20 coins".
/// - `clock_back`: 4 claims, the last (and the latest date seen) 3 days
///   after today, as if the clock were wound back. No dot, "Next gift: 50
///   coins", no Claim, and the save is unchanged.
/// - `hint`: 2 claims, the last yesterday. Claim on Day 3 (1 hint): the
///   tally slides out under the coin pill as the hint flies to it (13.5b),
///   steps up to the new total with its "+1" (13.5c), holds and slides
///   back; one more hint in the save, the coins unchanged.
///
/// ```sh
/// cd apps/game
/// flutter drive --flavor dev --driver test_driver/integration_test.dart \
///   --target integration_test/login_gift_test.dart \
///   --dart-define=NESTY_FAKE_DATE=20260926 \
///   --dart-define=NESTY_GIFT_SCENARIO=ready -d <device>
/// ```
///
/// `nesty-test --only gift` runs each scenario from a fresh install.
/// Written, and run by the device stage, never by the lane. Screenshots are
/// prefixed `g_`. Not on a device: haptics and sound (the sheet's feedback
/// cues are checked on the host, `test/features/login_gift/`).
const _scenario = String.fromEnvironment(
  'NESTY_GIFT_SCENARIO',
  defaultValue: 'ready',
);

const _startCoins = 880;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('the daily gift: $_scenario', (tester) async {
    pinEnglishPhone(tester);
    final today = _fakeToday();
    await switch (_scenario) {
      'claimed' => _seed(
        LoginGiftProgress(claims: 2, lastClaim: today, latestSeen: today),
      ),
      'day7' => _seed(
        LoginGiftProgress(
          claims: 6,
          lastClaim: today.addDays(-1),
          latestSeen: today.addDays(-1),
        ),
      ),
      'hint' => _seed(
        LoginGiftProgress(
          claims: 2,
          lastClaim: today.addDays(-1),
          latestSeen: today.addDays(-1),
        ),
      ),
      'clock_back' => _seed(
        LoginGiftProgress(
          claims: 4,
          lastClaim: today.addDays(3),
          latestSeen: today.addDays(3),
        ),
      ),
      _ => _seed(LoginGiftProgress(claims: 3, lastClaim: today.addDays(-3))),
    };

    app.main();
    final shots = _Shots(binding, tester);
    await tester.pumpUntil(
      () => find.byType(HomePage).evaluate().isNotEmpty,
      timeout: const Duration(seconds: 60),
      reason: 'Home for the seeded save (uninstall the app first)',
    );
    await tester.pumpFor(const Duration(milliseconds: 1000));
    final l10n = lookupAppLocalizations(const Locale('en'));
    final save = get<SaveService>();

    switch (_scenario) {
      case 'claimed':
        await _claimed(tester, shots, l10n, save);
      case 'day7':
        await _day7(tester, shots, l10n, save, today);
      case 'clock_back':
        await _clockBack(tester, shots, l10n, save, today);
      case 'hint':
        await _hint(tester, shots, l10n, save, today);
      default:
        await _ready(tester, shots, l10n, save, today);
    }
    binding.reportData = {
      ...?binding.reportData,
      'login_gift': {
        'scenario': _scenario,
        'platform': Platform.operatingSystem,
      },
    };
    // ignore: avoid_print
    print('NESTY_LOGIN_GIFT ${jsonEncode({'scenario': _scenario})}');
  }, timeout: const Timeout(Duration(minutes: 8)));
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

/// Past Level 2 (the gift unlocks with the Daily), [progress] on the track.
/// Both level fields, so Home's PLAY is level 3's.
Future<void> _seed(LoginGiftProgress progress) => seedSave(
  SaveDocument(
    currentLevel: 3,
    highestLevel: 3,
    coins: _startCoins,
    loginGift: progress,
  ),
);

final _button = find.byKey(GiftButton.faceKey);
final _tally = find.byKey(GiftTally.boxKey);
final _dot = find.byKey(GiftButton.dotKey);
final _claim = find.byKey(GiftSheet.claimKey);

/// What Home's coin pill shows now (capped while the gift's coins fly).
int _pillCoins(WidgetTester tester) =>
    tester.widget<CoinPill>(find.byType(CoinPill).first).coins;

Future<void> _openSheet(WidgetTester tester, AppLocalizations l10n) async {
  await tester.tap(_button);
  await tester.pumpUntil(
    () => find.byType(GiftSheet).evaluate().isNotEmpty,
    reason: 'the gift sheet',
  );
  // Past the sheet's slide in.
  await tester.pumpFor(const Duration(milliseconds: 900));
  expect(find.text(l10n.giftTitle), findsWidgets);
  expect(find.byType(GiftDayTile), findsNWidgets(7), reason: 'all seven days');
}

/// The sheet closes by its scrim, above the sheet's top gap.
Future<void> _closeSheet(WidgetTester tester) async {
  await tester.tapAt(const Offset(20, 20));
  await tester.pumpUntil(
    () => find.byType(GiftSheet).evaluate().isEmpty,
    reason: 'the sheet closed',
  );
  await tester.pumpFor(const Duration(milliseconds: 500));
}

GiftTileState _tile(WidgetTester tester, int day) => tester
    .widgetList<GiftDayTile>(find.byType(GiftDayTile))
    .firstWhere((tile) => tile.day == day)
    .tileState;

/// Days [done] are done, [today] (if any) is today's, the rest are plain
/// (never marked missed: there is no such state).
void _expectTrack(WidgetTester tester, {required int done, int? today}) {
  for (var day = 1; day <= 7; day++) {
    final expected = day <= done
        ? GiftTileState.done
        : day == today
        ? GiftTileState.today
        : GiftTileState.later;
    expect(_tile(tester, day), expected, reason: 'Day $day');
  }
}

Future<void> _ready(
  WidgetTester tester,
  _Shots shots,
  AppLocalizations l10n,
  SaveService save,
  LocalDate today,
) async {
  expect(_button, findsOneWidget, reason: 'the gift is unlocked');
  expect(_dot, findsOneWidget, reason: 'a gift to claim');
  await shots.take('g_01_home_ready');

  await _openSheet(tester, l10n);
  _expectTrack(tester, done: 3, today: 4);
  expect(_claim, findsOneWidget);
  expect(find.text(l10n.giftClaim), findsOneWidget);
  await shots.take('g_02_sheet_ready');

  await tester.tap(_claim);
  // The coins leave the tile (700 ms flights, 60 ms apart): shot in the air.
  await tester.pumpFor(const Duration(milliseconds: 280));
  await shots.take('g_03_claim_flight');
  expect(_tally, findsNothing, reason: 'coins go to the pill, not the tally');
  await tester.pumpUntil(
    () => _pillCoins(tester) == _startCoins + 40,
    timeout: const Duration(seconds: 10),
    reason: "Home's pill at +40",
  );
  await tester.pumpFor(const Duration(milliseconds: 800));
  expect(_claim, findsNothing, reason: 'no second claim today');
  expect(find.text(l10n.giftClaimedLine), findsOneWidget);
  expect(find.text(l10n.giftTomorrow(l10n.giftCoins(50))), findsOneWidget);
  _expectTrack(tester, done: 4);
  await shots.take('g_04_sheet_claimed');

  await _closeSheet(tester);
  expect(_dot, findsNothing, reason: 'the button at rest');
  expect(_button, findsOneWidget);
  expect(_pillCoins(tester), _startCoins + 40);
  await shots.take('g_05_home_claimed');

  final gift = save.document.loginGift;
  expect(gift.claims, 4);
  expect(gift.lastClaim, today);
  expect(save.coins, _startCoins + 40);
}

Future<void> _claimed(
  WidgetTester tester,
  _Shots shots,
  AppLocalizations l10n,
  SaveService save,
) async {
  expect(_button, findsOneWidget);
  expect(_dot, findsNothing, reason: "today's gift is already yours");
  await shots.take('g_11_home_no_dot');

  await _openSheet(tester, l10n);
  expect(_claim, findsNothing);
  expect(find.text(l10n.giftClaim), findsNothing);
  expect(find.text(l10n.giftClaimedLine), findsOneWidget);
  expect(find.text(l10n.giftTomorrow(l10n.giftHints(1))), findsOneWidget);
  _expectTrack(tester, done: 2);
  expect(_tile(tester, 3), GiftTileState.later, reason: 'Day 3 is plain');
  await shots.take('g_12_sheet_claimed');

  expect(save.document.loginGift.claims, 2, reason: 'nothing was claimed');
  expect(save.coins, _startCoins);
}

Future<void> _day7(
  WidgetTester tester,
  _Shots shots,
  AppLocalizations l10n,
  SaveService save,
  LocalDate today,
) async {
  final slotsBefore = save.boosterCount(BoosterKind.extraSlot);
  expect(_dot, findsOneWidget);
  await _openSheet(tester, l10n);
  _expectTrack(tester, done: 6, today: 7);
  await shots.take('g_21_sheet_day7');

  await tester.tap(_claim);
  // Day 7 closes the sheet, then the chest opens over Home.
  await tester.pumpUntil(
    () => find.byType(GiftSheet).evaluate().isEmpty,
    reason: 'the sheet closed on Day 7',
  );
  await tester.pumpUntil(
    () => find.byKey(ChestRewardSequence.cardKey).evaluate().isNotEmpty,
    reason: 'the Day 7 chest',
  );
  // The chest's arrival has to be over for the shot to show the settled art.
  await tester.pumpFor(const Duration(milliseconds: 2200));
  expect(find.text(l10n.giftChestTitle), findsOneWidget);
  // The house orange ribbon of 10.3b and 5.6 (`gift.chest.tint`: none).
  expect(
    tester.widget<RibbonTitle>(find.byType(RibbonTitle)).gradient,
    AppGradientTokens.primary,
  );
  expect(find.text(l10n.chestContentsCoins(100)), findsOneWidget);
  expect(find.text(l10n.chestContentsSlot(1)), findsOneWidget);
  expect(find.text(l10n.chestOpen), findsOneWidget);
  expect(find.text(l10n.dailyChestCollect), findsNothing);
  await shots.take('g_22_chest_closed');

  await tester.tap(find.text(l10n.chestOpen));
  await tester.pumpUntil(
    () => find.text(l10n.dailyChestCollect).evaluate().isNotEmpty,
    reason: 'the open chest with Collect',
  );
  await tester.pumpFor(const Duration(milliseconds: 2000));
  await shots.take('g_23_chest_open');

  await tester.tap(find.text(l10n.dailyChestCollect));
  // 13.6d: the coins fly to the pill and the slot to the tally under it.
  await tester.pumpUntil(
    () => _tally.evaluate().isNotEmpty,
    reason: 'the tally for the slot',
  );
  await tester.pumpFor(const Duration(milliseconds: 350));
  await shots.take('g_25_day7_collect');
  await tester.pumpUntil(
    () => find.byKey(GiftTally.tagKey).evaluate().isNotEmpty,
    reason: 'the slot landed on the tally',
  );
  expect(
    find.descendant(of: _tally, matching: find.text('${slotsBefore + 1}')),
    findsOneWidget,
    reason: "the tally shows the player's new total",
  );
  await tester.pumpUntil(
    () => find.byKey(ChestRewardSequence.cardKey).evaluate().isEmpty,
    timeout: const Duration(seconds: 10),
    reason: 'the chest closed after Collect',
  );
  await tester.pumpUntil(
    () => _pillCoins(tester) == _startCoins + 100,
    timeout: const Duration(seconds: 10),
    reason: "Home's pill at +100",
  );
  expect(save.coins, _startCoins + 100);
  expect(save.boosterCount(BoosterKind.extraSlot), slotsBefore + 1);
  expect(save.document.loginGift.claims, 7);
  expect(save.document.loginGift.lastClaim, today);

  await tester.pumpFor(const Duration(milliseconds: 600));
  expect(_dot, findsNothing);
  await _openSheet(tester, l10n);
  _expectTrack(tester, done: 7);
  expect(_claim, findsNothing);
  expect(find.text(l10n.giftClaimedLine), findsOneWidget);
  expect(find.text(l10n.giftTomorrow(l10n.giftCoins(20))), findsOneWidget);
  await shots.take('g_24_track_done');
}

Future<void> _clockBack(
  WidgetTester tester,
  _Shots shots,
  AppLocalizations l10n,
  SaveService save,
  LocalDate today,
) async {
  final seeded = save.document.loginGift;
  expect(_button, findsOneWidget);
  expect(_dot, findsNothing, reason: 'a wound-back clock claims nothing');
  await _openSheet(tester, l10n);
  expect(_claim, findsNothing);
  expect(find.text(l10n.giftClaim), findsNothing);
  expect(find.text(l10n.giftNext(l10n.giftCoins(50))), findsOneWidget);
  expect(find.text(l10n.giftClaimedLine), findsNothing);
  _expectTrack(tester, done: 4);
  await shots.take('g_31_waiting');

  final after = save.document.loginGift;
  expect(after.claims, 4);
  expect(after.lastClaim, seeded.lastClaim);
  expect(after.latestSeen, today.addDays(3), reason: 'never lowered');
  expect(save.coins, _startCoins);
}

Future<void> _hint(
  WidgetTester tester,
  _Shots shots,
  AppLocalizations l10n,
  SaveService save,
  LocalDate today,
) async {
  final hintsBefore = save.boosterCount(BoosterKind.hint);
  expect(_dot, findsOneWidget);
  await _openSheet(tester, l10n);
  _expectTrack(tester, done: 2, today: 3);
  await tester.tap(_claim);
  // 13.5b: the hint in the air, the tally out under the pill at the old
  // count.
  await tester.pumpFor(const Duration(milliseconds: 350));
  expect(_tally, findsOneWidget, reason: 'the tally slid out');
  await shots.take('g_41_hint_flight');
  await tester.pumpUntil(
    () => find.byKey(GiftTally.tagKey).evaluate().isNotEmpty,
    reason: 'the hint landed on the tally',
  );
  await tester.pumpFor(const Duration(milliseconds: 300));
  expect(
    find.descendant(of: _tally, matching: find.text('${hintsBefore + 1}')),
    findsOneWidget,
    reason: "the tally shows the player's new total",
  );
  // 13.5c: the tag sits on the tally, clear of "CHAPTER n".
  await shots.take('g_42_hint_landed');
  await tester.pumpUntil(
    () => _tally.evaluate().isEmpty,
    timeout: const Duration(seconds: 6),
    reason: 'the tally held, then slid back',
  );
  expect(find.text(l10n.giftClaimedLine), findsOneWidget);
  expect(find.text(l10n.giftTomorrow(l10n.giftCoins(40))), findsOneWidget);
  _expectTrack(tester, done: 3);

  await _closeSheet(tester);
  expect(_dot, findsNothing);
  expect(save.boosterCount(BoosterKind.hint), hintsBefore + 1);
  expect(save.coins, _startCoins);
  expect(save.document.loginGift.claims, 3);
  expect(save.document.loginGift.lastClaim, today);
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
