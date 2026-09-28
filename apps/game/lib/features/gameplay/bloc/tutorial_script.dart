import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';

/// L0001 and L0002's scripted tutorial (spec §7.6; docs/plans/m3-design.md
/// §10.4): pure functions from the board (and whether the tutorial is
/// already done) to the cue that belongs on screen, if any.
///
/// The bloc is the only caller: it gates input to the cue's own move while
/// one is active, and logs `tutorial_step` when a step completes. Legality
/// is always `Rules.tryMove`'s call, never this file's (CLAUDE.md rule 2):
/// [cueFor] itself checks that the proposed move is legal on the exact
/// board it is asked about, so a script that turns out illegal (a level
/// edited under it, a corrupted resume) just ends instead of freezing the
/// board forever.
///
/// The step number is derived from `GameState.moveCount` (and, within a
/// step, from the current selection), so resuming a saved board picks the
/// script back up at the right place (m3-design §3.4, §10.4).
abstract final class TutorialScript {
  /// L1: `tools/levels/authored/L0001.json`.
  static const String level1Id = 'L0001';

  /// L2: `tools/levels/authored/L0002.json`.
  static const String level2Id = 'L0002';

  /// The first family's small doll, then the big one it nests into (frames
  /// 1.3, 1.4).
  static const String _l1From = 'r0c2';
  static const String _l1To = 'r0c0';

  /// The second family: no frame (`TODO(design)`), the smallest doll into
  /// the family already built at [_l1To].
  static const String _l1SecondFrom = 'r1c1';
  static const String _l1SecondTo = 'r0c0';

  /// The swallow demo (frame 1.6): a big doll dropped on the next size
  /// down.
  static const String _l2From = 'r0c0';
  static const String _l2To = 'r1c0';

  /// The cue for a board of level [levelId] at [board]'s move count, with
  /// [selectedSlotId] the lifted nest (if any); null once [tutorialDone],
  /// for any other level, past the scripted moves, or when the candidate
  /// move isn't legal on [board] (rule 3).
  static TutorialCue? cueFor({
    required String levelId,
    required bool tutorialDone,
    required GameState board,
    required String? selectedSlotId,
  }) {
    if (tutorialDone) return null;
    final candidate = _candidate(levelId, board.moveCount, selectedSlotId);
    if (candidate == null) return null;
    final move = Move(candidate.from, candidate.to);
    return Rules.tryMove(board, move) is MoveApplied ? candidate : null;
  }

  static TutorialCue? _candidate(
    String levelId,
    int moveCount,
    String? selectedSlotId,
  ) {
    if (levelId == level1Id) {
      return switch (moveCount) {
        0 =>
          selectedSlotId == _l1From
              ? const TutorialCue(
                  step: 2,
                  kind: TutorialCueKind.tapTarget,
                  from: _l1From,
                  to: _l1To,
                )
              : const TutorialCue(
                  step: 1,
                  kind: TutorialCueKind.tapSource,
                  from: _l1From,
                  to: _l1To,
                ),
        1 => TutorialCue(
          step: 3,
          kind: selectedSlotId == _l1SecondFrom
              ? TutorialCueKind.tapTarget
              : TutorialCueKind.tapSource,
          from: _l1SecondFrom,
          to: _l1SecondTo,
        ),
        _ => null,
      };
    }
    if (levelId == level2Id) {
      return moveCount == 0
          ? const TutorialCue(
              step: 4,
              kind: TutorialCueKind.drag,
              from: _l2From,
              to: _l2To,
            )
          : null;
    }
    return null;
  }
}
