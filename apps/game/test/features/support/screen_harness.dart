import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

/// M7's five acceptance sizes (spec-prop §18, m7-design §18 "overflow"):
/// a small Android, the design's standard phone, a tall Android, a small
/// iPhone with a home button (no notch), and an iPad in portrait. Every
/// screen and overlay must lay out on all five, at [textScales], with no
/// overflow. Additive to [screenSizes] (which every existing per-widget
/// `screenSizes` loop keeps using unchanged); `test/overflow/` is the one
/// suite that sweeps this wider list.
const overflowScreenSizes = [
  Size(360, 640),
  Size(390, 844),
  Size(430, 932),
  Size(375, 667),
  Size(768, 1024),
];

/// Safe areas of each size above (status bar / home indicator). The three
/// [screenSizes] keep the exact values they always had; [overflowScreenSizes]
/// adds a small iPhone with a physical home button (status bar only, no
/// bottom inset) and an iPad in portrait (a modern Face ID/no-home-button
/// model: a shorter status bar than a notched phone's, plus a home
/// indicator).
EdgeInsets safeAreaOf(Size size) {
  if (size == const Size(375, 667)) return const EdgeInsets.only(top: 20);
  if (size == const Size(768, 1024)) {
    return const EdgeInsets.only(top: 24, bottom: 20);
  }
  return size.height >= 844
      ? const EdgeInsets.only(top: 59, bottom: 34)
      : const EdgeInsets.only(top: 24, bottom: 16);
}

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

  /// Set it to play the board's hint over the middle top stand (3.1b).
  @override
  final ValueNotifier<bool> familyCounterYield = ValueNotifier(false);

  final List<BoardEffect> applied = [];
  final List<LevelSkin?> skins = [];
  @override
  EdgeInsets? padding;

  /// The page's last hand-off (`GameplayBoard.boardLabels`); defaults to
  /// [BoardLabels.fallback], the same default the interface documents for
  /// "tests that don't exercise localization".
  @override
  BoardLabels boardLabels = BoardLabels.fallback;

  @override
  bool? reduceMotion;

  @override
  DollSymbols? symbols;

  @override
  bool paused = false;

  /// The page's last hand-off of the legal drop targets (E.14).
  @override
  Set<String> dropTargets = const {};

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

/// The overflow suite's check (M7 review R36): [expectNoLayoutErrors],
/// then every tappable node is at least 48 dp and labelled (spec §10.3 "Tap
/// targets are at least 48 dp", §16; m7-design §15 "nothing is narrower
/// than a 48 dp target") and no text on screen is cut ([expectNoCutText]).
/// An overflow is an exception, but a cut or a small target is not, so
/// before this the suite passed them silently.
Future<void> expectAccessibleLayout(WidgetTester tester) async {
  expectNoLayoutErrors(tester);
  final handle = tester.ensureSemantics();
  try {
    // A frame with no time passing, so the semantics tree is built even
    // when the test hadn't asked for it.
    await tester.pump();
    for (final guideline in [
      androidTapTargetGuideline,
      labeledTapTargetGuideline,
    ]) {
      final result = await guideline.evaluate(tester);
      expect(
        result.passed,
        isTrue,
        reason: '${guideline.description}:\n${result.reason}',
      );
    }
  } finally {
    handle.dispose();
  }
  expectNoCutText(tester);
}

/// No text on screen is cut: an ellipsis, lines past `maxLines`, or a
/// single line wider than its box (m7-design §15's shared rule: text scales
/// down, it is never cut; §15.2's "2 lines, no ellipsis at 1.3×"). A clip
/// throws nothing, so an overflow check alone never sees one.
void expectNoCutText(WidgetTester tester) {
  final cut = <String>[];
  void visit(RenderObject object) {
    if (object is RenderParagraph && object.hasSize) {
      final text = object.text.toPlainText();
      final singleLine = object.maxLines == 1 || !object.softWrap;
      final needs = object.getMaxIntrinsicWidth(double.infinity);
      final wider = singleLine && needs > object.size.width + 0.5;
      if (text.trim().isNotEmpty && (object.didExceedMaxLines || wider)) {
        cut.add(
          '"${text.replaceAll('\n', ' / ')}" '
          '(${object.size.width.toStringAsFixed(1)} dp wide, needs '
          '${needs.toStringAsFixed(1)})',
        );
      }
    }
    object.visitChildren(visit);
  }

  tester.binding.renderViews.forEach(visit);
  expect(cut, isEmpty, reason: 'text is cut instead of scaled down');
}
