part of 'race_cubit.dart';

/// Where a race stands (spec-prop §7.7; docs/plans/m7-design.md P2.5).
enum RacePhase {
  /// Before the player's board has loaded: at the start, and after Rematch
  /// or New race until the page reports the new board.
  waiting,

  /// Both boards at rest, the Start button up (vs-computer rule 4: "The
  /// race starts when the player taps Start, with no countdown").
  ready,

  /// The rival steps on the frame clock; the player's board takes input.
  running,

  /// A side completed every family: [RaceState.result] says which.
  finished,
}

/// What the rival strip says the rival is doing (vs-computer rules 6, 7;
/// frame 9.3).
enum RivalActivity {
  /// At rest: before Start.
  idle,

  /// Between moves (the strip's static "Thinking…").
  thinking,

  /// Its run couldn't be won and it went back to the start ("Starting
  /// over"): for the interval that restart takes (the default of an owner
  /// question, m7-design P2.14).
  startingOver,

  /// It completed every family.
  finished,
}

/// Who completed every family first (spec-prop §7.7 "Result").
enum RaceResult {
  /// The player: a win pays the rival's `race_reward_n` (frame 9.4).
  playerWon,

  /// The computer: costs nothing, takes nothing (frame 9.5).
  rivalWon,
}

/// What stops the rival's clock (spec-prop §7.7 "Pause: pausing, a sheet
/// or the app going to the background stops the rival too"). Holds stack:
/// the clock runs only with none.
enum RaceHold {
  /// The Pause dialog, and Settings opened over it.
  pause,

  /// Any sheet or overlay over the board: the out-of-moves sheet, a popup.
  overlay,

  /// The app is not in the foreground (`AppLifecycleState` other than
  /// `resumed`).
  app,
}

/// The race beside the player's board (spec-prop §7.7; m7-design P2.5):
/// the rival's side, the clock's state and the result. The player's own
/// board is the `GameplayBloc`'s.
@freezed
abstract class RaceState with _$RaceState {
  const factory RaceState({
    /// The race being played (the rival and its raceNo).
    required RacePlay request,

    @Default(RacePhase.waiting) RacePhase phase,

    /// A [RaceHold] is on: the rival's clock is stopped.
    @Default(false) bool held,

    /// Families on the board (both sides have the same board).
    @Default(0) int totalSets,

    /// Families the rival has completed in its current run (0 again after
    /// a restart).
    @Default(0) int rivalSets,

    @Default(RivalActivity.idle) RivalActivity activity,

    /// The rival's moves in this race, all runs together: bumped once per
    /// rival move, so the strip can play its short "moved" beat (never per
    /// frame).
    @Default(0) int rivalMoves,

    /// How many times the rival started over in this race.
    @Default(0) int rivalRestarts,

    /// The rival's board, from its mirrored `GameSession` (a mini board, if
    /// Claude Design's frame 9.3 asks for one; tests). Null before the
    /// board loads.
    GameState? rivalBoard,

    /// Once [phase] is [RacePhase.finished]: who won.
    RaceResult? result,

    /// Once the player won: what `SaveService.recordRaceWin` did (the
    /// coins, the rival unlocked, the new badges), written exactly once.
    RaceWinOutcome? outcome,
  }) = _RaceState;

  const RaceState._();

  /// The rival, 1–3.
  int get rival => request.rival;

  /// The rival's clock is running: the race runs and nothing holds it.
  bool get clockRunning => phase == RacePhase.running && !held;
}
