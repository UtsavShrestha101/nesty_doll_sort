import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/art/ui_art.dart';
import 'package:nesty_game/core/ui/art/ui_art_image.dart';
import 'package:nesty_game/core/ui/art/ui_art_image_source.dart';
import 'package:nesty_game/core/ui/art/ui_art_library.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/fx_spec.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';

/// A level's stars, 0–3 of 3 (spec-prop §7.10, D125; docs/plans/
/// star-rating.md; docs/plans/m7-design.md P3.7 and P4.7; frames 11.1–11.4):
/// the win card's reveal, Chapters' cells and totals, Records.
///
/// The one swap point for every star surface (m7-design P3.7). Since the
/// m7-3 delivery it draws Claude Design's art, never a painted shape:
/// - [StarRow] (at rest) is `UiArt.starFilled`/`starEmpty` at [size]. An
///   unearned star is the empty art (a soft cream outline), never a grey
///   fill.
/// - [StarRow.reveal] is the `ui_stars` Lottie in its 240×110 canvas
///   (`WinStarsTokens.starsCanvasSize`): the file rests on frame 0 (three
///   empty stars), then `star_1…star_n` play back to back (20 frames,
///   333 ms each), then `flourish` at 3 stars. Its image slots are filled
///   from the UI art by `UiArtImageSource`.
///
/// Always one semantics node: `starsSemantics(count)` ("2 of 3 stars") or,
/// with [newBest], `starsNewBestSemantics`.
class StarRow extends StatefulWidget {
  /// The stars at rest (Chapters' cells, Records, the target row): [count]
  /// filled of 3, each [size] across ([middleSize] for the middle one: the
  /// level card's 40/48/40).
  const StarRow({
    required this.count,
    this.size = sizeCard,
    this.middleSize,
    super.key,
  }) : delay = Duration.zero,
       onStar = null,
       onFlourishEnd = null,
       newBest = false,
       library = null,
       artLibrary = null,
       reveal = false;

  /// The win card's reveal (frames 11.2–11.2c, `motion.stars`): from
  /// [delay], star 1..[count] fill one segment after the other, [onStar]
  /// firing as each starts (the overlay plays its `star_n` sound and light
  /// haptic, `WinOverlaySchedule.starCues`); at 3 stars the flourish plays
  /// and [onFlourishEnd] fires after it (the success haptic).
  ///
  /// Under reduce motion the last frame of `star_[count]` shows at once, no
  /// pop and no flourish, and [onStar] fires once, for [count] (Q146; D191:
  /// the highest star's sound and one haptic; this departs from D48's
  /// half-stagger for this cue only).
  const StarRow.reveal({
    required this.count,
    this.delay = Duration.zero,
    this.onStar,
    this.onFlourishEnd,
    this.newBest = false,
    this.library,
    this.artLibrary,
    super.key,
  }) : size = sizeWin,
       middleSize = null,
       reveal = true;

  /// The win card's stars (in `ui_stars`).
  static const double sizeWin = 44;

  /// A chapter card's and the folded row's total, and Records.
  static const double sizeCard = 20;

  /// Under each won level cell in Chapters.
  static const double sizeCell = 11;

  /// Stars filled, 0–3 (clamped).
  final int count;

  /// Each star's width and height (at rest; the reveal's are the file's 44).
  final double size;

  /// The middle star's size when it differs (the level card's 48).
  final double? middleSize;

  /// [StarRow.reveal]: when the first star starts, from the overlay's open.
  /// Already at the motion speed (`WinOverlaySchedule.starsStartMs`).
  final Duration delay;

  /// [StarRow.reveal]: star `i` (1-based) starts. Once, with [count], under
  /// reduce motion.
  final void Function(int star)? onStar;

  /// [StarRow.reveal]: the 3-star flourish has finished (never under reduce
  /// motion).
  final VoidCallback? onFlourishEnd;

  /// The win beat the level's best stars: the semantics say so.
  final bool newBest;

  /// [StarRow.reveal]: the FX library (the DI one by default).
  final FxLibrary? library;

  /// [StarRow.reveal]: overrides `UiArtLibrary.of(context)` (tests).
  final UiArtLibrary? artLibrary;

  /// Built with [StarRow.reveal].
  final bool reveal;

  /// Gap between two stars at rest, a share of [size].
  static const double gapRatio = 0.18;

  /// The reveal's canvas (`layout.winStars`): 240×110.
  static const Size canvas = WinStarsTokens.starsCanvasSize;

  /// The three star centres in the `ui_stars` canvas (frame 11.2): the
  /// middle one sits 6 higher.
  static const List<Offset> centres = [
    Offset(64, 58),
    Offset(120, 52),
    Offset(176, 58),
  ];

  /// The reveal's own image slots.
  static const List<FxImageSlot> slots = [
    FxImageSlot.starFilled,
    FxImageSlot.starEmpty,
    FxImageSlot.starGlow,
  ];

  /// The three fallback stars drawn while the file is missing, for tests.
  @visibleForTesting
  static Key fallbackKey(int star, {required bool filled}) =>
      Key('star-fallback-$star-${filled ? 'filled' : 'empty'}');

  /// The reveal's Lottie, for tests.
  @visibleForTesting
  static const Key revealKey = Key('star-reveal');

  @override
  State<StarRow> createState() => _StarRowState();
}

/// A fraction total ("38/60", "212/600": a chapter card, its folded row and
/// Records' Stars row, spec-prop §10.2 #18, #19; m7-design P3.7): one filled
/// star at [StarRow.sizeCard], beside `chaptersStarsTotal(earned, total)`.
/// Not a [StarRow] itself (a total isn't 0–3 stars), but the same art.
class StarsTotal extends StatelessWidget {
  const StarsTotal({required this.earned, required this.total, super.key});

  final int earned;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return Semantics(
      label: l10n.chaptersStarsSemantics(earned, total),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          UiArtImage.square(UiArt.starFilled, extent: StarRow.sizeCard),
          const SizedBox(width: StarRow.sizeCard * StarRow.gapRatio),
          Text(
            l10n.chaptersStarsTotal(earned, total),
            style: AppTextStyleTokens.row.copyWith(
              fontSize: 14,
              color: AppColorTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StarRowState extends State<StarRow> {
  final List<Timer> _timers = [];
  LottieFxController? _controller;
  UiArtImageSource? _source;
  UiArtLibrary? _art;
  double? _preparedRatio;

  /// Stars whose segment has started (1-based), for the fallback.
  int _landed = 0;
  bool _scheduled = false;

  /// The frame the file shows when it isn't playing, so a late raster
  /// repaints it.
  double _restFrame = 0;

  @override
  void initState() {
    super.initState();
    if (widget.reveal) {
      _controller = LottieFxController(FxId.uiStars)..seek(0);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.reveal) return;
    _prepare();
    if (!_scheduled) {
      _scheduled = true;
      _schedule(reduced: context.reduceMotion);
    }
  }

  void _prepare() {
    final art = widget.artLibrary ?? UiArtLibrary.of(context);
    final ratio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
    if (art == null || (identical(art, _art) && ratio == _preparedRatio)) {
      return;
    }
    _art = art;
    _preparedRatio = ratio;
    final source = _source = UiArtImageSource(art);
    unawaited(
      source.prepare(devicePixelRatio: ratio, only: StarRow.slots).then((_) {
        final controller = _controller;
        // A raster that lands after the file drew its rest frame: repaint
        // it (a playing clip repaints itself).
        if (mounted && controller != null && !controller.isPlaying) {
          controller.seek(_restFrame);
        }
      }),
    );
  }

  FxMarker? _marker(String name) {
    for (final marker in fxSpecOf(FxId.uiStars).markers) {
      if (marker.name == name) return marker;
    }
    return null;
  }

  void _schedule({required bool reduced}) {
    final count = widget.count.clamp(0, 3);
    if (count == 0) return;
    final controller = _controller!;
    if (reduced) {
      // Q146: star_n's last frame at once, one cue for the highest star.
      _timers.add(
        Timer(widget.delay, () {
          if (!mounted) return;
          final last = _marker('star_$count');
          if (last != null) {
            _restFrame = last.end;
            controller.seek(last.end);
          }
          setState(() => _landed = count);
          widget.onStar?.call(count);
        }),
      );
      return;
    }
    var at = widget.delay;
    for (var i = 1; i <= count; i++) {
      final marker = _marker('star_$i');
      final ms = marker?.durationMs ?? StarMotionTokens.perStarMs.toDouble();
      final star = i;
      _timers.add(
        Timer(at, () {
          if (!mounted) return;
          controller.playMarker('star_$star');
          if (marker != null) _restFrame = marker.end;
          setState(() => _landed = star);
          widget.onStar?.call(star);
        }),
      );
      at += Duration(microseconds: (ms * 1000).round());
    }
    if (count == 3) {
      final flourish = _marker('flourish');
      _timers.add(
        Timer(at, () {
          if (!mounted) return;
          controller.playMarker('flourish');
          if (flourish != null) _restFrame = flourish.end;
        }),
      );
      final flourishMs = flourish?.durationMs ?? 1000;
      _timers.add(
        Timer(at + Duration(microseconds: (flourishMs * 1000).round()), () {
          if (mounted) widget.onFlourishEnd?.call();
        }),
      );
    }
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _controller?.dispose();
    super.dispose();
  }

  String _label(BuildContext context, int count) => widget.newBest
      ? context.localizations.starsNewBestSemantics(count)
      : context.localizations.starsSemantics(count);

  @override
  Widget build(BuildContext context) {
    final count = widget.count.clamp(0, 3);
    if (!widget.reveal) return _atRest(context, count);
    return Semantics(
      label: _label(context, count),
      excludeSemantics: true,
      child: SizedBox.fromSize(
        size: StarRow.canvas,
        child: LottieFxView(
          key: StarRow.revealKey,
          id: FxId.uiStars,
          controller: _controller,
          library: widget.library,
          images: _source,
          fallback: _Fallback(count: count, landed: _landed),
        ),
      ),
    );
  }

  Widget _atRest(BuildContext context, int count) {
    final size = widget.size;
    final middle = widget.middleSize ?? size;
    return Semantics(
      label: _label(context, count),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) SizedBox(width: size * StarRow.gapRatio),
            UiArtImage.square(
              i < count ? UiArt.starFilled : UiArt.starEmpty,
              extent: i == 1 ? middle : size,
              key: StarRow.fallbackKey(i + 1, filled: i < count),
            ),
          ],
        ],
      ),
    );
  }
}

/// The reveal's stand-in while `ui_stars` isn't available (rule 3): the
/// same art at the file's star centres, filled as their segments start.
class _Fallback extends StatelessWidget {
  const _Fallback({required this.count, required this.landed});

  final int count;
  final int landed;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      for (var i = 0; i < 3; i++)
        Positioned(
          left: StarRow.centres[i].dx - StarRow.sizeWin / 2,
          top: StarRow.centres[i].dy - StarRow.sizeWin / 2,
          child: UiArtImage.square(
            i < landed && i < count ? UiArt.starFilled : UiArt.starEmpty,
            extent: StarRow.sizeWin,
            key: StarRow.fallbackKey(i + 1, filled: i < landed && i < count),
          ),
        ),
    ],
  );
}
