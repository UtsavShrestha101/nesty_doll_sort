import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/art/ui_art_library.dart';
import 'package:nesty_game/core/ui/widgets/race/rival_portrait.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';
import 'package:nesty_game/features/fx/rival_portrait_image_source.dart';

/// How a rival's portrait reacts on a result card (tokens.json
/// `motion.rivalReact.segments`): it hops when it finishes first, nods when
/// the player does.
enum RivalReaction {
  /// The computer finished first (9.5): a hop with confetti bits.
  win('win'),

  /// The player finished first (9.4): a friendly nod.
  lose('lose');

  const RivalReaction(this.marker);

  /// The `ui_rival_react` segment.
  final String marker;
}

/// A rival's portrait that breathes and reacts (m7-4 C.6, tokens.json
/// `motion.rivalReact`; LOTTIE.md `ui_rival_react`): the file's `idle` loop,
/// `family` (a ring and two sparkles) each time [familyCount] rises, and
/// [reaction]'s `win` or `lose` once when it first shows, then `idle` again.
///
/// It takes the layout of a [RivalPortrait] of [size] (38 in the strip, 56
/// on a result card); the file's 120×120 canvas is [size] × 120/96, 47.5 and
/// 70 dp, and spills past the portrait for its sparkles and bits. The ring
/// and drop are drawn here, under the file.
///
/// Under reduced motion it rests on frame 0, still. Without the file (rule
/// 3) the static [RivalPortrait] stands in.
class RivalReact extends StatefulWidget {
  const RivalReact({
    required this.number,
    required this.size,
    this.reaction,
    this.familyCount = 0,
    this.library,
    this.uiArt,
    super.key,
  });

  /// The rival, 1–3.
  final int number;

  /// The portrait's diameter in dp.
  final double size;

  /// A result card's one-shot, played on the first frame.
  final RivalReaction? reaction;

  /// How many families the rival has completed: the `family` segment plays
  /// each time it rises.
  final int familyCount;

  /// The FX library (the DI one by default) and the UI art behind the
  /// portrait (the DI one by default).
  final FxLibrary? library;
  final UiArtLibrary? uiArt;

  /// The file's canvas over the portrait: 120 / 96.
  static const double canvasRatio = 120 / 96;

  /// The portrait's centre in the file's canvas (60, 64).
  static const Offset portraitCentre = Offset(60, 64);

  /// The file's portrait is 96 dp at 100 %.
  static const double portraitSize = 96;

  @override
  State<RivalReact> createState() => _RivalReactState();
}

class _RivalReactState extends State<RivalReact> {
  late final LottieFxController _controller = LottieFxController(
    FxId.uiRivalReact,
  );
  RivalPortraitImageSource? _source;
  UiArtLibrary? _art;
  int? _number;
  double? _ratio;
  bool? _reduceMotion;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prepareArt();
    final reduce = context.reduceMotion;
    final first = _reduceMotion == null;
    if (_reduceMotion == reduce) return;
    _reduceMotion = reduce;
    // The first build plays the reaction; a later OS toggle rests the
    // portrait or resumes the idle loop.
    _play(first ? widget.reaction?.marker : null);
  }

  @override
  void didUpdateWidget(RivalReact oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) {
      _prepareArt();
    }
    if (widget.familyCount > oldWidget.familyCount) _play('family');
  }

  /// Plays [segment] once, then the idle loop; or only the loop.
  void _play(String? segment) {
    if (context.reduceMotion) {
      _controller.rest(0);
      return;
    }
    if (segment == null) {
      _controller.playMarker('idle', loop: true);
    } else {
      _controller.playMarker(segment, thenMarker: 'idle');
    }
  }

  void _prepareArt() {
    final art = widget.uiArt ?? UiArtLibrary.of(context);
    final ratio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
    if (art == null ||
        (identical(art, _art) && ratio == _ratio && widget.number == _number)) {
      return;
    }
    _art = art;
    _ratio = ratio;
    _number = widget.number;
    final source = _source = RivalPortraitImageSource(art, widget.number);
    unawaited(
      source.prepare(devicePixelRatio: ratio).then((_) {
        // A raster that lands after a resting frame drew: repaint it.
        if (mounted && !_controller.isPlaying) _controller.rest(0);
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final k = size / RivalReact.portraitSize;
    final canvas = 120 * k;
    return SizedBox.square(
      dimension: size,
      child: ExcludeSemantics(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFFDF7),
                  boxShadow: RivalPortrait.plainShadows,
                ),
              ),
            ),
            Positioned(
              left: size / 2 - RivalReact.portraitCentre.dx * k,
              top: size / 2 - RivalReact.portraitCentre.dy * k,
              width: canvas,
              height: canvas,
              child: LottieFxView(
                id: FxId.uiRivalReact,
                controller: _controller,
                library: widget.library,
                images: _source,
                fallback: Stack(
                  children: [
                    Positioned(
                      left: (canvas - size) / 2,
                      top: RivalReact.portraitCentre.dy * k - size / 2,
                      width: size,
                      height: size,
                      child: RivalPortrait(
                        number: widget.number,
                        size: size,
                        ring: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
