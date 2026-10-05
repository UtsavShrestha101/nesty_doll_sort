import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart' show ValueKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/features/dev/level_picker_sheet.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/game/components/board_scene.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/main_dev.dart' as app;
import 'package:nesty_render/nesty_render.dart';

import 'support/board_probe.dart';
import 'support/phone_language.dart';
import 'support/seeded_save.dart';

/// The board's m7-3 layouts on a device (phase 4 lane B; m7-design P4.3;
/// architecture §2 and §7.3; frames 3.1b, 12.13 and the `Nesty Board
/// Presets` scenes): the fit rule and presets, the tall glass case and its
/// unlock, a 3-deep top-shelf tower, an iced tower's tag, two +1 Slots
/// (rows of 5 and 6), the tap feedback, the drag hover and the hint over
/// the middle top stand. Phase 5 adds an invalid move's shake (frame 2.6)
/// and level 57's board (frame 2.11). After Claude Design's m7-4 the same
/// steps show the glass and ice scaling with the stand (5.1), the top-shelf
/// tower's smaller step under `hudClearY` (5.3) and the hint's
/// `hintMiddle.clampTop` (5.4), and a last step opens chapters 7–10's first
/// levels: each chapter's ribbon in its own colours (4.15) and its own
/// shelf wood (`theme.chapters.N.boardArt`, A.5). No bundled or generated
/// level has four shelves, so `fourShelves` (5.2) is host-only
/// (nesty_render's `board_overlays_m74_test`).
///
/// It finds its levels by scanning the bundle (`assets/levels/bundle.json`,
/// decoded with nesty_core's codec), then jumps to each with the dev
/// flavor's level picker, so a re-authored bundle keeps the checks pointed at
/// the right boards. Lines are core's own optimal ones (`Solver.solve`), played
/// by tapping.
///
/// ```sh
/// cd apps/game
/// flutter drive --flavor dev --driver test_driver/integration_test.dart \
///   --target integration_test/board_layouts_test.dart -d <device>
/// ```
///
/// `nesty-test` runs it from a fresh install. Written, and run by the
/// device stage, never by the lane. Screenshots are prefixed `b_`. Not on a
/// device: the haptic of an empty stand's dip and the sounds (the host
/// tests pin the cues), and the exact frames of a 160 ms ping (the checks
/// poll the tween instead).
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'the board layouts of levels 31–200',
    (tester) async {
      pinEnglishPhone(tester);
      // A returning player past Level 20 who has met every level (the
      // picker lists every bundled one whatever the save says).
      await seedSave(const SaveDocument(currentLevel: 71, highestLevel: 200));

      app.main();
      final board = Board(tester);
      final shots = _Shots(binding, tester);
      await tester.pumpUntil(
        () => find.byType(HomePage).evaluate().isNotEmpty,
        timeout: const Duration(seconds: 60),
        reason: 'Home for the seeded save (uninstall the app first)',
      );
      await tester.pumpFor(const Duration(milliseconds: 800));
      final levels = await _Levels.load();
      final flow = _Flow(tester, board, shots, levels);

      await flow.sizeFive();
      await flow.boardMoments();
      await flow.invalidMove();
      await flow.levelFiftySeven();
      await flow.tallPreset();
      await flow.tallCase();
      await flow.towerOnTop();
      await flow.icedTower();
      await flow.twoExtraSlots();
      await flow.emptyStandTap();
      await flow.dragHover();
      await flow.hintOverTheMiddle();
      await flow.themedWood();

      // Merged, never replaced: `takeScreenshot` keeps the shots in
      // `reportData['screenshots']`, and the driver only writes what is
      // still there at the end.
      binding.reportData = {
        ...?binding.reportData,
        'board_layouts': {'platform': Platform.operatingSystem},
      };
      // ignore: avoid_print
      print('NESTY_BOARD_LAYOUTS ${jsonEncode({'ok': true})}');
    },
    timeout: const Timeout(Duration(minutes: 25)),
  );
}

/// The bundle's levels, for choosing boards.
final class _Levels {
  _Levels(this.entries);

  final List<LevelBundleEntry> entries;

  static Future<_Levels> load() async {
    final decoded = LevelBundleCodec.decodeString(
      await rootBundle.loadString('assets/levels/bundle.json'),
    );
    expect(decoded.bundle, isNotNull, reason: '${decoded.issues}');
    return _Levels(decoded.bundle!.levels);
  }

  LevelBundleEntry order(int order) =>
      entries.singleWhere((entry) => entry.order == order);

  /// The first entry (in play order) that [test] accepts.
  LevelBundleEntry first(bool Function(LevelBundleEntry entry) test) {
    for (final entry in entries) {
      if (test(entry)) return entry;
    }
    fail('no bundled level matches');
  }

  /// The picker tile's tier label.
  static String tierLabel(Tier tier) => switch (tier) {
    Tier.easy => 'Easy',
    Tier.medium => 'Medium',
    Tier.hard => 'Hard',
    Tier.superhard => 'Super Hard',
  };

  /// A level's first optimal line: core's `Solver.solve`.
  static List<Move> line(Level level) {
    final result = Solver.solve(GameState.initial(level));
    expect(result.verdict, SolveVerdict.solved, reason: level.id);
    return result.solution!;
  }
}

/// Every slot of [level] with its id.
Iterable<(String, Slot)> _slots(Level level) sync* {
  for (var r = 0; r < level.shelves.length; r++) {
    for (var c = 0; c < level.shelves[r].length; c++) {
      yield (SlotId.grid(r, c), level.shelves[r][c]);
    }
  }
}

int _tallest(Slot slot) {
  var size = 0;
  for (final nest in slot.nests) {
    if (nest.outerSize > size) size = nest.outerSize;
  }
  return size;
}

final class _Flow {
  _Flow(this.tester, this.board, this.shots, this.levels);

  final WidgetTester tester;
  final Board board;
  final _Shots shots;
  final _Levels levels;

  BoardGeometry get geometry => board.game.geometry!;

  SlotState slot(String id) => board.game.board.scene.slot(id)!;

  /// Home's dev level picker, scrolled to the tile (200 levels, grouped by
  /// chapter), then the level with its art and no intro card in the way.
  Future<void> jump(LevelBundleEntry entry) async {
    await _tapPickerTile(entry);
    await _waitForLevel(entry.order);
    await _dismissIntro();
    await board.waitIdle();
    await tester.pumpFor(const Duration(milliseconds: 800));
  }

  /// Level [number] on the board with its art.
  Future<void> _waitForLevel(int number) => tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isNotEmpty &&
        board.bloc.state.data?.levelNumber == number &&
        board.game.geometry != null &&
        board.game.skin != null,
    timeout: const Duration(seconds: 30),
    reason: 'level $number with its skin',
  );

  /// Home's dev level picker: [entry]'s tile, tapped.
  Future<void> _tapPickerTile(LevelBundleEntry entry) async {
    final number = entry.order;
    final picker = find.byType(LevelPickerSheet);
    await tester.tap(find.text('Jump to a level'));
    await tester.pumpUntil(
      () => picker.evaluate().isNotEmpty,
      reason: 'the level picker',
    );
    await tester.pumpFor(const Duration(milliseconds: 500));
    final tile = find.descendant(of: picker, matching: find.text('$number'));
    await tester.ensureVisible(tile);
    await tester.pumpFor(const Duration(milliseconds: 400));
    expect(
      find.bySemanticsLabel('Level $number · ${_Levels.tierLabel(entry.tier)}'),
      findsOneWidget,
      reason: 'level $number is ${entry.tier.id}',
    );
    await tester.tap(tile);
  }

  /// A mechanic this save hasn't met opens on its intro card, which holds
  /// input until dismissed.
  Future<void> _dismissIntro() async {
    for (
      var shown = board.state.intro;
      shown != null;
      shown = board.state.intro
    ) {
      await tester.pumpFor(const Duration(milliseconds: 600));
      await tester.tap(find.text('Got it'));
      await tester.pumpUntil(
        () => board.state.intro != shown,
        reason: 'the ${shown.name} intro card dismissed',
      );
    }
  }

  /// Pause, then Home (the save's current level stays 71).
  Future<void> home() async {
    await board.openPause();
    await board.pauseToHome(level: 71);
  }

  /// Plays [moves] of [line] one by one (tap, tap), stopping once [done]
  /// holds after a move.
  Future<void> play(List<Move> line, {required bool Function() done}) async {
    for (final move in line) {
      await board.move(move.from, move.to);
      await board.waitIdle();
      if (done()) return;
    }
    fail('the line ended before the state was reached');
  }

  // ── B.3: size 5 on three shelves ──

  /// Level 71: size-5 dolls on the usual planks: 133.5 dp, no shrink.
  Future<void> sizeFive() async {
    final entry = levels.order(71);
    expect(entry.level.maxSize, 5);
    await jump(entry);
    expect(geometry.preset, same(ShelfPresets.three));
    expect(geometry.dollHeightScale, 1);
    expect(geometry.maxDollHeight / geometry.scale, closeTo(133.5, 0.1));
    await shots.take('b_l71_size5');
    await home();
  }

  // ── Frames 2.3 to 2.5: a lifted doll, a nesting move, a completed family ──

  /// A plain board (no tutorial scrim, which `playthrough_test`'s own
  /// `03_selection`, `04_nesting` and `05_family_complete` show on level 1):
  /// the first level of the levels 21 to 60 whose optimal line nests before it
  /// completes a family, with more than one family. Shots `b_03_selection`
  /// (a doll lifted, the legal stands glowing, 450 ms in), `b_04_nesting`
  /// (250 ms into the nest, doll_move 0 to 267 then doll_nest) and
  /// `b_05_family_complete` (90 ms after the set lands on the counter, which
  /// is 1250 ms after doll_complete starts).
  Future<void> boardMoments() async {
    for (final entry in levels.entries.where(
      (e) => e.order > 20 && e.order <= 60,
    )) {
      final line = _Levels.line(entry.level);
      var state = GameState.initial(entry.level);
      int? nestAt;
      int? completeAt;
      for (var i = 0; i < line.length && completeAt == null; i++) {
        final result = Rules.tryMove(state, line[i]);
        if (result is! MoveApplied) break;
        state = result.state;
        final completed = result.events.whereType<Completed>();
        if (completed.isNotEmpty && completed.first.totalSets > 1) {
          completeAt = i;
        } else if (nestAt == null &&
            result.events.any((e) => e is NestedInto)) {
          nestAt = i;
        }
      }
      if (nestAt == null || completeAt == null) continue;
      await jump(entry);
      for (var i = 0; i < nestAt; i++) {
        await board.move(line[i].from, line[i].to);
        await board.waitIdle();
      }
      final nest = line[nestAt];
      await board.waitIdle();
      await board.tap(nest.from);
      await tester.pumpUntil(
        () => board.state.selectedSlotId == nest.from,
        reason: '${nest.from} lifted',
      );
      await tester.pumpFor(const Duration(milliseconds: 450));
      await shots.take('b_03_selection');
      Future<void> shotAt(String name, double from, double atMs) async {
        final timeline = board.game.board.timeline!;
        await tester.pumpUntil(
          () => timeline.nowMs >= from + atMs,
          reason: '$name at $atMs ms',
          step: const Duration(milliseconds: 4),
        );
        board.game.pauseEngine();
        try {
          await shots.take(name);
        } finally {
          board.game.resumeEngine();
        }
      }

      final timeline = board.game.board.timeline!;
      var start = timeline.nowMs;
      await board.drop(nest.to);
      await shotAt('b_04_nesting', start, 250);
      await board.waitIdle();
      for (var i = nestAt + 1; i < completeAt; i++) {
        await board.move(line[i].from, line[i].to);
        await board.waitIdle();
      }
      final last = line[completeAt];
      await board.waitIdle();
      await board.tap(last.from);
      await tester.pumpUntil(
        () => board.state.selectedSlotId == last.from,
        reason: '${last.from} lifted',
      );
      await tester.pumpFor(const Duration(milliseconds: 250));
      start = timeline.nowMs;
      await board.drop(last.to);
      // Frame 2.5 is the completion moment: the counter lit 1/n with the
      // sparkle over it and the trail's last particles. The set lands on the
      // counter at doll_complete's start + 1250 ms (TimelinePlans), so find
      // the clip's start, then shoot just after the landing (the old
      // 1,087 ms from the drop came before it: 0/n, no sparkles).
      await tester.pumpUntil(
        () => [
          for (final c in board.game.board.fx.liveClips) c.fx,
        ].contains(FxId.dollComplete),
        reason: 'doll_complete started',
        step: const Duration(milliseconds: 4),
      );
      final completeAtMs = timeline.nowMs;
      await shotAt('b_05_family_complete', completeAtMs, 1250 + 90);
      await board.waitIdle();
      await home();
      return;
    }
    fail('no early level nests before it completes a family');
  }

  // ── Frame 2.6: an invalid move (phase 5, architecture.md §1.3) ──

  /// On level 71 (the file's own seed's level): a lifted nest dropped on a
  /// stand core refuses (the same colour at the wrong size first, else
  /// another colour). The target shakes (`doll_invalid`, 600 ms, tokens
  /// `motion.invalid`); shot about 250 ms in, mid-shake, with the engine
  /// paused while the platform captures it.
  Future<void> invalidMove() async {
    final entry = levels.order(71);
    await jump(entry);
    final state = board.state.board;
    Move? sizeMove;
    Move? colorMove;
    for (final (from, source) in _slots(entry.level)) {
      if (source is! OpenSlot || source.isEmpty || source.isFrozen) continue;
      for (final (to, target) in _slots(entry.level)) {
        if (to == from || target is! OpenSlot) continue;
        if (target.isEmpty || target.isFrozen) continue;
        final result = Rules.tryMove(state, Move(from, to));
        if (result is! MoveRejected) continue;
        if (result.reason == InvalidMoveReason.sizeMismatch) {
          sizeMove ??= Move(from, to);
        } else if (result.reason == InvalidMoveReason.colorMismatch) {
          colorMove ??= Move(from, to);
        }
      }
    }
    final move = sizeMove ?? colorMove;
    expect(move, isNotNull, reason: 'an illegal drop on level 71');
    final before = board.state.board;
    await board.tap(move!.from);
    await tester.pumpUntil(
      () => board.state.selectedSlotId == move.from,
      reason: '${move.from} lifted',
    );
    await tester.pumpFor(const Duration(milliseconds: 250));
    await board.tap(move.to);
    await tester.pumpUntil(
      () => board.state.effect is MoveRejectedEffect,
      reason: 'core refused ${move.from} → ${move.to}',
      step: const Duration(milliseconds: 4),
    );
    final timeline = board.game.board.timeline!;
    final start = timeline.nowMs;
    // Frame 2.6 is the shake mid-animation. A bare doll's target shake is
    // inside the doll_invalid Lottie clip (frames 10.8-25.2 = 180-420 ms,
    // tokens motion.invalid; TimelinePlans._planRejected), not the slot's
    // hand-coded shakeX, which only a case, ice or tower target drives. So
    // catch the clock 260 ms in (a swing's peak) and prove the clip is live
    // and the window still open, then shoot with the engine paused.
    // Frame 2.6's ghost copies (+-7 dp at 30 %) and tick marks are the static
    // frame's way of drawing the shake (NestyBoard.dc.html `invalid`: `shake`
    // ghosts and `marks`); doll_invalid has only mover and target layers, so
    // no shot of the clip carries them (5f-fix2, by design).
    await tester.pumpUntil(
      () => timeline.nowMs >= start + 260,
      reason: 'the shake 260 ms in',
      step: const Duration(milliseconds: 4),
    );
    board.game.pauseEngine();
    try {
      expect(
        timeline.nowMs,
        lessThan(start + 400),
        reason: 'still inside the 180-420 ms shake window',
      );
      expect(
        [for (final c in board.game.board.fx.liveClips) c.fx],
        contains(FxId.dollInvalid),
        reason: 'doll_invalid is playing mid-shake',
      );
      await shots.take('b_invalid_move');
    } finally {
      board.game.resumeEngine();
    }
    await board.waitIdle();
    for (final id in before.slotIds) {
      expect(board.state.board.slot(id), before.slot(id), reason: 'kept: $id');
    }
    expect(board.state.selectedSlotId, isNull, reason: 'the selection clears');
    await home();
  }

  // ── Frame 2.11: level 57's board (phase 5, architecture.md §1.3) ──

  /// Level 57 as the player meets it (its intro card, if any, dismissed).
  Future<void> levelFiftySeven() async {
    await jump(levels.order(57));
    await shots.take('b_l57_board');
    await home();
  }

  // ── B.3: the tall preset ──

  /// Level 130: size 6 takes the tall preset (300 / 494 / 688), the dolls
  /// 94.7 % of 150.
  Future<void> tallPreset() async {
    final entry = levels.order(130);
    expect(entry.level.maxSize, 6);
    await jump(entry);
    expect(geometry.preset, same(ShelfPresets.threeTall));
    for (var r = 0; r < geometry.shelves.length; r++) {
      expect(
        geometry.fit.referenceY(geometry.shelves[r].plankTop),
        closeTo(ShelfPresets.threeTall.plankTops[r], 0.5),
        reason: 'shelf $r on the tall preset (300 / 494 / 688)',
      );
    }
    expect(geometry.dollHeightScale, closeTo(142.1 / 150, 0.002));
    await shots.take('b_l130_tall_preset');
    await home();
  }

  // ── B.4: a sealed size-5 or size-6 doll ──

  /// A level with a sealed size-5 doll: the tall case, then its unlock.
  Future<void> tallCase() async {
    final entry = levels.first(
      (e) =>
          e.tier == Tier.easy &&
          _slots(e.level).any(
            (s) => s.$2 is LockedSlot && _tallest(s.$2) >= 5 && !s.$2.isFrozen,
          ),
    );
    final (id, sealed) = _slots(
      entry.level,
    ).firstWhere((s) => s.$2 is LockedSlot && _tallest(s.$2) >= 5);
    await jump(entry);
    final component = board.game.board.slots[id]!;
    expect(geometry.slot(id).usesTallCase, isTrue, reason: entry.level.id);
    expect(component.glass?.id, FxId.fxGlassUnlockTall);
    expect(geometry.slot(id).lockedDollBaseY, geometry.slot(id).surfaceY);
    await shots.take('b_glass_tall_sealed');

    // Play core's line until the case breaks, and shoot the unlock.
    final line = _Levels.line(entry.level);
    var lines = 0;
    await play(
      line,
      done: () {
        lines++;
        return board.state.board.slot(id) is! LockedSlot;
      },
    );
    expect(sealed, isA<LockedSlot>());
    await tester.pumpFor(const Duration(milliseconds: 150));
    await shots.take('b_glass_tall_unlocking');
    await tester.pumpFor(const Duration(milliseconds: 1500));
    expect(
      component.glass,
      isNull,
      reason: 'the case shattered ($lines moves)',
    );
    await shots.take('b_glass_tall_unlocked');
    await home();
  }

  // ── B.5: a 3-deep tower on the top shelf ──

  /// A top-shelf tower with three buried nests: the stack steps under the
  /// family counter (or draws fewer silhouettes), and the tag says +3.
  Future<void> towerOnTop() async {
    final entry = levels.first(
      (e) => _slots(e.level).any(
        (s) =>
            s.$1.startsWith('r0') &&
            s.$2 is TowerSlot &&
            (s.$2 as TowerSlot).hiddenCount >= 3 &&
            !s.$2.isFrozen,
      ),
    );
    final (id, tower) = _slots(entry.level).firstWhere(
      (s) =>
          s.$1.startsWith('r0') &&
          s.$2 is TowerSlot &&
          (s.$2 as TowerSlot).hiddenCount >= 3,
    );
    await jump(entry);
    final state = slot(id);
    final geometrySlot = geometry.slot(id);
    final tallest = _tallest(tower);
    final stack = geometrySlot.towerStack(tallest, 3);
    expect(state.buriedDrawn, geometrySlot.buriedDrawn(3, topSize: tallest));
    expect(state.decor.tagLabel, '+3', reason: 'the tag keeps the real depth');
    // Every drawn silhouette stays under the family counter's clearance.
    for (var depth = 1; depth <= state.buriedDrawn; depth++) {
      final size = state.view.buried[depth - 1];
      final rect = geometrySlot.buriedSilhouetteRect(
        depth,
        size,
        buried: 3,
        topSize: tallest,
      );
      expect(
        rect.top,
        greaterThanOrEqualTo(geometry.fit.y(150) - 3),
        reason: 'silhouette $depth of $id (step ${stack.step})',
      );
    }
    await shots.take('b_tower_top_shelf');
    await home();
  }

  // ── B.7: an iced tower ──

  /// An iced tower: the "+N" tag is hidden while the ice is on, and pops in
  /// with the shatter.
  Future<void> icedTower() async {
    final entry = levels.first(
      (e) =>
          e.tier != Tier.superhard &&
          _slots(e.level).any(
            (s) =>
                s.$2 is TowerSlot &&
                s.$2.isFrozen &&
                _Levels.line(e.level).length <= 30,
          ),
    );
    final (id, tower) = _slots(
      entry.level,
    ).firstWhere((s) => s.$2 is TowerSlot && s.$2.isFrozen);
    await jump(entry);
    final state = slot(id);
    expect(state.decor.hasTag, isFalse, reason: 'hidden while iced');
    expect(state.decor.hasBadge, isTrue, reason: 'the ice counter shows');
    await shots.take('b_iced_tower_tag_hidden');

    // Play core's line until the ice shatters: the tag is on, popping in.
    await play(
      _Levels.line(entry.level),
      done: () => !board.state.board.slot(id).isFrozen,
    );
    final popped = await _pollUntil(
      () => state.tagPop != null || state.decor.hasTag,
    );
    expect(popped, isTrue, reason: '$id popped its tag');
    expect(state.decor.hasTag, isTrue);
    // Nothing can leave an iced tower, so it still holds what it started
    // with: the tag's real depth.
    expect(
      state.decor.tagLabel,
      '+${(tower as TowerSlot).hiddenCount}',
      reason: 'the count core says',
    );
    await shots.take('b_iced_tower_tag_pop');
    await tester.pumpFor(const Duration(milliseconds: 600));
    expect(state.tagPop, isNull);
    await shots.take('b_iced_tower_thawed');
    await home();
  }

  // ── B.6, D172: two +1 Slots on a 4-slot bottom shelf ──

  /// The bottom shelf of 4 becomes a row of 5 (pitch 74.4, stands at 0.8)
  /// and then of 6 (pitch 62), the dolls re-fitting each time (280 ms),
  /// the pad popping after.
  Future<void> twoExtraSlots() async {
    final entry = levels.first(
      (e) => e.level.shelves.last.length == 4 && e.level.maxSize <= 4,
    );
    await jump(entry);
    final before = board.game.geometry!;
    expect(before.shelves.last.slots, hasLength(4));
    for (final (extras, slots, pitch, scale) in [
      (1, 5, 74.4, 0.8),
      (2, 6, 62.0, 59.6 / 90),
    ]) {
      await tester.tap(find.text('+Slot'));
      await tester.pumpUntil(
        () => board.state.board.extraSlotCount == extras,
        reason: 'extra slot $extras',
      );
      // The row re-pitches over 280 ms, then the pad pulses.
      await tester.pumpFor(const Duration(milliseconds: 500));
      await board.waitIdle();
      final bottom = geometry.shelves.last;
      expect(bottom.slots, hasLength(slots));
      expect(bottom.pitch / geometry.scale, closeTo(pitch, 0.05));
      expect(bottom.pieceScale, closeTo(scale, 0.002));
      expect(bottom.slots.last.kind, SlotShapeKind.extra);
      expect(geometry.dollHeightScale, lessThanOrEqualTo(1));
      expect(
        slot('x${extras - 1}').pulses,
        1,
        reason: 'ui_extra_slot pulses on the new pad',
      );
      await tester.pumpFor(const Duration(milliseconds: 500));
      await shots.take('b_extra_slot_row_$slots');
    }
    await home();
  }

  // ── E.13: a tap on an empty stand ──

  /// A tap on an empty stand: a 2 dp dip, never the invalid shake.
  Future<void> emptyStandTap() async {
    // Past the tutorial levels, whose overlay holds input.
    final entry = levels.first(
      (e) =>
          e.order > 20 &&
          _slots(
            e.level,
          ).any((s) => s.$2 is OpenSlot && s.$2.isEmpty && !s.$2.isFrozen),
    );
    final (id, _) = _slots(
      entry.level,
    ).firstWhere((s) => s.$2 is OpenSlot && s.$2.isEmpty && !s.$2.isFrozen);
    await jump(entry);
    await board.tap(id);
    await tester.pumpUntil(
      () => board.state.effect is SlotNudgeEffect,
      reason: 'the nudge of a tap on empty $id',
      step: const Duration(milliseconds: 4),
    );
    final effect = board.state.effect! as SlotNudgeEffect;
    expect(effect.slotId, id);
    expect(board.state.selectedSlotId, isNull);
    // The dip is 80 ms: poll for its tween, then it is gone again.
    final dipped = await _pollUntil(() => slot(id).nudge != null);
    expect(dipped, isTrue, reason: 'the stand dips');
    await tester.pumpFor(const Duration(milliseconds: 300));
    expect(slot(id).nudge, isNull);
    expect(board.state.status, GameplayStatus.playing);
    await shots.take('b_empty_stand_tap');
    await home();
  }

  // ── E.14: the drag hover ──

  /// A dragged doll over a legal stand: the stand glows (`fx_select_glow`
  /// at 60 %); over an illegal one, nothing.
  Future<void> dragHover() async {
    final entry = levels.order(21);
    await jump(entry);
    final first = _Levels.line(entry.level).first;
    final start = board.centreOf(first.from);
    final gesture = await tester.startGesture(start);
    await tester.pump(const Duration(milliseconds: 100));
    // Past the touch slop, so the drag starts and lifts the doll.
    await gesture.moveBy(const Offset(0, -30));
    await tester.pumpUntil(
      () => board.state.selectedSlotId == first.from,
      reason: '${first.from} lifted by the drag',
    );
    final legal = board.state.dropTargets;
    expect(legal, contains(first.to));
    // Over the legal stand: it glows.
    await _dragTo(gesture, start, board.centreOf(first.to));
    expect(
      await _pollUntil(
        () => board.game.board.timeline!.hoverSlotId == first.to,
      ),
      isTrue,
      reason: '${first.to} glows under the finger',
    );
    await tester.pumpFor(const Duration(milliseconds: 300));
    await shots.take('b_drag_hover_legal');

    // Over an illegal one (a slot core does not list): nothing.
    final illegal = geometry.slots
        .map((s) => s.id)
        .firstWhere((id) => id != first.from && !legal.contains(id));
    await _dragTo(gesture, board.centreOf(first.to), board.centreOf(illegal));
    expect(
      await _pollUntil(() => board.game.board.timeline!.hoverSlotId == null),
      isTrue,
      reason: '$illegal takes no glow',
    );
    await shots.take('b_drag_hover_illegal');

    // Released over nothing: the doll goes back, the glow is gone.
    await _dragTo(gesture, board.centreOf(illegal), const Offset(2, 300));
    await gesture.up();
    await board.waitIdle();
    expect(board.game.board.timeline!.hoverSlotId, isNull);
    expect(board.state.selectedSlotId, isNull);
    await home();
  }

  Future<void> _dragTo(TestGesture gesture, Offset from, Offset to) async {
    const steps = 10;
    for (var i = 1; i <= steps; i++) {
      await gesture.moveTo(Offset.lerp(from, to, i / steps)!);
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  // ── E.20, frame 3.1b: the hint over the middle top stand ──

  /// A hint whose source is the middle stand of a 3-slot top shelf: the
  /// arrow rises into the family counter's place and the counter yields.
  Future<void> hintOverTheMiddle() async {
    final entry = levels.first((e) {
      final level = e.level;
      if (level.shelves.length != 3 || level.shelves.first.length != 3) {
        return false;
      }
      final hint = Solver.hint(GameState.initial(level));
      return hint.move?.from == 'r0c1';
    });
    await jump(entry);
    await tester.tap(find.text('Hint'));
    await tester.pumpUntil(
      () => board.state.hint != null,
      timeout: const Duration(seconds: 10),
      reason: 'the hint',
    );
    expect(board.state.hint!.from, 'r0c1');
    final middle = geometry.slot('r0c1');
    final size = slot('r0c1').view.outerSize;
    // Frame 3.1b's case needs the iPhone's 54 dp status bar: where the top
    // inset is shorter (the Android emulator at 390×844), the top shelf sits
    // higher under a lower HUD and the arrow clears the counter, which then
    // stays (the host tests cover both branches of hintNeedsCounter).
    if (!middle.hintNeedsCounter(size)) {
      await tester.pumpFor(const Duration(milliseconds: 500));
      expect(
        board.game.familyCounterYield.value,
        isFalse,
        reason: 'the arrow clears the counter, which stays',
      );
      await shots.take('b_hint_counter_yields');
      await home();
      return;
    }
    expect(
      await _pollUntil(() => board.game.familyCounterYield.value),
      isTrue,
      reason: 'the counter yields to the arrow',
    );
    await tester.pumpFor(const Duration(milliseconds: 500));
    await shots.take('b_hint_counter_yields');

    // Any tap clears the hint: the counter comes back.
    await board.tap('r0c1');
    await tester.pumpUntil(
      () => board.state.hint == null,
      reason: 'the hint cleared',
    );
    expect(
      await _pollUntil(() => !board.game.familyCounterYield.value),
      isTrue,
      reason: 'the counter returns',
    );
    await tester.pumpFor(const Duration(milliseconds: 400));
    await shots.take('b_hint_counter_back');
    await home();
  }

  // ── m7-4 A.5 and 4.15: chapters 7–10's wood and ribbons ──

  /// The first level of each of chapters 7–10 (levels 121, 141, 161, 181):
  /// the chapter's ribbon (`ui_chapter_ribbon`, one line, its named fills
  /// in the chapter's palette with `ribbonTail` and `ribbonFold`) over the
  /// board as it opens, then the board on the chapter's own stand, tower
  /// base and plank (`board/chNN/`), loaded once per theme. The save picks
  /// no theme, so each board wears its chapter's.
  Future<void> themedWood() async {
    final ribbon = find.byKey(const ValueKey('chapterRibbon'));
    for (var chapter = 7; chapter <= 10; chapter++) {
      final id = 'ch${chapter.toString().padLeft(2, '0')}';
      final entry = levels.order((chapter - 1) * 20 + 1);
      expect(entry.chapterId, id);
      final theme = ChapterThemeTokens.chapters.singleWhere((t) => t.id == id);
      expect(theme.boardArtDir, 'board/$id/', reason: '$id has its own wood');
      await _tapPickerTile(entry);
      // The ribbon starts with the level (2.6 s), whatever the art's state.
      await tester.pumpUntil(
        () => ribbon.evaluate().isNotEmpty,
        timeout: const Duration(seconds: 30),
        reason: "chapter $chapter's ribbon",
        step: const Duration(milliseconds: 16),
      );
      await tester.pumpFor(const Duration(milliseconds: 700));
      await shots.take('b_${id}_ribbon');
      await _waitForLevel(entry.order);
      await tester.pumpUntil(
        () => ribbon.evaluate().isEmpty,
        timeout: const Duration(seconds: 10),
        reason: "chapter $chapter's ribbon gone",
      );
      await _dismissIntro();
      await board.waitIdle();
      await tester.pumpFor(const Duration(milliseconds: 400));
      expect(board.state.entry.chapterId, id);
      await shots.take('b_${id}_board');
      await home();
    }
  }

  /// Pumps frames until [condition] holds (a tween that lasts a few
  /// frames), up to 2 s.
  Future<bool> _pollUntil(bool Function() condition) async {
    final end = DateTime.now().add(const Duration(seconds: 2));
    while (!condition()) {
      if (DateTime.now().isAfter(end)) return false;
      await tester.pump(const Duration(milliseconds: 4));
    }
    return true;
  }
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
