import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/theme/app_theme.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
import 'package:nesty_game/core/ui/widgets/text/shrink_to_fit_text.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/game/timeline/feedback_sink.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_board.dart';
import 'package:nesty_game/l10n/app_localizations.dart';
import 'package:nesty_render/nesty_render.dart';

import '../../l10n/support/test_locale.dart';

export '../../l10n/support/test_locale.dart'
    show testL10n, testLocale, testLocaleCode;

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
const allOverflowScreenSizes = [
  Size(360, 640),
  Size(390, 844),
  Size(430, 932),
  Size(375, 667),
  Size(768, 1024),
];

/// The locales whose overflow run takes every size (build/m7-p5/p5/l10n.md
/// §6.2): English, German (the longest) and Hindi and Japanese (the
/// tallest). The others take the two small phones, where a long string
/// breaks first.
const fullOverflowMatrixLocales = {'en', 'de', 'hi', 'ja'};

/// `--dart-define=NESTY_OVERFLOW_MATRIX=full` gives every locale every size.
const overflowMatrix = String.fromEnvironment('NESTY_OVERFLOW_MATRIX');

/// The sizes the overflow suite sweeps in this run's locale ([testLocale];
/// l10n.md §6.2): [allOverflowScreenSizes] for [fullOverflowMatrixLocales]
/// or a `full` matrix, else 360×640 and 375×667. Each still runs at both
/// [textScales].
final List<Size> overflowScreenSizes =
    overflowMatrix == 'full' ||
        fullOverflowMatrixLocales.contains(testLocale.languageCode)
    ? allOverflowScreenSizes
    : const [Size(360, 640), Size(375, 667)];

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
/// the app theme, the run's copy ([testLocale], English by default, or
/// [locale]), [textScale] and [reduceMotion].
Future<void> pumpScreen(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(390, 844),
  double textScale = 1,
  bool reduceMotion = false,
  EdgeInsets? padding,
  Locale? locale,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final safe = padding ?? safeAreaOf(size);
  await tester.pumpWidget(
    MaterialApp(
      // The app's own locale wiring (app.dart): the script's theme, and
      // its size factor and display face under the run's text scale.
      theme: AppTheme.forLocale(checkedLocale(locale)),
      debugShowCheckedModeBanner: false,
      locale: checkedLocale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: reduceMotion,
          padding: safe,
          viewPadding: safe,
        ),
        child: LocaleScriptScope(child: child!),
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
  expectReadableText(tester);
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

/// The readability floor (build/m7-p5/p5/l10n.md §6.2 item 7): no text is
/// drawn below this share of its style's size, at the run's text scale, by
/// a `FittedBox` (or any scale transform) or a `ShrinkToFitText`. Below it
/// a string gets its short form instead (tokens.json `textFit`: wrap, else
/// scale to the surface's `minScale`, 0.75 at the least, else the short
/// form).
const readableFloor = 0.75;

/// `report` (the default) prints the texts under [readableFloor] and
/// passes; `gate` fails on them. l10n.md §6.2 runs it as a report until
/// English passes: in 5B-1 English did not (the HUD's level pill, Home's
/// chapter card and bonus card, rival select and the rival strip at 360 dp
/// and 1.3× text, where the short forms are not wired yet), so 5B-5 flips
/// the default to `gate` once they are. `--dart-define=NESTY_READABILITY=
/// gate` gates a run now.
const readabilityMode = String.fromEnvironment(
  'NESTY_READABILITY',
  defaultValue: 'gate',
);

/// Every text on screen drawn below [readableFloor] of its style's size:
/// the scale its transform to the screen applies (a `FittedBox`'s shrink),
/// times a `ShrinkToFitText`'s font step, times the text scaler. Text that
/// is scaled to nothing (an entrance not begun) or offstage is not drawn,
/// so it is skipped.
List<String> unreadableText(WidgetTester tester) {
  final requested = <RenderParagraph, double>{};
  for (final element in find.byType(ShrinkToFitText).evaluate()) {
    final widget = element.widget as ShrinkToFitText;
    final size =
        DefaultTextStyle.of(element).style.merge(widget.style).fontSize ?? 14;
    void visit(Element child) {
      final object = child.renderObject;
      if (child.widget is RichText && object is RenderParagraph) {
        requested[object] = size;
      }
      child.visitChildren(visit);
    }

    element.visitChildren(visit);
  }

  final found = <String>[];
  final pixelRatio = tester.view.devicePixelRatio;
  void walk(RenderObject object) {
    if (object is RenderOffstage && object.offstage) return;
    if (object is RenderOpacity && object.opacity == 0) return;
    if (object is RenderParagraph && object.hasSize && object.attached) {
      final text = object.text.toPlainText().trim();
      final fontSize = object.text.style?.fontSize;
      if (text.isNotEmpty &&
          !_isIconGlyph(text) &&
          fontSize != null &&
          fontSize > 0) {
        final matrix = object.getTransformTo(null);
        final scale =
            math.sqrt(
              matrix.entry(0, 0) * matrix.entry(0, 0) +
                  matrix.entry(1, 0) * matrix.entry(1, 0),
            ) /
            pixelRatio;
        final shrink = fontSize / (requested[object] ?? fontSize);
        // The script's size factor (Japanese draws at 0.94, tokens
        // `font.scripts.jpan.size`) is the design's size for that script,
        // not a shrink: the floor is measured against it.
        final scaler =
            object.textScaler.scale(fontSize) /
            fontSize /
            LocaleScript.current.sizeFactor;
        final factor = scale * shrink * scaler;
        if (scale > 0.05 && factor < readableFloor - 0.005) {
          found.add(
            '"${text.replaceAll('\n', ' / ')}" at '
            '${(factor * 100).toStringAsFixed(0)} % of its '
            '${(requested[object] ?? fontSize).toStringAsFixed(1)} dp style',
          );
        }
      }
    }
    object.visitChildren(walk);
  }

  tester.binding.renderViews.forEach(walk);
  return found;
}

/// An icon font's glyph (Private Use Area), which is not text to read.
bool _isIconGlyph(String text) => text.runes.every(
  (rune) =>
      (rune >= 0xE000 && rune <= 0xF8FF) || rune >= 0xF0000 || rune == 0x20,
);

/// [unreadableText] is empty, or, in a `report` run, printed.
void expectReadableText(WidgetTester tester) {
  final found = unreadableText(tester);
  if (readabilityMode == 'report') {
    if (found.isNotEmpty) {
      debugPrint(
        'READABILITY ${tester.testDescription}:\n  ${found.join('\n  ')}',
      );
    }
    return;
  }
  expect(found, isEmpty, reason: 'text is drawn below the readability floor');
}
