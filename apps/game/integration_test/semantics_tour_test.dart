import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nesty_core/nesty_core.dart' show Tier;
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/models/reduce_motion_mode.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/services/database/hive_boxes.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/chapters/pages/chapters_page.dart';
import 'package:nesty_game/features/chapters/widgets/chapter_level_cell.dart';
import 'package:nesty_game/features/chapters/widgets/level_card.dart';
import 'package:nesty_game/features/daily/pages/daily_page.dart';
import 'package:nesty_game/features/fx/chest/chest_reward_sequence.dart';
import 'package:nesty_game/features/fx/fx_spinner.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/overlays/milestone_chest_modal.dart';
import 'package:nesty_game/features/gameplay/overlays/out_of_moves_sheet.dart';
import 'package:nesty_game/features/gameplay/overlays/race_result_overlay.dart';
import 'package:nesty_game/features/gameplay/overlays/tutorial_overlay.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/museum/pages/museum_page.dart';
import 'package:nesty_game/features/museum/widgets/figurine_modal.dart';
import 'package:nesty_game/features/race/pages/rival_select_page.dart';
import 'package:nesty_game/features/records/pages/records_page.dart';
import 'package:nesty_game/features/settings/pages/settings_page.dart';
import 'package:nesty_game/features/settings/widgets/language_sheet.dart';
import 'package:nesty_game/features/shop/pages/shop_page.dart';
import 'package:nesty_game/features/shop/pages/skin_detail_page.dart';
import 'package:nesty_game/features/shop/widgets/shop_buy_button.dart';
import 'package:nesty_game/features/shop/widgets/skin_grid_card.dart';
import 'package:nesty_game/features/splash/pages/splash_page.dart';
import 'package:nesty_game/main_dev.dart' as app;

import 'support/board_probe.dart';
import 'support/hint_solver.dart';
import 'support/phone_language.dart';
import 'support/race_solver.dart';
import 'support/seeded_save.dart';

/// What a screen reader is given on each screen (phase 5, architecture.md
/// §2.1; D169's "Screen readers" row): one scenario per run, chosen by
/// `--dart-define=NESTY_A11Y_SCENARIO=<name>`, each from a fresh install:
///
/// - `race` (run with `--dart-define=NESTY_RACE_PACE_MS=600000`): past
///   Level 20, Pebble beaten, Button new: rival select (9.2), the strip
///   ready and running (9.3), a solve with core's own line, the win (9.4),
///   the unlock card (9.6), then a race against Comet, its Pause (9.7) and
///   Leave race's question (9.7b);
/// - `race_loss` (run with `--dart-define=NESTY_RACE_PACE_MS=250`): the
///   computer finishes first (9.5);
/// - `game`: the splash, level 1's three tutorial steps and its win, Home,
///   level 16's towers card, Out of Moves and Pause, level 10's win and its
///   chest, closed and open;
/// - `meta` (a returning player, 60 levels won, 300 coins): Home, Daily, the
///   daily's win and the reminder offer, the Museum and a figurine, the
///   Shop, a skin's detail and "Not enough coins", Settings, its language
///   sheet and Reduce motion, Chapters and a level card, Records.
///
/// On each screen it walks the live semantics tree in traversal order
/// (`SemanticsController.simulatedAccessibilityTraversal`, the order
/// TalkBack and VoiceOver move in) and records every node that has a label,
/// value, hint or action into `reportData['semantics']`, with a screenshot
/// `s_<screen>`. It asserts, collecting every miss before failing once at
/// the end:
/// - every tap target has a label;
/// - no two adjacent nodes repeat a label;
/// - a node that names a rival says "Computer", or the node after it does
///   (spec-prop §1.1 rule 5);
/// - a modal overlay leaves nothing actionable of the page under it that a
///   reader could reach (review R11): each such screen names what must be
///   gone.
///
/// `--dart-define=NESTY_A11Y_HOLD=1` holds on each screen for phase 5's
/// TalkBack pass, which moves the reader's focus over the screen meanwhile:
/// it prints the line `NESTY_A11Y_HOLD n screen nodes`, then waits (5
/// minutes at most) for a file `a11y_go_n` in the app's documents folder
/// (on Android, `run-as` the app id, then `touch app_flutter/a11y_go_n`).
/// The app keeps running while it waits.
///
/// ```sh
/// cd apps/game
/// flutter drive --flavor dev --driver test_driver/integration_test.dart \
///   --target integration_test/semantics_tour_test.dart \
///   --dart-define=NESTY_A11Y_SCENARIO=game -d <device>
/// ```
const _scenario = String.fromEnvironment(
  'NESTY_A11Y_SCENARIO',
  defaultValue: 'game',
);

const _holdDefine = String.fromEnvironment('NESTY_A11Y_HOLD');
const _hold = _holdDefine == '1' || _holdDefine == 'true';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'the screen readers\' tour: $_scenario',
    (tester) async {
      pinEnglishPhone(tester);
      final semantics = tester.ensureSemantics();
      final board = Board(tester);
      final tour = _Tour(binding, tester);
      try {
        switch (_scenario) {
          case 'race':
            await _race(tester, board, tour);
          case 'race_loss':
            await _raceLoss(tester, board, tour);
          case 'meta':
            await _meta(tester, board, tour);
          case 'game':
            await _game(tester, board, tour);
          default:
            fail('unknown NESTY_A11Y_SCENARIO $_scenario');
        }
      } finally {
        tour.report();
        semantics.dispose();
      }
      expect(
        tour.issues,
        isEmpty,
        reason: 'what a screen reader would meet (reportData semantics)',
      );
    },
    timeout: const Timeout(Duration(minutes: _hold ? 120 : 15)),
  );
}

/// One screen's node in traversal order, as the report records it.
Map<String, Object?> _entry(SemanticsNode node) {
  final data = node.getSemanticsData();
  return {
    'id': node.id,
    if (data.label.isNotEmpty) 'label': data.label,
    if (data.value.isNotEmpty) 'value': data.value,
    if (data.hint.isNotEmpty) 'hint': data.hint,
    if (data.tooltip.isNotEmpty) 'tooltip': data.tooltip,
    'flags': data.flagsCollection.toStrings(),
    'actions': [
      for (final action in SemanticsAction.values)
        if (data.hasAction(action)) action.name,
    ],
  };
}

bool _actionable(SemanticsData data) =>
    data.hasAction(SemanticsAction.tap) ||
    data.hasAction(SemanticsAction.longPress);

bool _matches(Pattern pattern, String label) => switch (pattern) {
  final String text => label == text,
  final RegExp regExp => regExp.hasMatch(label),
  _ => false,
};

/// The rivals' names (copy.md G.5 `rival_1_name`…`rival_3_name`) as a
/// node's own subject: "Pebble", "Pebble, …", "Pebble. …".
final _namesRival = RegExp(r'^(Pebble|Button|Comet)([,.]|$)');

bool _saysComputer(String label) => label.toLowerCase().contains('computer');

final class _Tour {
  _Tour(this._binding, this._tester);

  final IntegrationTestWidgetsFlutterBinding _binding;
  final WidgetTester _tester;
  final Map<String, List<Map<String, Object?>>> _screens = {};
  final List<String> issues = [];
  bool _converted = false;
  int _holds = 0;

  /// Dumps and checks the screen on show as [screen], shoots `s_<screen>`
  /// and, with `NESTY_A11Y_HOLD`, holds for the TalkBack pass. [hidden]
  /// names what the page under a modal overlay offered: none of it may be
  /// actionable now.
  Future<void> visit(
    String screen, {
    List<Pattern> hidden = const [],
    bool hold = true,
  }) async {
    await _tester.pump();
    final nodes = [
      for (final node in _tester.semantics.simulatedAccessibilityTraversal())
        if (!node.isMergedIntoParent) node,
    ];
    final entries = <Map<String, Object?>>[];
    String? previous;
    for (var i = 0; i < nodes.length; i++) {
      final data = nodes[i].getSemanticsData();
      final label = data.label;
      final hasAction = SemanticsAction.values.any(data.hasAction);
      if (label.isEmpty &&
          data.value.isEmpty &&
          data.hint.isEmpty &&
          !hasAction) {
        continue;
      }
      entries.add(_entry(nodes[i]));
      if (_actionable(data) &&
          label.isEmpty &&
          data.value.isEmpty &&
          data.tooltip.isEmpty) {
        issues.add('$screen: a tap target with no label (node ${nodes[i].id})');
      }
      if (label.isNotEmpty && label == previous) {
        issues.add('$screen: "$label" twice in a row');
      }
      if (label.isNotEmpty) previous = label;
      // Case-insensitive: m7-4's `a11y_*` strings say "computer" mid-sentence
      // ("Pebble, computer. 1 win."), which a reader says the same way (D234).
      if (_namesRival.hasMatch(label) && !_saysComputer(label)) {
        final next = i + 1 < nodes.length
            ? nodes[i + 1].getSemanticsData().label
            : '';
        if (!_saysComputer(next)) {
          issues.add('$screen: "$label" names a rival without "Computer"');
        }
      }
      for (final pattern in hidden) {
        if (_actionable(data) && _matches(pattern, label)) {
          issues.add(
            '$screen: "$label" from the page under the overlay is reachable',
          );
        }
      }
    }
    _screens[screen] = entries;
    // ignore: avoid_print
    print('NESTY_A11Y_SCREEN $screen ${entries.length}');
    await _shoot('s_$screen');
    if (_hold && hold) await _holdFor(screen, entries.length);
  }

  Future<void> _shoot(String name) async {
    if (Platform.isAndroid && !_converted) {
      await _binding.convertFlutterSurfaceToImage();
      _converted = true;
    }
    await _tester.pump();
    final bytes = await _binding.takeScreenshot(name);
    expect(bytes, isNotEmpty, reason: name);
  }

  /// The TalkBack pass's hold (architecture.md §2.2): the script moves the
  /// reader's focus over the screen, then touches `a11y_go_<n>`.
  Future<void> _holdFor(String screen, int count) async {
    final n = ++_holds;
    final go = File('${_documents().path}/a11y_go_$n');
    // ignore: avoid_print
    print('NESTY_A11Y_HOLD $n $screen $count');
    final end = DateTime.now().add(const Duration(minutes: 5));
    while (!go.existsSync()) {
      if (DateTime.now().isAfter(end)) {
        // ignore: avoid_print
        print('NESTY_A11Y_HOLD_TIMEOUT $n $screen');
        return;
      }
      await _tester.pumpFor(const Duration(milliseconds: 250));
    }
    go.deleteSync();
    // ignore: avoid_print
    print('NESTY_A11Y_GO $n $screen');
  }

  /// The app's documents folder, where Hive keeps its `hive/` boxes
  /// (`HiveDatabaseService.open`; Android's `app_flutter`).
  static Directory _documents() {
    try {
      return File(Hive.box<Object>(HiveBoxes.settings).path!).parent.parent;
    } on Object {
      return Directory.systemTemp;
    }
  }

  void report() {
    _binding.reportData = {
      ...?_binding.reportData,
      'semantics': {
        'scenario': _scenario,
        'platform': Platform.operatingSystem,
        'screens': _screens,
        'issues': issues,
      },
    };
    // ignore: avoid_print
    print(
      'NESTY_A11Y ${jsonEncode({'scenario': _scenario, 'screens': _screens.length, 'issues': issues})}',
    );
  }
}

// ── Navigation ───────────────────────────────────────────────────────────

Future<void> _waitHome(WidgetTester tester) async {
  await tester.pumpUntil(
    () =>
        find.byType(SplashPage).evaluate().isEmpty &&
        find.byType(HomePage).evaluate().isNotEmpty,
    timeout: const Duration(seconds: 60),
    reason: 'Home for the seeded save (uninstall the app first)',
  );
  await tester.pumpFor(const Duration(milliseconds: 1200));
}

/// [page]'s route has finished its transition in, then [settle] ms more.
Future<void> _routeSettled(
  WidgetTester tester,
  Type page, {
  int settle = 400,
}) async {
  await tester.pumpUntil(() {
    final element = find.byType(page).evaluate().firstOrNull;
    if (element == null) return false;
    return ModalRoute.of(element)?.animation?.isCompleted ?? false;
  }, reason: 'the $page transition in');
  await tester.pumpFor(Duration(milliseconds: settle));
}

/// [page]'s own header back arrow.
Future<void> _backFrom(WidgetTester tester, Type page) async {
  await tester.tap(
    find.descendant(
      of: find.byType(page),
      matching: find.bySemanticsLabel('Back'),
    ),
  );
  await tester.pumpUntil(
    () => find.byType(page).evaluate().isEmpty,
    reason: 'back from $page',
  );
  await tester.pumpFor(const Duration(milliseconds: 400));
}

Finder _nav(String label) => find.descendant(
  of: find.byType(NestyBottomNav),
  matching: find.text(label),
);

Future<void> _tab(WidgetTester tester, String label, Type page) async {
  await tester.tap(_nav(label));
  await tester.pumpUntil(
    () => find.byType(page).evaluate().isNotEmpty,
    reason: 'the $label tab',
  );
  await tester.pumpFor(const Duration(milliseconds: 900));
}

Future<void> _artReady(WidgetTester tester, String what) async {
  await tester.pumpUntil(
    () => find.byType(FxSpinner).evaluate().isEmpty,
    timeout: const Duration(seconds: 30),
    reason: '$what with its skin art',
  );
  await tester.pumpFor(const Duration(milliseconds: 300));
}

/// A level's tier as its dev picker tile labels it ("Level 16 · Hard").
String _tierLabel(int level) {
  final entry = get<LevelRepository>().entryAt(level)!;
  return switch (entry.tier) {
    Tier.easy => 'Easy',
    Tier.medium => 'Medium',
    Tier.hard => 'Hard',
    Tier.superhard => 'Super Hard',
  };
}

/// Home's dev "Jump to a level" picker to [number], without waiting for the
/// board to go idle: an intro card holds it.
Future<void> _jumpToCard(WidgetTester tester, Board board, int number) async {
  final tile = find.bySemanticsLabel('Level $number · ${_tierLabel(number)}');
  await tester.tap(find.text('Jump to a level'));
  await tester.pumpUntil(
    () => tile.evaluate().isNotEmpty,
    reason: 'the level picker',
  );
  await tester.pumpFor(const Duration(milliseconds: 500));
  if (tile.hitTestable().evaluate().isEmpty) {
    await Scrollable.ensureVisible(tester.element(tile), alignment: 0.5);
    await tester.pumpFor(const Duration(milliseconds: 300));
  }
  await tester.tap(tile);
  await tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isNotEmpty &&
        board.bloc.state.data?.levelNumber == number &&
        board.game.geometry != null &&
        board.game.skin != null,
    timeout: const Duration(seconds: 30),
    reason: 'level $number with its skin',
  );
  await tester.pumpFor(const Duration(milliseconds: 800));
}

// ── game: a fresh install ────────────────────────────────────────────────

Future<void> _game(WidgetTester tester, Board board, _Tour tour) async {
  app.main();
  await tester.pumpUntil(
    () => find.byType(SplashPage).evaluate().isNotEmpty,
    reason: 'the splash',
  );
  await tester.pumpFor(const Duration(milliseconds: 200));
  // The app goes on to level 1 by itself, so the splash is never held.
  if (find.byType(SplashPage).evaluate().isNotEmpty) {
    await tour.visit('splash', hold: false);
  }

  // Level 1's tutorial (frames 1.3–1.6).
  await tester.pumpUntil(
    () => find.byType(TutorialOverlay).evaluate().isNotEmpty,
    timeout: const Duration(seconds: 60),
    reason: "level 1's tutorial",
  );
  await board.waitForLevel(1);
  await tour.visit('l1_step1');
  await board.tap('r0c2');
  await tester.pumpUntil(
    () => board.state.selectedSlotId == 'r0c2',
    reason: 'r0c2 selected',
  );
  await tester.pumpFor(const Duration(milliseconds: 600));
  await tour.visit('l1_step2');
  await board.drop('r0c0');
  await board.waitIdle();
  await tester.pumpUntil(
    () => find.text('STEP 3 OF 3').evaluate().isNotEmpty,
    reason: "the tutorial's step 3",
  );
  await tester.pumpFor(const Duration(milliseconds: 300));
  await tour.visit('l1_step3');
  await board.move('r1c1', 'r0c0');
  await board.waitForWinOverlay();
  await tester.pumpFor(const Duration(milliseconds: 2000));
  await tour.visit('l1_win', hidden: ['Pause']);

  await board.continueHome(level: 2);
  await tester.pumpFor(const Duration(milliseconds: 1500));
  await tour.visit('home');

  // Level 16: the towers card, then the shortest Out of Moves line (the
  // r1c1 tower's top onto the only empty stand), Restart and Pause.
  await _jumpToCard(tester, board, 16);
  await tester.pumpUntil(
    () => board.state.intro != null,
    reason: "level 16's towers card",
  );
  await tester.pumpFor(const Duration(milliseconds: 900));
  await tour.visit('l16_intro');
  await tester.tap(find.text('Got it'));
  await tester.pumpUntil(
    () => board.state.intro == null,
    reason: 'the towers card dismissed',
  );
  await board.waitIdle();
  // The card fades out over the board and takes a tap until it is gone
  // (overlays_test's `_dismissIntro` waits the same 300 ms).
  await tester.pumpFor(const Duration(milliseconds: 300));
  await board.move('r1c1', 'r0c3');
  await tester.pumpUntil(
    () => find.byType(OutOfMovesSheet).evaluate().isNotEmpty,
    timeout: const Duration(seconds: 10),
    reason: 'the Out of Moves sheet',
  );
  await tester.pumpFor(const Duration(milliseconds: 700));
  await tour.visit('out_of_moves', hidden: ['Pause']);
  await tester.tap(
    find.descendant(
      of: find.byType(OutOfMovesSheet),
      matching: find.text('Restart'),
    ),
  );
  await tester.pumpUntil(
    () =>
        find.byType(OutOfMovesSheet).evaluate().isEmpty &&
        board.state.status == GameplayStatus.playing,
    reason: 'the restarted board',
  );
  await board.waitIdle();
  await board.openPause();
  await tester.pumpFor(const Duration(milliseconds: 600));
  await tour.visit('pause', hidden: ['Pause']);
  await board.pauseToHome(level: 2);

  // Level 10: its win pays chapter 1's chest (E5).
  await board.jumpTo(10, _tierLabel(10));
  await solveWithHints(tester, board);
  await board.waitForWinOverlay();
  await tester.pumpFor(const Duration(milliseconds: 3500));
  expect(board.state.chest, isNotNull, reason: 'level 10 pays the chest');
  await tour.visit('l10_win', hidden: ['Pause']);
  await tester.tap(find.text('Continue'));
  await tester.pumpUntil(
    () => find.byType(MilestoneChestModal).evaluate().isNotEmpty,
    reason: 'the milestone chest',
  );
  await tester.pumpFor(
    const Duration(milliseconds: ChestRewardSequence.arrivalMs + 300),
  );
  await tour.visit('chest_closed', hidden: ['Pause']);
  await tester.tap(find.text('Open'));
  await tester.pumpUntil(
    () => find.text('Collect').evaluate().isNotEmpty,
    reason: 'the chest open',
  );
  await tester.pumpFor(const Duration(milliseconds: 500));
  await tour.visit('chest_open', hidden: ['Pause']);
  await tester.tap(find.text('Collect'));
  await tester.pumpUntil(
    () => find.byType(MilestoneChestModal).evaluate().isEmpty,
    timeout: const Duration(seconds: 10),
    reason: 'the chest collected',
  );
}

// ── race and race_loss ───────────────────────────────────────────────────

Future<void> _openSelect(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(HomePage),
      matching: find.text('vs Computer'),
    ),
  );
  await tester.pumpUntil(
    () => find.byType(RivalSelectView).evaluate().isNotEmpty,
    reason: 'rival select',
  );
  await _routeSettled(tester, RivalSelectPage, settle: 600);
}

/// Rival select's Start: the race board, ready, with its skin.
Future<void> _startFromSelect(WidgetTester tester, Board board) async {
  await tester.tap(find.text('Start'));
  await tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isNotEmpty &&
        board.bloc.state.data?.isRace == true &&
        board.game.geometry != null &&
        board.game.skin != null,
    timeout: const Duration(seconds: 30),
    reason: 'the race board with its skin',
  );
  await board.waitIdle();
  await tester.pumpFor(const Duration(milliseconds: 800));
}

Future<void> _tapStart(WidgetTester tester, Board board) async {
  await tester.tap(find.text('Start'));
  await tester.pumpUntil(
    () => board.state.raceLive,
    reason: 'the race running',
  );
}

Future<void> _race(WidgetTester tester, Board board, _Tour tour) async {
  await seedSave(
    const SaveDocument(
      currentLevel: 21,
      highestLevel: 21,
      tutorialDone: true,
      race: RaceProgress(
        rivals: [
          RivalProgress(unlocked: true, wins: 1, raceNo: 1),
          RivalProgress(unlocked: true),
          RivalProgress(),
        ],
      ),
    ),
  );
  app.main();
  await _waitHome(tester);

  await _openSelect(tester);
  await tour.visit('rival_select');
  await _startFromSelect(tester, board);
  await tour.visit('race_ready');
  await _tapStart(tester, board);
  await tester.pumpFor(const Duration(milliseconds: 300));
  await tour.visit('race_running');
  await RaceSolver.play(RaceSolver.line(board.state.board), move: board.move);
  await tester.pumpUntil(
    () => find.byType(RaceWinCard).evaluate().isNotEmpty,
    timeout: const Duration(seconds: 10),
    reason: 'the race win card (9.4)',
  );
  await tester.pumpFor(const Duration(milliseconds: 1500));
  await tour.visit('race_win', hidden: ['Pause']);
  // Past the badge toast, then system back: the unlock card first (9.6).
  await tester.pumpFor(const Duration(milliseconds: 3000));
  await tester.binding.handlePopRoute();
  await tester.pumpUntil(
    () => find.byType(RivalUnlockedCard).evaluate().isNotEmpty,
    reason: 'the 9.6 card',
  );
  await tester.pumpFor(const Duration(milliseconds: 500));
  await tour.visit('rival_unlocked');
  await tester.tap(find.text('Not now'));
  await tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isEmpty &&
        find.byType(RivalSelectView).evaluate().isNotEmpty,
    reason: 'back to rival select',
  );
  await tester.pumpFor(const Duration(milliseconds: 600));

  // Comet, new: Pause (9.7) and Leave race's question (9.7b).
  await _startFromSelect(tester, board);
  await _tapStart(tester, board);
  await tester.pumpFor(const Duration(milliseconds: 200));
  await board.openPause();
  await tester.pumpFor(const Duration(milliseconds: 500));
  await tour.visit('race_pause', hidden: ['Pause']);
  await tester.tap(find.text('Leave race'));
  await tester.pumpFor(const Duration(milliseconds: 500));
  await tour.visit('race_leave_confirm', hidden: ['Pause']);
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('raceLeaveConfirm')),
      matching: find.text('Leave race'),
    ),
  );
  await tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isEmpty &&
        find.byType(RivalSelectView).evaluate().isNotEmpty,
    reason: 'Leave race back to rival select',
  );
}

Future<void> _raceLoss(WidgetTester tester, Board board, _Tour tour) async {
  await seedSave(
    const SaveDocument(currentLevel: 21, highestLevel: 21, tutorialDone: true),
  );
  app.main();
  await _waitHome(tester);
  await _openSelect(tester);
  await _startFromSelect(tester, board);
  await _tapStart(tester, board);
  await tester.pumpUntil(
    () => find.byType(RaceLossCard).evaluate().isNotEmpty,
    timeout: const Duration(minutes: 3),
    reason: 'the computer to finish first (9.5)',
  );
  await tester.pumpFor(const Duration(milliseconds: 800));
  await tour.visit('race_loss', hidden: ['Pause']);
}

// ── meta: a returning player ─────────────────────────────────────────────

/// Levels 1–60 won, three families home, 300 coins (Ocean's 800 opens "Not
/// enough coins"), rival 1 beaten, today's daily unsolved.
SaveDocument _metaPlayer() => SaveDocument(
  currentLevel: 61,
  highestLevel: 61,
  coins: 300,
  tutorialDone: true,
  seenIntros: const ['towers', 'glass', 'ice'],
  museum: const ['ch01', 'ch02', 'ch03'],
  levelStars: {
    for (var order = 1; order <= 60; order++)
      'L${order.toString().padLeft(4, '0')}': const [3, 2, 3, 1][order % 4],
  },
  records: const SaveRecords(families: 3, dolls: 120, dailies: 4),
  race: const RaceProgress(
    rivals: [
      RivalProgress(unlocked: true, wins: 1, raceNo: 1),
      RivalProgress(unlocked: true),
      RivalProgress(),
    ],
  ),
);

Future<void> _meta(WidgetTester tester, Board board, _Tour tour) async {
  await seedSave(_metaPlayer());
  app.main();
  await _waitHome(tester);
  await tour.visit('home');

  // Daily, its win and the one-time reminder offer.
  await tester.tap(find.text('Daily Puzzle'));
  await tester.pumpUntil(
    () => find.byType(DailyPage).evaluate().isNotEmpty,
    reason: 'the Daily screen',
  );
  await _routeSettled(tester, DailyPage);
  await _artReady(tester, 'the Daily preview');
  await tour.visit('daily');
  await tester.tap(find.text('Play'));
  await tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isNotEmpty &&
        board.game.geometry != null &&
        board.game.skin != null,
    timeout: const Duration(seconds: 30),
    reason: "today's daily with its skin",
  );
  await solveWithHints(tester, board);
  await board.waitForWinOverlay();
  await tester.pumpFor(const Duration(milliseconds: 1500));
  await tour.visit('daily_win', hidden: ['Pause']);
  await tester.tap(find.text('Back to Daily'));
  const offerTitle = 'Want a note when tomorrow’s puzzle is ready?';
  await tester.pumpUntil(
    () => find.text(offerTitle).evaluate().isNotEmpty,
    reason: 'the reminder offer',
  );
  await tester.pumpFor(const Duration(milliseconds: 600));
  await tour.visit('daily_offer', hidden: ['Back']);
  await tester.ensureVisible(find.text('No thanks'));
  await tester.pumpFor(const Duration(milliseconds: 300));
  await tester.tap(find.text('No thanks'));
  await tester.pumpUntil(
    () => find.text(offerTitle).evaluate().isEmpty,
    reason: 'No thanks closes the offer',
  );
  await tester.pumpFor(const Duration(milliseconds: 400));
  await _backFrom(tester, DailyPage);

  // The Museum and a collected family's figurine.
  await _tab(tester, 'Museum', MuseumPage);
  await tour.visit('museum');
  const classic = 'The Classic Family, home in your Museum';
  await tester.tap(find.bySemanticsLabel(classic));
  await tester.pumpUntil(
    () => find.byType(FigurineModal).evaluate().isNotEmpty,
    reason: 'the figurine modal',
  );
  await tester.pumpFor(const Duration(milliseconds: 600));
  await tour.visit('museum_modal', hidden: [classic]);
  await tester.tap(
    find.descendant(
      of: find.byType(FigurineModal),
      matching: find.bySemanticsLabel('Close'),
    ),
  );
  await tester.pumpUntil(
    () => find.byType(FigurineModal).evaluate().isEmpty,
    reason: 'the figurine modal closed',
  );
  await tester.pumpFor(const Duration(milliseconds: 400));

  // The Shop, Ocean's detail, and Ocean's price over the balance.
  await _tab(tester, 'Shop', ShopPage);
  await tester.pumpUntil(
    () => find.byType(SkinGridCard).evaluate().isNotEmpty,
    reason: 'the Skins tab loaded',
  );
  await _artReady(tester, 'the Skins cards');
  await tour.visit('shop');
  await tester.tap(find.text('Ocean'));
  await tester.pumpUntil(
    () => find.byType(SkinDetailPage).evaluate().isNotEmpty,
    reason: "Ocean's detail",
  );
  await _routeSettled(tester, SkinDetailPage);
  await _artReady(tester, "Ocean's detail");
  await tour.visit('shop_detail');
  await _backFrom(tester, SkinDetailPage);
  await tester.tap(
    find.descendant(
      of: find.widgetWithText(SkinGridCard, 'Ocean'),
      matching: find.byType(ShopBuyButton),
    ),
  );
  await tester.pumpUntil(
    () => find.byType(NotEnoughCoinsDialog).evaluate().isNotEmpty,
    reason: 'the Not enough coins dialog',
  );
  await tester.pumpFor(const Duration(milliseconds: 500));
  await tour.visit('not_enough_coins', hidden: [RegExp(r'^Themes\b')]);
  await tester.tap(find.text('Go to Shop'));
  await tester.pumpUntil(
    () => find.byType(NotEnoughCoinsDialog).evaluate().isEmpty,
    reason: 'the dialog closed',
  );
  await tester.pumpFor(const Duration(milliseconds: 400));

  // Settings, its language sheet and Reduce motion.
  await _tab(tester, 'Home', HomePage);
  await tester.tap(find.bySemanticsLabel('Settings'));
  await tester.pumpUntil(
    () => find.byType(SettingsPage).evaluate().isNotEmpty,
    reason: 'Settings',
  );
  await _routeSettled(tester, SettingsPage);
  await tour.visit('settings');
  final language = find.text('Language');
  await Scrollable.ensureVisible(tester.element(language), alignment: 0.5);
  await tester.pumpFor(const Duration(milliseconds: 300));
  await tester.tap(language);
  await tester.pumpUntil(
    () => find.byType(LanguageSheet).evaluate().isNotEmpty,
    reason: 'the language sheet',
  );
  await tester.pumpFor(const Duration(milliseconds: 500));
  await tour.visit('language', hidden: [RegExp(r'^Sound\b')]);
  await tester.tap(find.text('Done'));
  await tester.pumpUntil(
    () => find.byType(LanguageSheet).evaluate().isEmpty,
    reason: 'the sheet closed',
  );
  await tester.pumpFor(const Duration(milliseconds: 400));
  final reduceMotion = find.byType(SettingsSegmentedRow<ReduceMotionMode>);
  await tester.ensureVisible(reduceMotion);
  await tester.pumpFor(const Duration(milliseconds: 400));
  await tour.visit('settings_reduce_motion');
  await tester.tap(find.bySemanticsLabel('Close'));
  await tester.pumpUntil(
    () => find.byType(SettingsPage).evaluate().isEmpty,
    reason: 'back Home',
  );
  await tester.pumpFor(const Duration(milliseconds: 400));

  // Chapters and a won level's card.
  await tester.tap(find.text('Snowy Cabin').first);
  await tester.pumpUntil(
    () => find.byType(ChaptersPage).evaluate().isNotEmpty,
    reason: 'Chapters from the chapter card',
  );
  await _routeSettled(tester, ChaptersPage, settle: 900);
  await tour.visit('chapters');
  final chapters = find
      .descendant(
        of: find.byType(ChaptersPage),
        matching: find.byType(Scrollable),
      )
      .first;
  final chapterOne = find.text('Sunny Toy Shop');
  await tester.scrollUntilVisible(chapterOne, -250, scrollable: chapters);
  await tester.pumpFor(const Duration(milliseconds: 400));
  await tester.tap(chapterOne);
  await tester.pumpFor(const Duration(milliseconds: 900));
  final cellTwo = find.descendant(
    of: find.byType(ChapterLevelCell),
    matching: find.text('2'),
  );
  await tester.scrollUntilVisible(cellTwo, 250, scrollable: chapters);
  await tester.pumpFor(const Duration(milliseconds: 400));
  await tester.tap(cellTwo.first);
  await tester.pumpUntil(
    () => find.byType(LevelCard).evaluate().isNotEmpty,
    reason: 'the level card',
  );
  await tester.pumpFor(const Duration(milliseconds: 500));
  await tour.visit('level_card', hidden: ['Back']);
  await tester.binding.handlePopRoute();
  await tester.pumpUntil(
    () => find.byType(LevelCard).evaluate().isEmpty,
    reason: 'the level card closed',
  );
  await tester.pumpFor(const Duration(milliseconds: 400));
  await _backFrom(tester, ChaptersPage);

  // Records.
  await tester.tap(
    find.descendant(of: find.byType(HomePage), matching: find.text('Records')),
  );
  await tester.pumpUntil(
    () => find.byType(RecordsPage).evaluate().isNotEmpty,
    reason: 'Records',
  );
  await _routeSettled(tester, RecordsPage);
  await tour.visit('records');
}
