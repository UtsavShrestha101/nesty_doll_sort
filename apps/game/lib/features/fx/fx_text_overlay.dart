import 'dart:ui';

import 'package:nesty_game/core/ui/lottie/lottie_label.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/fx/fx_drawable_params.dart';
import 'package:nesty_game/features/fx/fx_id.dart';

/// A file whose text layers are hidden and replaced by a localized Flutter
/// label that follows one of its nulls (PROGRESS D44, m2-lottie-design
/// §12): the family counter and the two ribbons.
final class FxTextHook {
  const FxTextHook(this.nullName, this.style, {this.swapFrame});

  /// The null the label follows (`counter`, `ribbon`). Its position and
  /// scale are captured during the draw by callbacks that return the
  /// authored values unchanged.
  final String nullName;

  /// Size, colour, shadow, baseline and fit of the label, and the null's
  /// rest position (the UI lane's table, `LottieLabelStyles`).
  final LottieLabelStyle style;

  /// While playing, frames before this show the previous label: the
  /// counter's old count swaps for the new one at the bump's peak.
  final double? swapFrame;

  static const _counter = FxTextHook(
    'counter',
    LottieLabelStyles.familyCounter,
    swapFrame: FxTiming.counterSwapFrame,
  );
  static const _winRibbon = FxTextHook('ribbon', LottieLabelStyles.winRibbon);
  static const _chapterRibbon = FxTextHook(
    'ribbon',
    LottieLabelStyles.chapterRibbon,
  );

  /// The hook of [id], or null for a file without text.
  static FxTextHook? of(FxId id) => switch (id) {
    FxId.uiFamilyCounter => _counter,
    FxId.uiWinRibbon => _winRibbon,
    FxId.uiChapterRibbon => _chapterRibbon,
    _ => null,
  };
}

/// Paints a [FxTextHook]'s label over its composition, at the null's
/// captured transform, with one cached `TextPainter` per label (laid out
/// only when its text changes: rule 8). Owned by one view.
final class FxTextOverlay {
  FxTextOverlay(
    this.hook, {
    this.textDirection = TextDirection.ltr,
    LottieLabelStyle? style,
  }) : style = style ?? hook.style,
       _label = LottieLabelPainter(
         style ?? hook.style,
         textDirection: textDirection,
       ),
       _previous = LottieLabelPainter(
         style ?? hook.style,
         textDirection: textDirection,
       );

  final FxTextHook hook;

  /// The label's style: the hook's, or a ribbon's for its band width
  /// (`FxRibbon.labelFor`, m7-5).
  final LottieLabelStyle style;

  /// The labels' direction (Flutter text also fixes Lottie's hard-coded
  /// LTR, §12).
  final TextDirection textDirection;
  final LottieLabelPainter _label;
  final LottieLabelPainter _previous;
  bool _hasPrevious = false;

  /// The label shown at rest and after the swap.
  String get label => _label.text;
  set label(String value) => _label.text = value;

  /// The label shown before [FxTextHook.swapFrame] while playing (the old
  /// count); null shows [label] throughout.
  String? get previousLabel => _hasPrevious ? _previous.text : null;
  set previousLabel(String? value) {
    _hasPrevious = value != null;
    if (value != null) _previous.text = value;
  }

  // ── Hot path: painted every frame the view repaints. No allocation. ──

  /// Paints the label in the composition's space (after the drawable
  /// drew), following the transform [params] captured at [frame].
  void paint(
    Canvas canvas,
    FxDrawableParams params, {
    required double frame,
    required bool playing,
  }) {
    final swap = hook.swapFrame;
    final usePrevious = _hasPrevious && playing && swap != null && frame < swap;
    (usePrevious ? _previous : _label).paint(
      canvas,
      params.textNullPosition,
      nullScale: params.textNullScale,
    );
  }

  /// Paints the label at the null's rest position and scale 1 (no
  /// composition: the file failed to load, rule 3).
  void paintAtRest(Canvas canvas) => _label.paint(canvas, style.restNull);

  // ── End of hot path. ──

  void dispose() {
    _label.dispose();
    _previous.dispose();
  }
}
