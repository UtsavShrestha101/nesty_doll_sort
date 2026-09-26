import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/game/timeline/fx_clip.dart';
import 'package:nesty_game/features/gameplay/game/timeline/fx_command.dart';

/// Everything the board timeline planned for one [BoardEffect]: the
/// commands and cues in time order, the slots it reserves and for how long
/// (docs/plans/m2-lottie-design.md §7). All times are real ms from the
/// batch's start (at the motion speed it was planned with); [startMs] is
/// the timeline time it started at.
///
/// `BoardTimeline.schedule` returns it; the timeline then executes it over
/// `advance`. The board may look ahead in it (for example to ensure the
/// glass-case frames a `PlaySlotFx` will need); tests assert on it.
final class TimelineBatch {
  TimelineBatch({
    required this.id,
    required this.effect,
    required this.startMs,
    required List<FxCommand> commands,
    required List<FxCue> cues,
    required Map<String, double> reservations,
    required this.endMs,
    this.globalLockMs = 0,
    this.locksInput = false,
  }) : commands = List.unmodifiable(commands),
       cues = List.unmodifiable(cues),
       reservations = Map.unmodifiable(reservations);

  final int id;
  final BoardEffect effect;

  /// Timeline time the batch started at.
  final double startMs;

  /// In execution order (by time, then as planned).
  final List<FxCommand> commands;

  /// In time order.
  final List<FxCue> cues;

  /// Slot → how long it is reserved, from the batch start.
  final Map<String, double> reservations;

  /// When the batch is done, from its start: its last command or clip end,
  /// including the HUD's counter bump after a landing. The sparkle trail's
  /// last particles may fade after it (they don't hold `onWon`).
  final double endMs;

  /// How long every slot is locked from the batch start (the +1 Slot
  /// re-pitch), 0 for none.
  final double globalLockMs;

  /// True when the batch locks input until the next board reset (Won).
  final bool locksInput;

  /// The commands of type [T], in order.
  Iterable<T> commandsOf<T extends FxCommand>() => commands.whereType<T>();

  /// Every clip the batch starts, in start order.
  Iterable<FxClip> get clips => commandsOf<StartClip>().map((c) => c.clip);

  @override
  String toString() =>
      'TimelineBatch#$id(${effect.runtimeType}, ${commands.length} commands, '
      '${cues.length} cues, end ${endMs.toStringAsFixed(1)})';
}
