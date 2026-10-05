import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';
import 'package:nesty_render/nesty_render.dart';

/// One doll outside the board, playing a widget-hosted doll file: the
/// splash and Home shelves' `doll_idle` and the win overlay's `doll_win_hop`
/// (LOTTIE.md "When each one plays"; m2-lottie-design §15).
///
/// The widget is the file's 160×260 canvas at 1:1; its parent places it
/// with [anchor] (the doll's base, (80, 230)) on the shelf point (see
/// [LottieDoll.positioned]). The doll's `doll_size` is `height / 150`.
///
/// The art comes from [images] (a `LevelSkin.images` holding this colour's
/// part rasters). When it has none for [color] (the fake env, a skin that
/// failed) or the composition didn't load (rule 3), the doll is drawn still
/// by [renderer] (the procedural placeholder by default, spec §12.5).
/// Reduced motion rests the ambient loops on frame 0 (D48).
class LottieDoll extends StatefulWidget {
  const LottieDoll({
    required this.id,
    required this.color,
    required this.height,
    this.images,
    this.renderer,
    this.symbols = DollSymbols.subtle,
    this.speed = 1,
    this.phaseMs = 0,
    this.startDelay = Duration.zero,
    this.library,
    super.key,
  }) : assert(
         id == FxId.dollIdle || id == FxId.dollWinHop,
         'a widget-hosted doll file',
       );

  /// `doll_idle` or `doll_win_hop`.
  final FxId id;
  final DollColor color;

  /// The doll's height in logical px (the full 768-unit artboard).
  final double height;
  final FxImageSource? images;
  final DollRenderer? renderer;
  final DollSymbols symbols;

  /// Playback speed (Home's idle dolls: 0.8–1.2).
  final double speed;

  /// How far into its loop the doll starts (a random phase).
  final double phaseMs;

  /// Rests on frame 0 this long before playing (the win families' 150 ms
  /// stagger).
  final Duration startDelay;

  /// The DI library by default.
  final FxLibrary? library;

  /// The file's canvas.
  static const Size canvas = Size(160, 260);

  /// The doll's base on the canvas (LOTTIE.md "doll base (80, 230)").
  static const Offset anchor = Offset(80, 230);

  /// A 1-unit doll is this tall (LOTTIE.md "At 100 % the doll is 150 dp").
  static const double unitHeight = 150;

  /// [doll] in a [Stack], its base on ([centerX], [baseY]).
  static Widget positioned({
    required double centerX,
    required double baseY,
    required Widget doll,
  }) => Positioned(
    left: centerX - anchor.dx,
    top: baseY - anchor.dy,
    width: canvas.width,
    height: canvas.height,
    child: IgnorePointer(child: doll),
  );

  @override
  State<LottieDoll> createState() => _LottieDollState();
}

class _LottieDollState extends State<LottieDoll> {
  static final DollRenderer _placeholder = PlaceholderDollPainter();

  late LottieFxController _controller;
  Timer? _start;

  @override
  void initState() {
    super.initState();
    _controller = _newController();
  }

  LottieFxController _newController() {
    final controller = LottieFxController(widget.id);
    controller.images.request.doll = widget.color;
    controller.params.setSize(
      FxRole.doll,
      widget.height / LottieDoll.unitHeight,
    );
    if (widget.startDelay > Duration.zero) {
      controller.rest(0);
      _start = Timer(widget.startDelay, () {
        if (mounted) _play(controller);
      });
    } else {
      _play(controller);
    }
    return controller;
  }

  void _play(LottieFxController controller) =>
      controller.playWhole(speed: widget.speed, startMs: widget.phaseMs);

  @override
  void didUpdateWidget(LottieDoll oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _start?.cancel();
      final old = _controller;
      _controller = _newController();
      // The view unbinds from the old controller when it rebuilds.
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
      return;
    }
    if (oldWidget.color != widget.color) {
      _controller.images.request.doll = widget.color;
      _controller.params.markChanged();
    }
    if (oldWidget.height != widget.height) {
      _controller.params.setSize(
        FxRole.doll,
        widget.height / LottieDoll.unitHeight,
      );
    }
  }

  @override
  void dispose() {
    _start?.cancel();
    _controller.dispose();
    super.dispose();
  }

  bool get _hasArt {
    final images = widget.images;
    if (images == null) return false;
    final request = _controller.images.request;
    return images.rasterFor(FxImageSlot.dollLid, request) != null &&
        images.rasterFor(FxImageSlot.dollBody, request) != null;
  }

  @override
  Widget build(BuildContext context) {
    final still = _StillDoll(
      renderer: widget.renderer ?? _placeholder,
      color: widget.color,
      height: widget.height,
      symbols: widget.symbols,
    );
    if (!_hasArt) return still;
    return LottieFxView(
      id: widget.id,
      controller: _controller,
      library: widget.library,
      images: widget.images,
      fallback: still,
    );
  }
}

/// The rest pose on the 160×260 canvas, drawn by a [DollRenderer].
class _StillDoll extends StatelessWidget {
  const _StillDoll({
    required this.renderer,
    required this.color,
    required this.height,
    required this.symbols,
  });

  final DollRenderer renderer;
  final DollColor color;
  final double height;
  final DollSymbols symbols;

  @override
  Widget build(BuildContext context) {
    final width = height * DollArt.width / DollArt.height;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: LottieDoll.anchor.dx - width / 2,
          top: LottieDoll.anchor.dy - height * DollArt.base.dy / DollArt.height,
          width: width,
          height: height,
          child: CustomPaint(
            painter: DollPainter(
              renderer: renderer,
              color: color,
              symbols: symbols,
            ),
          ),
        ),
      ],
    );
  }
}

/// One `fx_twinkle` star (LOTTIE.md: Splash, Home, Win; 2.0–2.4 s with a
/// random phase), [size] across, tinted [color] (`#FFF3B0` or `#F5B418`).
/// Decorative: nothing is drawn when the file is missing, and it rests on
/// frame 0 under reduced motion.
class LottieTwinkle extends StatefulWidget {
  const LottieTwinkle({
    required this.size,
    this.color = const Color(0xFFFFF3B0),
    this.periodMs = 2000,
    this.phaseMs = 0,
    this.once = false,
    this.library,
    super.key,
  });

  final double size;
  final Color color;

  /// Plays one twinkle and stops on its last frame, instead of looping.
  final bool once;

  /// One twinkle's length; the file's is 2000 ms.
  final double periodMs;
  final double phaseMs;
  final FxLibrary? library;

  /// The file's own period (120 f at 60 fps).
  static const double filePeriodMs = 2000;

  @override
  State<LottieTwinkle> createState() => _LottieTwinkleState();
}

class _LottieTwinkleState extends State<LottieTwinkle> {
  late final LottieFxController _controller = LottieFxController(
    FxId.fxTwinkle,
  );

  @override
  void initState() {
    super.initState();
    _controller.params.tintColor = widget.color;
    _controller.playWhole(
      speed: LottieTwinkle.filePeriodMs / widget.periodMs,
      startMs: widget.phaseMs,
      loop: widget.once ? false : null,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: SizedBox.square(
      dimension: widget.size,
      child: LottieFxView(
        id: FxId.fxTwinkle,
        controller: _controller,
        library: widget.library,
      ),
    ),
  );
}
