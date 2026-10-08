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
    /// (the frame 1.4 look, copy.md `tut_step_3_*`), L2 the swallow. The tooltip copy and
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

    /// While a nest is lifted ([selectedSlotId]): the slots core would accept
    /// it on (`Rules.legalTargets`, computed once on the pick; empty
    /// otherwise). The board glows a legal target under a drag with it
    /// (frame 12.13, E.14; phase 4 architecture §2.6); it never decides a
    /// move (rule 2).
    @Default(<String>{}) Set<String> dropTargets,
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

    /// Relaxed mode is on (E6, spec-prop §8; docs/plans/m7-design.md §10),
    /// read live from Settings (`DatabaseService.relaxedModeChanges`): undo
    /// is free and unlimited, the Undo badge shows "∞", and no price, popup
    /// or ad row shows for it. Hint and +1 Slot are unchanged.
    @Default(false) bool relaxed,

    /// A race's board takes the player's input (vs Computer, spec-prop
    /// §7.7; m7-design P2.6): set by [RaceGateChanged], true only while the
    /// race runs (after Start, before a result). Always false outside a
    /// race, where it is never read.
    @Default(false) bool raceLive,

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

    /// Once a daily is won: the solve relit a paused streak
    /// (`DailyProgress.relitOn`; m7-design §8): the win card's streak line
    /// says so.
    @Default(false) bool dailyRelit,

    /// Once a past day is won: it had already been played (the archive held
    /// its date), so the win card says "again" and not "new"
    /// (`past_daily_complete.again`). False otherwise.
    @Default(false) bool pastDailyAgain,

    /// Once won: the moves the win took (`GameState.moveCount`), for the
    /// win card's "Moves 18 · Best 16" or "Moves 18" (m7-design §11). Null
    /// before the win.
    int? winMoves,

    /// Once won: the level's best moves after this win
    /// (`LevelWinOutcome.bestMoves`), for a campaign level or a replay; null
    /// for boards that keep no best (bonus, daily, race), whose card shows
    /// the moves only.
    int? bestMoves,

    /// Once won: the best before this win (`LevelWinOutcome.previousBest`),
    /// null for a first win of the level.
    int? previousBest,

    /// Once won: the levels left to the next milestone chest when it is
    /// nearer than the figurine (`MilestoneChest.levelsToNext`): the win
    /// card shows its countdown instead of the figurine bar (m7-design §9).
    /// Null for a replay, a daily, or when the figurine is nearer.
    int? chestLevelsLeft,

    /// Once won: the milestone chest this win opened and paid
    /// (`LevelWinOutcome.chestPaid`): Continue opens its modal before
    /// Chapter complete and the next level (m7-design §9). The modal only
    /// shows it: the coins and hints are already in the save.
    ChestGrant? chest,

    /// Once won: the badges this win earned, in `BadgeId` order
    /// (`LevelWinOutcome.newBadges`): one toast each (m7-design §12).
    @Default(<BadgeId>[]) List<BadgeId> newBadges,

    /// Once won: the player's first win ever (E9; m7-design §13): Continue
    /// goes to Home instead of the next level.
    @Default(false) bool firstWin,

    /// Once won: this win's stars, 1–3 (`StarRating.starsForWin`; spec-prop
    /// §7.10, m7-design P3.6); null for the daily, Bonus Endless, a race,
    /// or an entry without a par. Nothing about stars shows during play.
    int? stars,

    /// Once won: the level's best stars before this win
    /// (`LevelWinOutcome.previousStars`); null when it had none.
    int? previousStars,

    /// Once won: the 3-star threshold (`StarRules.targetFor`) for the replay
    /// card's "3 stars at N moves or fewer": only on a replay below 3 stars
    /// whose moves were over it (Q118); null otherwise.
    int? starTarget,

    /// Once won: the one-time star tip may show
    /// (`LevelWinOutcome.showStarTip`: never shown, below 3 stars, not
    /// capped; Q119). The card shows it when it has room and then calls
    /// `SaveService.markStarTipShown` (phase 4 architecture §3.6).
    @Default(false) bool starTip,

    /// Once won: a hint or an extra slot capped [stars] (the uncapped rule
    /// would have given 3; spec-prop §7.10): the card's helper note "Wins
    /// with a hint or an extra slot earn up to 2 stars." (Q145).
    @Default(false) bool starsCapped,

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

  /// A replay from Chapters (m7-design §6): no coins, chest or figurine,
  /// no tutorial or intro card, and Continue goes back to Chapters.
  bool get isReplay => play.request.isReplay;

  /// A past day's daily (local habits 3, §7.5c): no coin pill, the date
  /// pill, the past-day win card, nothing paid, no streak move, no coin
  /// purchase of a booster.
  bool get isPastDaily => play.request is PastDailyPlay;

  /// The date of a past day's board, or null for any other board.
  LocalDate? get pastDate => switch (play.request) {
    PastDailyPlay(:final yyyymmdd) => LocalDate.fromYyyymmdd(yyyymmdd),
    _ => null,
  };

  /// A vs Computer race (m7-design P2.6): the bloc's race mode (undo free,
  /// Hint and +1 Slot off, no level record), input gated by [raceLive].
  bool get isRace => play.request.isRace;

  /// Once won: a replay raised the level's best stars (the card's "New
  /// best!", m7-design P3.7). Never on a level's first win.
  bool get starsNewBest =>
      isReplay &&
      stars != null &&
      previousStars != null &&
      stars! > previousStars!;

  /// The family counter "setsCompleted / totalSets" (frame 2.2).
  int get setsCompleted => board.completedSets;

  int get totalSets => entry.level.totalSets;

  /// Board input (taps, drags) is accepted: not paused, no popup or intro
  /// card up, in play, and in a race only while it runs ([raceLive]).
  bool get acceptsInput =>
      !paused &&
      offer == null &&
      intro == null &&
      (!isRace || raceLive) &&
      (status == GameplayStatus.playing || status == GameplayStatus.outOfMoves);
}
