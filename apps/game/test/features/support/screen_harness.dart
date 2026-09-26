import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/theme/app_theme.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/game/timeline/feedback_sink.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_board.dart';
import 'package:nesty_game/l10n/app_localizations.dart';
import 'package:nesty_render/nesty_render.dart';

/// The phones every screen is checked on (spec §16, M7 "no layout
/// overflows"): a small Android, the design's reference, a large iPhone.
const screenSizes = [Size(360, 640), Size(390, 844), Size(430, 932)];

/// Menus respect system text up to 1.3× (spec §16, `App`'s clamp).
const textScales = [1.0, 1.3];

/// Safe areas of each size above (status bar / home indicator).
EdgeInsets safeAreaOf(Size size) => size.height >= 844
    ? const EdgeInsets.only(top: 59, bottom: 34)
    : const EdgeInsets.only(top: 24, bottom: 16);

/// Pumps [child] as a whole screen on a [size] phone with its safe areas,
/// the app theme, English copy, [textScale] and [reduceMotion].
Future<void> pumpScreen(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(390, 844),
  double textScale = 1,
  bool reduceMotion = false,
  EdgeInsets? padding,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final safe = padding ?? safeAreaOf(size);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: reduceMotion,
          padding: safe,
          viewPadding: safe,
        ),
        child: child!,
      ),
      home: child,
    ),
  );
}

/// Records the cues it is asked to play.
final class RecordingCues implements FeedbackSink {
  final List<FxCue> played = [];

  @override
  void play(FxCue cue) => played.add(cue);
}

/// A [GameplayBoard] with no Flame: it records what the page tells it, and
/// the test plays the board's side through [callbacks].
final class FakeGameplayBoard implements GameplayBoard {
  FakeGameplayBoard(
    this.callbacks, {
    required FxLibrary fx,
    required FeedbackSink feedback,
    this.drivesOutcomes = true,
  });

  final GameplayBoardCallbacks callbacks;

  @override
  final bool drivesOutcomes;

  final List<BoardEffect> applied = [];
  final List<LevelSkin?> skins = [];
  @override
  EdgeInsets? padding;

  @override
  bool? reduceMotion;

  @override
  DollSymbols? symbols;

  @override
  bool paused = false;

  @override
  bool overlayOpen = false;

  @override
  final Widget view = const SizedBox.expand(key: ValueKey('fake-board'));

  @override
  void apply(BoardEffect effect, GameState board) => applied.add(effect);

  @override
  set levelSkin(LevelSkin? skin) => skins.add(skin);

  /// The screen [layOut] and [layoutFor] lay boards out on; null plays a
  /// board that isn't sized yet.
  Size? screen = const Size(390, 844);

  @override
  BoardGeometry? layoutFor(GameState state) {
    final size = screen;
    return size == null ? null : _layout(state, size);
  }

  /// The board laid [board] out on [size] with [padding]: reports it.
  void layOut(GameState board, {Size size = const Size(390, 844)}) =>
      callbacks.onLayout(_layout(board, size));

  BoardGeometry _layout(GameState board, Size size) => BoardLayout.compute(
    _shapeOf(board),
    BoardViewport(size: size, padding: padding ?? EdgeInsets.zero),
  );

  static BoardShape _shapeOf(GameState board) {
    final rows = List.generate(
      board.level.shelves.length,
      (_) => <SlotShape>[],
    );
    for (final id in board.slotIds) {
      rows[board.positionOf(id).row].add(SlotShape(id, SlotShapeKind.open));
    }
    return BoardShape(rows: rows, maxSize: board.level.maxSize);
  }
}

/// Builds a [FakeGameplayBoard] and keeps it for the test.
final class FakeBoardFactory {
  FakeBoardFactory({this.drivesOutcomes = true});

  final bool drivesOutcomes;
  FakeGameplayBoard? board;

  GameplayBoard call(
    GameplayBoardCallbacks callbacks, {
    required FxLibrary fx,
    required FeedbackSink feedback,
  }) => board = FakeGameplayBoard(
    callbacks,
    fx: fx,
    feedback: feedback,
    drivesOutcomes: drivesOutcomes,
  );
}

/// No exception was thrown while laying out or painting (an overflow is
/// one).
void expectNoLayoutErrors(WidgetTester tester) =>
    expect(tester.takeException(), isNull);
