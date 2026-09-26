import 'dart:ui' as ui;

import 'package:flame/components.dart' hide Snapshot;
import 'package:flutter/painting.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/skin/level_skin_images.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/game/components/board_component.dart';
import 'package:nesty_game/features/gameplay/game/components/fx_layer.dart';
import 'package:nesty_game/features/gameplay/game/nesty_game.dart';
import 'package:nesty_game/features/gameplay/game/timeline/timeline.dart';
import 'package:nesty_render/nesty_render.dart';

import '../../../../helpers/level_fixtures.dart';
import '../../../fx/support/fx_test_art.dart';

export '../../../../helpers/level_fixtures.dart';
export '../../../fx/support/fx_test_art.dart';

/// NestyBoard:80–84 `MAIN()` (frame 2.2, Level 56) as a level: a tower at
/// r1c0 (blue2 over green1), a purple-locked glass case at r1c3 (green2),
/// ice 2 on r2c1 (blue1); r1c2 is empty. The same contents as nesty_render's
/// `mainBoardContents`.
final Level mainLevel = levelFrom('''
{
  "schemaVersion": 1,
  "id": "T5600",
  "maxSize": 4,
  "shelves": [
    [ {"type": "open", "nest": ["red4", "red3"]},
      {"type": "open", "nest": ["blue4", "blue3"]},
      {"type": "open", "nest": ["green4"]},
      {"type": "open", "nest": ["purple3", "purple2", "purple1"]} ],
    [ {"type": "tower", "stack": [["green1"], ["blue2"]]},
      {"type": "open", "nest": ["red2", "red1"]},
      {"type": "open", "nest": null},
      {"type": "locked", "unlockColor": "purple", "nest": ["green2"]} ],
    [ {"type": "open", "nest": ["purple4"]},
      {"type": "open", "nest": ["blue1"], "ice": 2},
      {"type": "open", "nest": ["green3"]} ]
  ]
}
''');

/// The Level 1 tutorial: red3 at r0c0, red2 at r0c2, red1 at r1c1.
final Level tutorial = levelFrom(tutorialLevelJson);

/// The board files the game pools, plus the slot compositions.
const boardFiles = [...FxLayer.pooled, FxId.fxGlassUnlock, FxId.fxIce];

/// A fake library holding the shipped compositions of [ids], with a blank.
Future<FakeFxLibrary> libraryWith(Iterable<FxId> ids) async {
  final library = FakeFxLibrary()..blank = transparentPixel;
  for (final id in ids) {
    library.compositions[id] = await shippedOnce(id);
  }
  await library.load();
  return library;
}

/// The game's frame: 60 fps.
const frameMs = 1000 / 60;

/// A mounted [NestyGame] on a real `GameSession`, recording the intents,
/// commands, cues and callbacks.
final class GameHarness {
  GameHarness._(this.session, this.game);

  static Future<GameHarness> mount(
    Level level, {
    FxLibrary? fx,
    BoardViewport viewport = BoardViewport.reference,
    bool reduceMotion = false,
    LevelSkin? skin,
  }) async {
    late final GameHarness harness;
    final cues = <FxCue>[];
    final game = NestyGame(
      fx: fx,
      feedback: _RecordingFeedback(cues),
      onIntent: (intent) => harness.intents.add(intent),
      onFamilyLanded: (done, total, _) => harness.landed.add((done, total)),
      onBoardIdle: () => harness.idles++,
      onWon: (moves) => harness.won.add(moves),
      onOutOfMoves: () => harness.outOfMoves++,
      onLayout: (geometry) => harness.layouts.add(geometry),
      padding: viewport.padding,
      reduceMotion: reduceMotion,
    );
    harness = GameHarness._(GameSession(level), game).._cues = cues;
    game.onGameResize(Vector2(viewport.size.width, viewport.size.height));
    await game.onLoad();
    // ignore: invalid_use_of_internal_member
    game.mount();
    game.board.debugOnCommand = (command, lateMs) =>
        harness.executed.add((command: command, lateMs: lateMs));
    if (skin != null) game.skin = skin;
    await harness.tick();
    return harness;
  }

  final GameSession session;
  final NestyGame game;
  final List<GameplayEvent> intents = [];
  final List<({FxCommand command, double lateMs})> executed = [];
  final List<(int, int)> landed = [];
  final List<int> won = [];
  final List<BoardGeometry> layouts = [];
  int idles = 0;
  int outOfMoves = 0;
  late List<FxCue> _cues;

  List<FxCue> get cues => _cues;

  BoardComponent get board => game.board;

  BoardTimeline get timeline => board.timeline!;

  GameState get state => session.state;

  /// One tick of [ms], then every pending add and remove.
  Future<void> tick([double ms = 0]) async {
    game.update(ms / 1000);
    await game.ready();
  }

  /// Ticks in [stepMs] frames until [ms] have passed.
  Future<void> run(double ms, {double stepMs = frameMs}) async {
    var left = ms;
    while (left > 1e-9) {
      final dt = left < stepMs ? left : stepMs;
      game.update(dt / 1000);
      left -= dt;
    }
    await game.ready();
  }

  /// Applies [effect] with the session's state and ticks once (0 ms).
  Future<void> apply(BoardEffect effect) async {
    game.apply(effect, state);
    await tick();
  }

  Future<void> start() =>
      apply(BoardResetEffect(snapshot: state, reason: BoardResetReason.start));

  Future<void> select(String slotId, {bool byDrag = false}) =>
      apply(SelectionChangedEffect(selected: slotId, byDrag: byDrag));

  /// Plays [from] → [to] in core (it must be legal) and applies it.
  Future<MoveApplied> move(
    String from,
    String to, {
    bool byDrag = false,
  }) async {
    final result = session.move(from, to);
    if (result is! MoveApplied) throw StateError('$from -> $to: $result');
    await apply(MoveAppliedEffect(result: result, byDrag: byDrag));
    return result;
  }

  /// The commands of type [T] executed so far.
  Iterable<T> commandsOf<T extends FxCommand>() =>
      executed.map((e) => e.command).whereType<T>();

  /// The whole board as rendered now, at [pixelRatio].
  Future<Snapshot> render({double pixelRatio = 1}) =>
      snapshot(game.size.x, game.size.y, game.render, pixelRatio: pixelRatio);
}

final class _RecordingFeedback implements FeedbackSink {
  _RecordingFeedback(this.cues);

  final List<FxCue> cues;

  @override
  void play(FxCue cue) => cues.add(cue);
}

/// A doll part set for [colors] at [artHeightPx], shaped like the real
/// rasters (m2-lottie-design §4, D45): an opaque doll inside its outline
/// (so a nested doll is hidden by the one around it), soft detail on it, a
/// translucent ground shadow under the base, and the hard split at art
/// y 400: each lid has art above the split row only, each body below it.
DollPartSet blobParts(Iterable<DollColor> colors, {int artHeightPx = 300}) {
  final r = artHeightPx / 768;
  final split = DollPartRasters.splitRowPx(artHeightPx: artHeightPx);
  final width = (512 * r).round();
  ui.Image part(DollColor color, {required bool lid}) {
    final swatch = DollPalette.of(color);
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder)
      ..clipRect(
        lid
            ? Rect.fromLTRB(0, 0, width.toDouble(), split.toDouble())
            : Rect.fromLTRB(
                0,
                split.toDouble(),
                width * 1.0,
                artHeightPx * 1.0,
              ),
      )
      ..scale(r);
    if (!lid) {
      // The ground shadow, under the base (art y 742).
      canvas.drawOval(
        const Rect.fromLTRB(136, 722, 376, 762),
        Paint()..color = const Color(0x55000000),
      );
    }
    canvas
      ..drawRRect(
        RRect.fromLTRBR(96, 40, 416, 742, const Radius.circular(150)),
        Paint()..color = lid ? swatch.base : swatch.light,
      )
      ..drawCircle(
        Offset(lid ? 200 : 300, lid ? 230 : 560),
        90,
        Paint()
          ..shader = ui.Gradient.radial(
            Offset(lid ? 200 : 300, lid ? 230 : 560),
            90,
            [swatch.ink, swatch.ink.withValues(alpha: 0)],
          ),
      );
    return recorder.endRecording().toImageSync(width, artHeightPx);
  }

  return DollPartSet(
    skinKey: 'test@1',
    symbols: DollSymbols.none,
    artHeightPx: artHeightPx,
    lids: {for (final color in colors) color: part(color, lid: true)},
    bodies: {for (final color in colors) color: part(color, lid: false)},
    silhouette: insetBox(width, artHeightPx, const Color(0xFFE6C08C)),
  );
}

/// A level skin over [parts]: the real `LevelSkinImages` (the game's
/// `FxImageSource`) and `PartRasterDollRenderer`, no board sprites.
final class TestSkin implements LevelSkin {
  TestSkin(this.parts)
    : images = LevelSkinImages(parts: parts),
      restRenderer = PartRasterDollRenderer(parts.clone());

  final DollPartSet parts;

  @override
  final FxImageSource images;

  @override
  final DollRenderer restRenderer;

  @override
  BoardSprites? get sprites => null;

  bool disposed = false;

  @override
  void dispose() {
    if (disposed) return;
    disposed = true;
    restRenderer.dispose();
    (images as LevelSkinImages).dispose();
    parts.dispose();
  }
}

/// The mean absolute channel difference of [a] and [b] (0–255) over the
/// pixels either one touches inside [region] (pixel coordinates; the whole
/// snapshot when null), and how many pixels that is.
({double mean, int touched}) meanDifference(
  Snapshot a,
  Snapshot b, {
  Rect? region,
}) {
  final left = region == null ? 0 : region.left.floor().clamp(0, a.width);
  final top = region == null ? 0 : region.top.floor().clamp(0, a.height);
  final right = region == null
      ? a.width
      : region.right.ceil().clamp(0, a.width);
  final bottom = region == null
      ? a.height
      : region.bottom.ceil().clamp(0, a.height);
  var sum = 0;
  var touched = 0;
  for (var y = top; y < bottom; y++) {
    for (var x = left; x < right; x++) {
      final i = (y * a.width + x) * 4;
      if (a.bytes[i + 3] == 0 && b.bytes[i + 3] == 0) continue;
      touched++;
      for (var c = 0; c < 4; c++) {
        sum += (a.bytes[i + c] - b.bytes[i + c]).abs();
      }
    }
  }
  return (mean: touched == 0 ? 0 : sum / (touched * 4), touched: touched);
}

/// [slot]'s doll box for a doll of [size] at its resting base, in pixels at
/// [pixelRatio], with a margin for filtering (the shadow is inside the art
/// box; the pips just below it are not).
Rect dollBox(SlotGeometry slot, int size, {double pixelRatio = 1}) {
  final box = slot.dollRect(size);
  return Rect.fromLTRB(
    (box.left - 4) * pixelRatio,
    (box.top - 4) * pixelRatio,
    (box.right + 4) * pixelRatio,
    (box.bottom + 1) * pixelRatio,
  );
}
