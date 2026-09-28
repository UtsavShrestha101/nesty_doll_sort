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
  /// hold the level just won; "Play Bonus Level N" sends a
  /// `GameplayStarted` of [GameplayState.nextRequest] (m3-design §7.4).
  allLevelsDone,
}

/// A booster pressed with none left: the purchase popup (frames 3.2, 3.3,
/// and +1 Slot's; docs/plans/m3-design.md §7.3). Board input and the
/// boosters are locked while it is up. Affordable when `GameplayState.coins
/// >= price`.
@freezed
abstract class BoosterOffer with _$BoosterOffer {
  const factory BoosterOffer({
    required BoosterType type,

    /// `price_undo`, `price_hint` or `price_slot` (spec §7.3, §9.4).
    required int price,
  }) = _BoosterOffer;
}

/// How a tutorial step is shown (frames 1.3, 1.4, 1.6).
enum TutorialCueKind {
  /// The hand taps [TutorialCue.from] (1.3).
  tapSource,

  /// [TutorialCue.from] is lifted; the hand taps [TutorialCue.to] (1.4).
  tapTarget,

  /// The hand drags [TutorialCue.from] onto [TutorialCue.to] (1.6).
  drag,
}

/// The scripted tutorial move on screen (spec §7.6; m3-design §10.4): the
/// scrim's holes, the dotted arc, the tooltip and the hand. The bloc accepts
/// only this move (by tap or drag) until it is made; legality still comes
/// from core.
@freezed
abstract class TutorialCue with _$TutorialCue {
  const factory TutorialCue({
    /// 1–4: L1 tap the small doll, L1 tap the big one, L1 finish the family
    /// (no frame: `TODO(design)`), L2 the swallow. The tooltip copy and
    /// `tutorial_step{step}` follow it.
    required int step,
    required TutorialCueKind kind,

    /// The scripted move.
    required String from,
    required String to,
  }) = _TutorialCue;
}

/// Everything the gameplay page, HUD and board render (m2-lottie-design §11,
/// docs/plans/m3-design.md §6.4).
@freezed
abstract class GameplayState with _$GameplayState {
  const factory GameplayState({
    /// What is being played and how it pays (m3-design §6.2).
    required PlayEntry play,

    /// The level and its play metadata (order, chapter, tier, reward): the
    /// bundle entry of a campaign level, or a stand-in for a generated one
    /// (order `levelCount + n` for Bonus Level n, the date for the daily;
    /// its theme as the chapter). The M2 widgets read it; new code reads
    /// [play].
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

    /// Undo does something: a move to undo, free (or [unlimitedBoosters]),
    /// from the inventory, or via the coin offer (frame 3.2, m3-design
    /// §7.3). False only when there is nothing to undo.
    @Default(false) bool canUndo,

    /// +1 Slot does something: fewer than 2 added to this level, free (or
    /// [unlimitedBoosters]), from the inventory, or via the coin offer.
    /// False only when the level's own limit is reached.
    @Default(false) bool canAddSlot,

    /// Hint does something: free (or [unlimitedBoosters]), from the
    /// inventory, or via the coin offer (frame 3.3, m3-design §7.3).
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

    /// The purchase popup (frames 3.2, 3.3; m3-design §7.3).
    BoosterOffer? offer,

    /// The coin prices a booster shows and costs once its free uses or the
    /// inventory are gone (Remote Config `price_undo`, `price_hint`,
    /// `price_slot`; frames 3.2, 3.3, 3.5 badges and rows; m3-design §7.3).
    @Default(0) int undoPrice,
    @Default(0) int hintPrice,
    @Default(0) int slotPrice,

    /// The tutorial step on screen (frames 1.3, 1.4, 1.6; m3-design §10.4).
    TutorialCue? tutorial,

    /// The intro card on screen (frames 4.1–4.3; m3-design §10.4). Input
    /// is locked under it until `IntroDismissed`.
    IntroMechanic? intro,

    /// Once won: the chapter this win completed and collected (frame 4.6).
    String? completedChapterId,

    /// Once won: the `reward_chapter` coins it paid (4.6 "+150 coins").
    @Default(0) int chapterReward,

    /// Once a daily is won: the streak after the solve (frame 5.4).
    int? dailyStreak,

    /// Once won: what Continue plays (`LevelResolver.next`). The page
    /// prefetches its art; a bonus request after a campaign level shows All
    /// Levels Done first (frame 4.9); null after a daily ("Back to Daily").
    PlayRequest? nextRequest,

    /// The board came back from the in-progress save (m3-design §3.4).
    @Default(false) bool restored,
  }) = _GameplayState;

  const GameplayState._();

  /// 1-based global play order (spec §7.1).
  int get levelNumber => entry.order;

  /// The family counter "setsCompleted / totalSets" (frame 2.2).
  int get setsCompleted => board.completedSets;

  int get totalSets => entry.level.totalSets;

  /// Board input (taps, drags) is accepted: not paused, no popup or intro
  /// card up, and in play.
  bool get acceptsInput =>
      !paused &&
      offer == null &&
      intro == null &&
      (status == GameplayStatus.playing || status == GameplayStatus.outOfMoves);
}
