import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/models/booster.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/ticker/fake_frame_ticker.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/race/cubit/race_cubit.dart';

import '../features/gameplay/bloc/support/bloc_fixtures.dart';
import '../features/gameplay/bloc/support/scripted_level_resolver.dart';

/// E1 for vs Computer (spec-prop §1.1, §7.7; docs/plans/m7-design.md
/// P2.12; brainstorm §5): one race through the real `GameplayBloc` and
/// `RaceCubit` together, on fakes, driven the way the gameplay page drives
/// them (the start effect loads the rival, every board is forwarded, the
/// gate follows the phase). A race offers nothing to buy: Hint, +1 Slot and
/// a purchase confirm never raise a `BoosterOffer` or spend a coin, and the
/// coins only ever rise, by exactly the rival's reward. A loss and a quit
/// write nothing. Nothing in `RaceState` counts down: the pace is the
/// rival's move interval, never a clock shown to the player.
void main() {
  const race = RacePlay(rival: 1, raceNo: 1);
  const startCoins = 500;

  late FakeSaveService save;
  late FakeRemoteConfigService config;
  late FakeFrameTicker ticker;
  late GameplayBloc bloc;
  late RaceCubit cubit;
  late _RacePage page;

  setUp(() {
    config = FakeRemoteConfigService();
    // Past the unlock with coins to spend and no boosters in the wallet: in
    // a campaign level, Hint and +1 Slot would each offer a purchase.
    save = FakeSaveService(
      remoteConfig: config,
      initial: const SaveDocument(
        coins: startCoins,
        currentLevel: 21,
        highestLevel: 21,
      ),
    );
    // The race was chosen on rival select, which stored its number.
    expect(save.beginRace(1), race.raceNo);
    bloc = buildBloc(
      resolver: ScriptedLevelResolver(
        entries: {race: playEntryFor(race, defaultLevel, rewardCoins: 20)},
      ),
      save: save,
      config: config,
    );
    ticker = FakeFrameTicker();
    cubit = RaceCubit(race, save, config, ticker);
    page = _RacePage(bloc, cubit, () => save.document.coins);
  });

  tearDown(() async {
    await page.dispose();
    await cubit.close();
    await bloc.close();
  });

  /// The route opens the race, and the player taps Start.
  Future<void> startRace() async {
    bloc.add(const GameplayStarted(race));
    await settle();
    expect(cubit.state.data?.phase, RacePhase.ready);
    cubit.start();
    await settle();
    expect(dataOf(bloc).raceLive, isTrue);
  }

  /// The player's move from [from] to [to] (tap-tap).
  Future<void> move(String from, String to) async {
    bloc
      ..add(SlotTapped(from))
      ..add(SlotTapped(to));
    await settle();
  }

  test('Hint, +1 Slot and a purchase confirm never offer or spend, and the '
      'coins only rise, by exactly the reward', () async {
    await startRace();
    for (final event in const <GameplayEvent>[
      HintPressed(),
      ExtraSlotPressed(),
      BoosterPurchaseConfirmed(BoosterType.hint),
      BoosterPurchaseConfirmed(BoosterType.slot),
      UndoPressed(),
      RestartPressed(),
    ]) {
      bloc.add(event);
      await settle();
    }
    expect(save.document.coins, startCoins, reason: 'nothing was spent');

    await move(red2, red3);
    bloc.add(const HintPressed());
    await settle();
    await move(red1, red3);

    expect(cubit.state.data?.result, RaceResult.playerWon);
    expect(save.document.coins, startCoins + 20, reason: 'race_reward_1');
    expect(page.states, isNotEmpty);
    for (final state in page.states) {
      expect(state.offer, isNull, reason: 'no BoosterOffer in a race');
      expect(state.canHint, isFalse);
      expect(state.canAddSlot, isFalse);
    }
    for (final seen in [page.hudCoins, page.savedCoins]) {
      var coins = startCoins;
      for (final value in seen) {
        expect(value, greaterThanOrEqualTo(coins), reason: 'coins never fall');
        coins = value;
      }
    }
    expect(page.savedCoins.toSet(), {startCoins, startCoins + 20});
  });

  test('a loss writes nothing: no coins, no win, no unlock, no save '
      'change', () async {
    await startRace();
    final before = save.document;
    var changes = 0;
    final sub = save.changes.listen((_) => changes++);
    addTearDown(sub.cancel);

    // The player never moves; the computer plays its whole race.
    ticker.advance(const Duration(minutes: 10));
    await settle();

    expect(cubit.state.data?.result, RaceResult.rivalWon);
    expect(changes, 0);
    expect(save.document, before);
    expect(dataOf(bloc).acceptsInput, isFalse, reason: 'the gate closed');
  });

  test('a quit mid-race writes nothing', () async {
    await startRace();
    await move(red2, red3);
    ticker.advance(const Duration(seconds: 2));
    final before = save.document;
    var changes = 0;
    final sub = save.changes.listen((_) => changes++);
    addTearDown(sub.cancel);

    // Quit race pops the route, which closes both.
    await page.dispose();
    await cubit.close();
    await bloc.close();

    expect(changes, 0);
    expect(save.document, before);
  });

  test('nothing in RaceState counts down: no time field, and its counts '
      'only go up', () async {
    // The state's fields, by name (freezed's toString lists every one).
    final fields = RegExp(
      r'(\w+):',
    ).allMatches(const RaceState(request: race).toString());
    const timeWords = [
      'time',
      'remaining',
      'left',
      'deadline',
      'countdown',
      'seconds',
      'ms',
      'elapsed',
      'timer',
      'clock',
    ];
    for (final match in fields) {
      final name = match.group(1)!.toLowerCase();
      for (final word in timeWords) {
        expect(name, isNot(contains(word)), reason: 'RaceState.$name');
      }
    }

    await startRace();
    ticker.advance(const Duration(seconds: 30));
    await settle();
    final states = page.raceStates;
    expect(states.length, greaterThan(2));
    for (var i = 1; i < states.length; i++) {
      expect(
        states[i].rivalMoves,
        greaterThanOrEqualTo(states[i - 1].rivalMoves),
      );
      expect(
        states[i].rivalRestarts,
        greaterThanOrEqualTo(states[i - 1].rivalRestarts),
      );
    }
  });
}

/// The gameplay page's race hand-offs without the widgets (m7-design P2.5,
/// P2.10): the bloc's start effect loads the rival, every board the bloc
/// emits goes to the cubit synchronously, and the gate opens when the race
/// runs and closes when it finishes.
final class _RacePage {
  _RacePage(this.bloc, this.cubit, this._savedCoins) {
    _blocSub = bloc.stream.listen((value) {
      final state = value.data;
      if (state == null) return;
      states.add(state);
      hudCoins.add(state.coins);
      if (state.effectSeq != _effectSeq) {
        _effectSeq = state.effectSeq;
        if (state.effect case BoardResetEffect(
          reason: BoardResetReason.start,
        )) {
          cubit.playerBoardLoaded(state.play);
        }
      }
      cubit.playerBoardChanged(state.board);
      savedCoins.add(_savedCoins());
    });
    _raceSub = cubit.stream.listen((value) {
      final state = value.data;
      if (state == null) return;
      raceStates.add(state);
      final previous = _phase;
      _phase = state.phase;
      if (state.phase == RacePhase.running && previous != RacePhase.running) {
        bloc.add(const RaceGateChanged(open: true));
      } else if (state.phase == RacePhase.finished &&
          previous != RacePhase.finished) {
        bloc.add(const RaceGateChanged(open: false));
      }
    });
  }

  final GameplayBloc bloc;
  final RaceCubit cubit;
  final int Function() _savedCoins;

  /// Every player state the bloc emitted, oldest first.
  final List<GameplayState> states = [];

  /// Every race state the cubit emitted, oldest first.
  final List<RaceState> raceStates = [];

  /// The coins the HUD shows (the bloc's) and the save's after each board,
  /// in order: a race only ever adds to them.
  final List<int> hudCoins = [];
  final List<int> savedCoins = [];

  int _effectSeq = 0;
  RacePhase? _phase;
  StreamSubscription<Object?>? _blocSub;
  StreamSubscription<Object?>? _raceSub;

  Future<void> dispose() async {
    await _blocSub?.cancel();
    await _raceSub?.cancel();
    _blocSub = null;
    _raceSub = null;
  }
}
