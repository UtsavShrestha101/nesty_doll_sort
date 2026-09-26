/// The board timeline (docs/plans/m2-lottie-design.md §7–§10, §13): pure
/// Dart planning of every board animation, cue and input reservation. The
/// Flame board executes its [FxCommand]s.
library;

export 'package:nesty_game/features/gameplay/game/timeline/board_timeline.dart';
export 'package:nesty_game/features/gameplay/game/timeline/combo_tracker.dart';
export 'package:nesty_game/features/gameplay/game/timeline/feedback_sink.dart';
export 'package:nesty_game/features/gameplay/game/timeline/fx_clip.dart';
export 'package:nesty_game/features/gameplay/game/timeline/fx_command.dart';
export 'package:nesty_game/features/gameplay/game/timeline/fx_placement.dart';
export 'package:nesty_game/features/gameplay/game/timeline/fx_segment.dart';
export 'package:nesty_game/features/gameplay/game/timeline/hand_tween.dart';
export 'package:nesty_game/features/gameplay/game/timeline/motion_spec.dart';
export 'package:nesty_game/features/gameplay/game/timeline/slot_reservations.dart';
export 'package:nesty_game/features/gameplay/game/timeline/timeline_batch.dart';
export 'package:nesty_game/features/gameplay/game/timeline/win_overlay_schedule.dart';
