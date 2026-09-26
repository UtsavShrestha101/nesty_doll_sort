import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/game/timeline/timeline.dart';
import 'package:nesty_render/nesty_render.dart';

import '../../../../../helpers/level_fixtures.dart';

/// 1× frame times of the files, as docs/plans/m2-lottie-design.md §7 and
/// §17 quote them (60 fps).
double framesMs(double frames) => frames * 1000 / 60;

/// The Level 1 tutorial: red3 at r0c0, red2 at r0c2, red1 at r1c1.
final Level tutorial = levelFrom(tutorialLevelJson);

/// Red completes by r0c0 (red3) swallowing r0c1 ([red2, red1]); the
/// completion breaks the red glass on r0c2 (blue3 inside) and cracks the
/// ice (3) on r0c3 (blue2). Blue is left to play.
final Level comboLevel = levelFrom('''
{
  "schemaVersion": 1,
  "id": "T1001",
  "maxSize": 3,
  "shelves": [
    [ {"type": "open", "nest": ["red3"]},
      {"type": "open", "nest": ["red2", "red1"]},
      {"type": "locked", "unlockColor": "red", "nest": ["blue3"]},
      {"type": "open", "nest": ["blue2"], "ice": 3} ],
    [ {"type": "open", "nest": ["blue1"]},
      {"type": "open", "nest": null},
      {"type": "tower", "stack": [["green1"], ["green3"]]},
      {"type": "open", "nest": ["green2"]} ]
  ]
}
''');

/// Towers: r0c0 buries red1 and red2 under blue3 (moving blue3 to the
/// empty r0c2 reveals red2); r0c1 buries blue1 under [red2, red1], which
/// red3 on r1c0 swallows into a full set (the completion reveals blue1).
final Level towerLevel = levelFrom('''
{
  "schemaVersion": 1,
  "id": "T1002",
  "maxSize": 3,
  "shelves": [
    [ {"type": "tower", "stack": [["green1"], ["green2"], ["blue3"]]},
      {"type": "tower", "stack": [["blue1"], ["red2", "red1"]]},
      {"type": "open", "nest": null} ],
    [ {"type": "open", "nest": ["red3"]},
      {"type": "open", "nest": ["blue2"]},
      {"type": "open", "nest": ["green3"]} ]
  ]
}
''');

/// Two sets on separate slots: red3 swallows [red2, red1] on r0c1 (which
/// breaks two red glass cases, the last 80 ms after the first), and green3
/// on r0c3 swallows [green2, green1] on r1c0 for the win. Either move can
/// start while the other plays.
final Level twoSetLevel = levelFrom('''
{
  "schemaVersion": 1,
  "id": "T1004",
  "maxSize": 3,
  "shelves": [
    [ {"type": "open", "nest": ["red3"]},
      {"type": "open", "nest": ["red2", "red1"]},
      {"type": "locked", "unlockColor": "red", "nest": null},
      {"type": "open", "nest": ["green3"]} ],
    [ {"type": "open", "nest": ["green2", "green1"]},
      {"type": "locked", "unlockColor": "red", "nest": null} ]
  ]
}
''');

/// Hide counts per slot, applied from the commands the board received the
/// way the board does (§10.1): a live clip or tween hides its slots' top
/// sprites until it is released, stopped or ended.
final class SpriteModel {
  final Map<String, int> hidden = {};
  final Set<int> _hiding = {};

  bool isHidden(String slotId) => (hidden[slotId] ?? 0) > 0;

  void apply(FxCommand command) {
    switch (command) {
      case StartClip(:final clip):
        if (_hiding.add(clip.id)) _add(clip.hides, 1);
      case ReleaseClipSlots(:final clip) || StopClip(:final clip):
        if (_hiding.remove(clip.id)) _add(clip.hides, -1);
      case StartTween(:final tween):
        _add(tween.hides, 1);
      case EndTween(:final tween):
        _add(tween.hides, -1);
      case ResetBoard():
        hidden.clear();
        _hiding.clear();
      default:
        break;
    }
  }

  void _add(List<String> slots, int delta) {
    for (final id in slots) {
      final count = (hidden[id] ?? 0) + delta;
      expect(count, greaterThanOrEqualTo(0), reason: 'hide count of $id');
      hidden[id] = count;
    }
  }
}

/// The iced tutorial of the bloc fixtures, with [ice] layers on red2
/// (r0c2).
Level icedTutorial(int ice) => levelFrom('''
{
  "schemaVersion": 1,
  "id": "T1003",
  "maxSize": 3,
  "shelves": [
    [ {"type": "open", "nest": ["red3"]},
      {"type": "open", "nest": null},
      {"type": "open", "nest": ["red2"], "ice": $ice} ],
    [ {"type": "open", "nest": null},
      {"type": "open", "nest": ["red1"]},
      {"type": "open", "nest": null} ]
  ]
}
''');

/// The bloc fixtures' out-of-moves board: blue1 (r0c0's top) into the
/// empty r0c3 leaves no legal move.
final Level outOfMoves = levelFrom('''
{
  "schemaVersion": 1,
  "id": "T0002",
  "maxSize": 3,
  "shelves": [
    [ {"type": "tower", "stack": [["red2"], ["red1"], ["blue1"]]},
      {"type": "tower", "stack": [["blue2"], ["red3"]]},
      {"type": "open", "nest": ["blue3"]},
      {"type": "open", "nest": null} ]
  ]
}
''');

/// The layout the game would build for [state] on [viewport]: the level's
/// slot kinds (a tower stays a tower stand, a lock a case), extra slots on
/// the bottom shelf.
BoardGeometry geometryOf(
  GameState state, {
  BoardViewport viewport = BoardViewport.reference,
}) {
  final level = state.level;
  final rows = <List<SlotShape>>[];
  for (var r = 0; r < level.shelves.length; r++) {
    final shelf = level.shelves[r];
    rows.add([
      for (var c = 0; c < shelf.length; c++)
        SlotShape(SlotId.grid(r, c), switch (shelf[c]) {
          TowerSlot() => SlotShapeKind.tower,
          LockedSlot() => SlotShapeKind.locked,
          OpenSlot() => SlotShapeKind.open,
        }),
    ]);
  }
  for (final id in state.slotIds) {
    if (SlotId.isExtra(id)) rows.last.add(SlotShape(id, SlotShapeKind.extra));
  }
  return BoardLayout.compute(
    BoardShape(rows: rows, maxSize: level.maxSize),
    viewport,
  );
}

/// A command as the board received it.
typedef Executed = ({FxCommand command, double lateMs, double atMs});

/// A cue as the sink played it.
typedef Played = ({FxCue cue, double atMs});

final class RecordingCommandSink implements FxCommandSink {
  BoardTimeline? timeline;
  final List<Executed> executed = [];

  @override
  void execute(FxCommand command, double lateMs) => executed.add((
    command: command,
    lateMs: lateMs,
    atMs: timeline?.nowMs ?? 0,
  ));
}

final class RecordingFeedbackSink implements FeedbackSink {
  BoardTimeline? timeline;
  final List<Played> played = [];

  @override
  void play(FxCue cue) => played.add((cue: cue, atMs: timeline?.nowMs ?? 0));
}

/// A timeline over a real [GameSession] of [level], with recording sinks.
final class TimelineHarness {
  TimelineHarness(
    Level level, {
    MotionSpec motion = MotionSpec.standard,
    bool Function(FxId id)? isAvailable,
    Map<FxId, int> poolSizes = TimelinePools.defaults,
    ComboTracker? combo,
    BoardViewport viewport = BoardViewport.reference,
  }) : session = GameSession(level),
       _viewport = viewport {
    timeline = BoardTimeline(
      commands: commands,
      feedback: feedback,
      geometry: geometryOf(session.state, viewport: viewport),
      motion: motion,
      isAvailable: isAvailable,
      poolSizes: poolSizes,
      combo: combo,
    );
    commands.timeline = timeline;
    feedback.timeline = timeline;
  }

  final GameSession session;
  final BoardViewport _viewport;
  final RecordingCommandSink commands = RecordingCommandSink();
  final RecordingFeedbackSink feedback = RecordingFeedbackSink();
  late final BoardTimeline timeline;

  GameState get state => session.state;

  BoardGeometry get geometry => timeline.geometry;

  TimelineBatch schedule(
    BoardEffect effect, {
    BoardGeometry? geometry,
    Offset? dragBase,
  }) =>
      timeline.schedule(effect, state, geometry: geometry, dragBase: dragBase);

  TimelineBatch start() => schedule(
    BoardResetEffect(snapshot: state, reason: BoardResetReason.start),
  );

  TimelineBatch select(String slotId, {bool byDrag = false}) =>
      schedule(SelectionChangedEffect(selected: slotId, byDrag: byDrag));

  TimelineBatch deselect(String slotId, {bool byDrag = false, Offset? at}) =>
      schedule(
        SelectionChangedEffect(previous: slotId, byDrag: byDrag),
        dragBase: at,
      );

  /// Plays [from] → [to] in core; it must be legal.
  TimelineBatch move(
    String from,
    String to, {
    bool byDrag = false,
    Offset? dragBase,
  }) {
    final result = session.move(from, to);
    expect(result, isA<MoveApplied>(), reason: '$from -> $to');
    return schedule(
      MoveAppliedEffect(result: result as MoveApplied, byDrag: byDrag),
      dragBase: dragBase,
    );
  }

  /// Tries [from] → [to] in core; it must be rejected.
  TimelineBatch reject(
    String from,
    String to, {
    bool byDrag = false,
    Offset? dragBase,
  }) {
    final result = Rules.tryMove(state, Move(from, to));
    expect(result, isA<MoveRejected>(), reason: '$from -> $to');
    return schedule(
      MoveRejectedEffect(
        source: from,
        target: to,
        reason: (result as MoveRejected).reason,
        byDrag: byDrag,
      ),
      dragBase: dragBase,
    );
  }

  TimelineBatch addExtraSlot() {
    final added = session.addExtraSlot()!;
    return schedule(
      ExtraSlotAddedEffect(added),
      geometry: geometryOf(added.state, viewport: _viewport),
    );
  }

  /// Advances in [stepMs] frames until [ms] have passed.
  void run(double ms, {double stepMs = 1000 / 60}) {
    var left = ms;
    while (left > 1e-9) {
      final dt = left < stepMs ? left : stepMs;
      timeline.advance(dt);
      left -= dt;
    }
  }
}

/// The only [T] in [batch] matching [test].
T only<T extends FxCommand>(TimelineBatch batch, [bool Function(T)? test]) {
  final found = batch.commandsOf<T>().where(test ?? (_) => true).toList();
  expect(found, hasLength(1), reason: '$T in ${batch.commands}');
  return found.single;
}

/// The only clip of [purpose] (and [fx]) the batch starts.
StartClip startOf(TimelineBatch batch, FxClipPurpose purpose, [FxId? fx]) =>
    only<StartClip>(
      batch,
      (c) => c.clip.purpose == purpose && (fx == null || c.clip.fx == fx),
    );

/// The commands of [batch] addressed to [clip].
List<FxCommand> commandsFor(TimelineBatch batch, FxClip clip) => [
  for (final command in batch.commands)
    if (_clipOf(command)?.id == clip.id) command,
];

FxClip? _clipOf(FxCommand command) => switch (command) {
  StartClip(:final clip) ||
  PlayClipSegment(:final clip) ||
  PlaceClip(:final clip) ||
  ReleaseClipSlots(:final clip) ||
  StopClip(:final clip) => clip,
  _ => null,
};

/// The time [clip] stops in [batch].
double stopOf(TimelineBatch batch, FxClip clip) =>
    only<StopClip>(batch, (c) => c.clip.id == clip.id).atMs;

/// Close to [ms] within 1e-6.
Matcher at(double ms) => closeTo(ms, 1e-6);

/// An [Offset] close to ([x], [y]).
Matcher offsetNear(double x, double y, [double tolerance = 1e-6]) =>
    isA<Offset>()
        .having((o) => o.dx, 'dx', closeTo(x, tolerance))
        .having((o) => o.dy, 'dy', closeTo(y, tolerance));

/// An [FxCue] at [atMs] (within 1e-6) with exactly these fields.
Matcher isCue(
  double atMs, {
  SoundEffect? sound,
  HapticPattern? haptic,
  int? dollSize,
  int? comboStep,
}) => isA<FxCue>()
    .having((c) => c.atMs, 'atMs', closeTo(atMs, 1e-6))
    .having((c) => c.sound, 'sound', sound)
    .having((c) => c.haptic, 'haptic', haptic)
    .having((c) => c.dollSize, 'dollSize', dollSize)
    .having((c) => c.comboStep, 'comboStep', comboStep);
