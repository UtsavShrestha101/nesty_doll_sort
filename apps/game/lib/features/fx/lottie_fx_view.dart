import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/features/fx/fx_drawable.dart';
import 'package:nesty_game/features/fx/fx_drawable_params.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_images.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/fx_player.dart';
import 'package:nesty_game/features/fx/fx_spec.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';
import 'package:nesty_game/features/fx/fx_text_overlay.dart';

/// Plays one widget-hosted file in a [LottieFxView] (m2-lottie-design §2
/// "Widgets"): the plan, the per-use [params] and [images], and reduced
/// motion (§13). Independent of the composition, so it can be set up
/// before the library has loaded.
///
/// Listeners are notified on every frame change (the view repaints from
/// them, with no widget rebuild) and when [isPlaying] changes.
class LottieFxController extends ChangeNotifier {
  LottieFxController(this.id)
    : spec = fxSpecOf(id),
      player = FxPlayer.forSpec(fxSpecOf(id));

  final FxId id;
  final FxSpec spec;

  /// Sizes, fills and captured transforms; read by the delegates.
  final FxDrawableParams params = FxDrawableParams();

  /// The image source and request (doll colours for `doll_idle` and
  /// `doll_win_hop`); the view sets the library's blank.
  final FxImages images = FxImages();

  final FxPlayer player;

  /// Called on the tick a one-shot reaches its end.
  VoidCallback? onFinished;

  /// Builds the current plan; rebuilt when reduced motion flips. Null
  /// while resting or seeking.
  FxPlan? Function()? _builder;
  double _startMs = 0;
  bool _reducedMotion = false;
  bool _disposed = false;

  bool get isPlaying => player.isPlaying;

  /// Set by the view from `MediaQuery.disableAnimationsOf` (D48). Changing
  /// it re-plans the current playback.
  bool get reducedMotion => _reducedMotion;
  set reducedMotion(bool value) {
    if (value == _reducedMotion) return;
    _reducedMotion = value;
    params.reducedMotion = value;
    if (_builder != null) _start(_startMs + player.elapsedMs);
  }

  /// True when nothing is drawn under reduced motion (`fx_confetti`).
  bool get isSkipped => FxMotionPolicy.isSkipped(id, reduced: _reducedMotion);

  /// Plays the whole file: looping when it loops, once otherwise; ambient
  /// loops rest on frame 0 under reduced motion. [startMs] offsets the
  /// start (the random phase of idle dolls), [speed] scales it (their
  /// 0.8–1.2 speed).
  void playWhole({double speed = 1, double startMs = 0, bool? loop}) {
    _builder = () =>
        FxPlan.whole(spec, reduced: _reducedMotion, speed: speed, loop: loop);
    _start(startMs);
  }

  /// Plays the marker [segment] once, then [thenMarker] looping, with the
  /// reduced-motion policy (a one-shot at 2×, an informational loop at 1×,
  /// an ambient one dropped). Does nothing when the file has no such
  /// marker (rule 3).
  void playMarker(
    String segment, {
    String? thenMarker,
    bool loop = false,
    double speed = 1,
  }) {
    _builder = () => FxPlan.marker(
      spec,
      segment,
      thenMarker: thenMarker,
      loop: loop,
      reduced: _reducedMotion,
      speed: speed,
    );
    _start(0);
  }

  /// Rests on [frame] (the toggle's on/off look).
  void rest(double frame) {
    _builder = null;
    player.rest(frame);
    _notify();
  }

  /// Shows [frame] without playing: the splash loader's
  /// `frame = progress %`.
  void seek(double frame) {
    _builder = null;
    player.seek(frame);
    _notify();
  }

  /// Advances by [dtMs] (the view's ticker).
  void advance(double dtMs) {
    if (!player.isPlaying) return;
    final finished = player.advance(dtMs);
    _notify();
    if (finished) onFinished?.call();
  }

  void _start(double startMs) {
    final plan = _builder?.call();
    if (plan == null) {
      _builder = null;
      return;
    }
    _startMs = startMs;
    player.start(plan, startMs: startMs);
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// A widget-hosted file (the HUD, overlays and screens): a `CustomPaint`
/// over one `LottieDrawable` in its own `RepaintBoundary`, repainted from
/// its [controller] by a ticker that runs only while it plays, so a paused
/// view costs nothing and a playing one never repaints its neighbours
/// (m2-lottie-design §2, §14). Never use `Lottie.asset`: it decodes the
/// placeholder PNGs.
///
/// - The composition comes from [library] (the DI one by default); until
///   it is loaded, or if it failed (rule 3), [fallback] shows, with the
///   label at its rest position so the text is never lost.
/// - For the text files (`ui_family_counter`, `ui_win_ribbon`,
///   `ui_chapter_ribbon`) the Lottie text layers are hidden and [label] is
///   painted following the file's null (§12); [previousLabel] shows until
///   the counter's swap frame while it plays.
/// - Reduced motion comes from `MediaQuery.disableAnimationsOf` unless
///   [reducedMotion] is given.
/// - Without a [controller] it makes its own and, when [autoplay] is set,
///   plays the whole file (looping when the file loops).
class LottieFxView extends StatefulWidget {
  const LottieFxView({
    required this.id,
    this.controller,
    this.library,
    this.images,
    this.label,
    this.previousLabel,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.fallback,
    this.reducedMotion,
    this.autoplay = true,
    super.key,
  });

  final FxId id;
  final LottieFxController? controller;
  final FxLibrary? library;

  /// The rasters of the file's image slots (doll parts for `doll_idle` and
  /// `doll_win_hop`).
  final FxImageSource? images;

  final String? label;
  final String? previousLabel;
  final BoxFit fit;
  final Alignment alignment;

  /// Drawn when the composition isn't available.
  final Widget? fallback;

  final bool? reducedMotion;

  /// With an internal controller: play the whole file on first build.
  final bool autoplay;

  @override
  State<LottieFxView> createState() => _LottieFxViewState();
}

class _LottieFxViewState extends State<LottieFxView>
    with SingleTickerProviderStateMixin {
  LottieFxController? _ownController;
  late LottieFxController _controller;
  FxLibrary? _library;
  FxDrawable? _drawable;
  FxTextOverlay? _overlay;
  Ticker? _ticker;
  Duration _lastTick = Duration.zero;
  FxLibrary? _awaiting;

  @override
  void initState() {
    super.initState();
    _bindController();
    _bindLibrary();
    if (widget.controller == null && widget.autoplay) {
      _controller.playWhole();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.reducedMotion =
        widget.reducedMotion ??
        MediaQuery.maybeDisableAnimationsOf(context) ??
        false;
    _syncOverlay();
  }

  @override
  void didUpdateWidget(LottieFxView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.id != widget.id) {
      _controller.removeListener(_onControllerChanged);
      _ownController?.dispose();
      _ownController = null;
      _drawable = null;
      _overlay?.dispose();
      _overlay = null;
      _bindController();
      if (widget.controller == null && widget.autoplay) {
        _controller.playWhole();
      }
      _syncTicker();
    }
    if (oldWidget.library != widget.library) {
      _drawable = null;
      _syncTicker();
      _bindLibrary();
    }
    _controller.reducedMotion =
        widget.reducedMotion ??
        MediaQuery.maybeDisableAnimationsOf(context) ??
        false;
    _buildDrawable();
    _syncOverlay();
  }

  void _bindController() {
    final external = widget.controller;
    assert(
      external == null || external.id == widget.id,
      'the controller plays ${external.id.fileName}, not ${widget.id.fileName}',
    );
    _controller = external ?? (_ownController = LottieFxController(widget.id));
    _controller.addListener(_onControllerChanged);
  }

  void _bindLibrary() {
    final library =
        widget.library ??
        (get.isRegistered<FxLibrary>() ? get<FxLibrary>() : null);
    _library = library;
    _buildDrawable();
    if (library != null && _drawable == null && !library.isLoaded) {
      _waitForLibrary(library);
    }
  }

  void _waitForLibrary(FxLibrary library) {
    if (identical(_awaiting, library)) return;
    _awaiting = library;
    void check(double _) {
      if (!mounted || _drawable != null || !identical(library, _library)) {
        return;
      }
      if (library[widget.id] != null) setState(_buildDrawable);
    }

    library.load(onProgress: check).then((_) {
      if (identical(_awaiting, library)) _awaiting = null;
      check(1);
    });
  }

  void _buildDrawable() {
    final images = _controller.images..source = widget.images;
    if (_drawable != null) return;
    final library = _library;
    final composition = library?[widget.id];
    if (library == null || composition == null) return;
    images.blank = library.blank;
    _drawable = FxDrawable(
      composition,
      spec: _controller.spec,
      params: _controller.params,
      images: images,
      player: _controller.player,
    );
    _syncTicker();
  }

  void _syncOverlay() {
    final hook = FxTextHook.of(widget.id);
    final label = widget.label;
    if (hook == null || label == null) {
      _overlay?.dispose();
      _overlay = null;
      return;
    }
    final direction = Directionality.maybeOf(context) ?? TextDirection.ltr;
    var overlay = _overlay;
    if (overlay == null || overlay.textDirection != direction) {
      overlay?.dispose();
      overlay = _overlay = FxTextOverlay(hook, textDirection: direction);
    }
    overlay
      ..label = label
      ..previousLabel = widget.previousLabel;
  }

  void _onControllerChanged() => _syncTicker();

  void _syncTicker() {
    final shouldTick = _drawable != null && _controller.isPlaying;
    final ticker = _ticker;
    if (shouldTick && (ticker == null || !ticker.isActive)) {
      _lastTick = Duration.zero;
      (_ticker ??= createTicker(_onTick)).start();
    } else if (!shouldTick && ticker != null && ticker.isActive) {
      ticker.stop();
    }
  }

  void _onTick(Duration elapsed) {
    final dt = elapsed - _lastTick;
    _lastTick = elapsed;
    _controller.advance(dt.inMicroseconds / 1000);
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _controller.removeListener(_onControllerChanged);
    _ownController?.dispose();
    _overlay?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spec = _controller.spec;
    final clip = _drawable;
    final painter = _FxPainter(
      clip: _controller.isSkipped ? null : clip,
      controller: _controller,
      overlay: _overlay,
      canvas: Size(spec.width, spec.height),
      fit: widget.fit,
      alignment: widget.alignment,
      source: widget.images,
      label: widget.label,
      previousLabel: widget.previousLabel,
    );
    // Its own layer (rule 8): a playing or looping clip repaints only
    // itself at 60 fps, and a resting one replays its recorded layer when
    // anything around it repaints. Without it, each tick marks the whole
    // route's layer dirty and re-records every surface, text and resting
    // clip on the page (Home's idle dolls and twinkles, the win overlay).
    final paint = RepaintBoundary(
      child: CustomPaint(size: Size(spec.width, spec.height), painter: painter),
    );
    final fallback = widget.fallback;
    if (clip != null || fallback == null) return paint;
    return Stack(
      alignment: widget.alignment,
      children: [
        Positioned.fill(child: fallback),
        Positioned.fill(child: paint),
      ],
    );
  }
}

/// Paints the clip (and the label) fitted into the widget's box. Repaints
/// from the controller; everything per frame is cached (rule 8).
final class _FxPainter extends CustomPainter {
  _FxPainter({
    required this.clip,
    required this.controller,
    required this.overlay,
    required this.canvas,
    required this.fit,
    required this.alignment,
    required this.source,
    required this.label,
    required this.previousLabel,
  }) : super(repaint: controller);

  // Not painted directly: a resting view repaints when they change.
  final FxImageSource? source;
  final String? label;
  final String? previousLabel;

  final FxDrawable? clip;
  final LottieFxController controller;
  final FxTextOverlay? overlay;
  final Size canvas;
  final BoxFit fit;
  final Alignment alignment;

  Size? _fittedFor;
  double _scaleX = 1;
  double _scaleY = 1;
  double _dx = 0;
  double _dy = 0;

  void _fitTo(Size size) {
    final fitted = applyBoxFit(fit, canvas, size);
    final destination = fitted.destination;
    final rect = alignment.inscribe(destination, Offset.zero & size);
    _scaleX = destination.width / canvas.width;
    _scaleY = destination.height / canvas.height;
    _dx = rect.left;
    _dy = rect.top;
    _fittedFor = size;
  }

  // ── Hot path: every repaint while playing. ──

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    if (_fittedFor != size) _fitTo(size);
    canvas
      ..save()
      ..translate(_dx, _dy)
      ..scale(_scaleX, _scaleY);
    final clip = this.clip;
    final overlay = this.overlay;
    if (clip != null) {
      clip.draw(canvas);
      overlay?.paint(
        canvas,
        clip.params,
        frame: clip.player.frame,
        playing: clip.player.isPlaying,
      );
    } else {
      overlay?.paintAtRest(canvas);
    }
    canvas.restore();
  }

  // ── End of hot path. ──

  @override
  bool shouldRepaint(_FxPainter oldDelegate) =>
      !identical(oldDelegate.clip, clip) ||
      !identical(oldDelegate.controller, controller) ||
      !identical(oldDelegate.overlay, overlay) ||
      oldDelegate.fit != fit ||
      oldDelegate.alignment != alignment ||
      oldDelegate.canvas != canvas ||
      !identical(oldDelegate.source, source) ||
      oldDelegate.label != label ||
      oldDelegate.previousLabel != previousLabel;
}
