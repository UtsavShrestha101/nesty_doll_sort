part of 'gameplay_bloc.dart';

/// Where the level stands (spec §2.3).
enum GameplayStatus {
  playing,

  /// Every doll is in a completed set. Input is locked; the win overlay
  /// opens when the board's timeline reports the winning batch done.
  won,

  /// Not won and no legal move: the Out-of-Moves sheet (frame 3.5) opens
  /// when the board is idle. Undo, +1 Slot and Restart still work.
  outOfMoves,

  /// Continue was pressed on the last level of the bundle: All Levels Done
  /// (frame 4.9). [GameplayState.entry] and [GameplayState.board] still
  /// hold the level just won. Bonus Endless is M3 (spec §7.1).
  allLevelsDone,
}

/// Everything the gameplay page, HUD and board render (m2-lottie-design §11).
@freezed
abstract class GameplayState with _$GameplayState {
  const factory GameplayState({
    /// The level and its play metadata (order, chapter, tier, reward).
    required LevelBundleEntry entry,

    /// The board after the last transition: nesty_core's truth.
    required GameState board,

    /// The lifted nest's slot, if any.
    String? selectedSlotId,
    @Default(GameplayStatus.playing) GameplayStatus status,
    @Default(false) bool paused,

    /// Frame 3.4's banner and the glowing Undo: the solver proved the board
    /// unsolvable. Cleared by the next board change.
    @Default(false) bool softStuck,

    /// The hint on screen (frame 3.1), cleared by any tap and any board
    /// reset.
    Move? hint,

    /// Undos left before undo costs coins (`SaveService.freeUndosPerLevel`,
    /// Remote Config `free_undos_per_level`, spec §7.3). Per level: a
    /// restart keeps the count (D22, `GameSession.undosUsed`).
    @Default(0) int freeUndosLeft,

    /// Hint boosters in the inventory (spec §8), for the booster badge.
    @Default(0) int hintsLeft,

    /// Extra-slot boosters in the inventory (spec §8), for the booster
    /// badge. The level's own limit of 2 is in [canAddSlot].
    @Default(0) int extraSlotsLeft,

    /// Undo is usable: a move to undo and a free undo left (or
    /// [unlimitedBoosters]). The coin path is M3 (frame 3.2).
    @Default(false) bool canUndo,

    /// +1 Slot is usable: fewer than 2 added to this level and a booster in
    /// the inventory (or free in this build).
    @Default(false) bool canAddSlot,

    /// Hint is usable: a booster in the inventory (or
    /// [unlimitedBoosters]). The coin path is M3 (frame 3.3).
    @Default(false) bool canHint,

    /// The dev flavor (`SaveService.unlimitedBoosters`): boosters never run
    /// out, so the badges may show no count.
    @Default(false) bool unlimitedBoosters,

    /// The player's coins (the HUD coin pill, spec §7.3).
    @Default(0) int coins,

    /// Coins the win paid (the win overlay's "+N"); 0 until [status] is
    /// [GameplayStatus.won].
    @Default(0) int winReward,

    /// Bumped by every board change: an applied move, undo, restart, +1
    /// Slot and a new level. Solver results asked for an older value are
    /// stale.
    @Default(0) int moveSeq,

    /// Bumped with every new [effect].
    @Default(0) int effectSeq,

    /// What the board must play for the latest transition.
    BoardEffect? effect,
  }) = _GameplayState;

  const GameplayState._();

  /// 1-based global play order (spec §7.1).
  int get levelNumber => entry.order;

  /// The family counter "setsCompleted / totalSets" (frame 2.2).
  int get setsCompleted => board.completedSets;

  int get totalSets => entry.level.totalSets;

  /// Board input (taps, drags) is accepted.
  bool get acceptsInput =>
      !paused &&
      (status == GameplayStatus.playing || status == GameplayStatus.outOfMoves);
}
