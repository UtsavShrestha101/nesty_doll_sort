import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/services.dart' show rootBundle;
import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/repository/bundled_catalog_repository.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';
import 'package:nesty_game/features/museum/widgets/figurine_image.dart';

/// Decodes the collected figurine's art at [pixels] square for the Lottie's
/// `figurine` slot, or null when it can't (rule 3: the still art stays).
typedef FigurineRasterLoader =
    Future<ui.Image?> Function(String asset, int pixels);

/// A collected family's figurine in its Museum niche (frame 6.1; tokens
/// `motion.museumIdle`, m7-4 J.2): `ui_museum_idle` looping on the figurine,
/// a 3 dp bob with a breathing shadow and two twinkles, each niche starting
/// at its own random frame. Under reduce motion the clip rests on frame 0.
///
/// The file's canvas is 90×90 with the figurine's base at (45, 80); this
/// widget's box is the 62 dp art box, so the canvas hangs 14 dp out each
/// side and 10 dp under it, over the niche's floor and neighbours. Until the
/// file and the art are ready, or if either fails, the still [FigurineImage]
/// shows (the same pose as frame 0).
class MuseumIdleFigurine extends StatefulWidget {
  const MuseumIdleFigurine({
    required this.figurineId,
    this.library,
    this.loadRaster = defaultRasterLoader,
    super.key,
  });

  final String figurineId;

  /// The FX library (the DI one by default).
  final FxLibrary? library;

  final FigurineRasterLoader loadRaster;

  /// The art box, dp (`layout.museum.cabinet.art`).
  static const double box = MuseumTokens.cabinetArt;

  /// Where the file's canvas sits against the art box: the figurine's base
  /// (45, 80) goes on the box's bottom centre.
  static const double canvasLeft = (box - MuseumIdleTokens.canvas) / 2;
  static const double canvasTop = box - 80;

  /// The start offset, in ms into the 4 s loop, of niche [figurineId]: the
  /// same on every visit (a seeded draw) and different between niches.
  static double startMsOf(String figurineId) {
    final span = fxSpecOf(FxId.uiMuseumIdle).durationMs;
    final seed = figurineId.codeUnits.fold<int>(
      17,
      (hash, unit) => (hash * 31 + unit) & 0x7fffffff,
    );
    return math.Random(seed).nextDouble() * span;
  }

  static final Map<String, Future<ui.Image?>> _decoded = {};

  /// Reads `assets/museum/NN-<id>.png` and scales it to [pixels]. One decode
  /// per figurine and size for the app's lifetime (ten small images).
  static Future<ui.Image?> defaultRasterLoader(String asset, int pixels) =>
      _decoded['$asset@$pixels'] ??= _decode(asset, pixels);

  static Future<ui.Image?> _decode(String asset, int pixels) async {
    try {
      final data = await rootBundle.load(asset);
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: pixels,
        targetHeight: pixels,
      );
      final frame = await codec.getNextFrame();
      codec.dispose();
      return frame.image;
    } on Object {
      return null;
    }
  }

  @override
  State<MuseumIdleFigurine> createState() => _MuseumIdleFigurineState();
}

class _MuseumIdleFigurineState extends State<MuseumIdleFigurine> {
  late final LottieFxController _controller = LottieFxController(
    FxId.uiMuseumIdle,
  );
  _FigurineSource? _source;
  bool _reduced = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(MuseumIdleFigurine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.figurineId != widget.figurineId) {
      _source = null;
      _started = false;
      _decode();
    }
  }

  Future<void> _decode() async {
    final index = BundledCatalogRepository.figurineIds.indexOf(
      widget.figurineId,
    );
    if (index < 0) return;
    final asset = BundledCatalogRepository.figurineArt(
      index + 1,
      widget.figurineId,
    );
    final id = widget.figurineId;
    final dpr = WidgetsBinding.instance.platformDispatcher.views.isEmpty
        ? 3.0
        : WidgetsBinding
              .instance
              .platformDispatcher
              .views
              .first
              .devicePixelRatio;
    final pixels = (MuseumIdleFigurine.box * dpr).ceil();
    final image = await widget.loadRaster(asset, pixels);
    if (!mounted || image == null || id != widget.figurineId) return;
    setState(() {
      _source = _FigurineSource(
        FxRaster(image, scale: image.width / MuseumIdleFigurine.box),
      );
      _started = false;
      _play();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = context.reduceMotion;
    if (reduced != _reduced || !_started) {
      _reduced = reduced;
      _play();
    }
  }

  void _play() {
    if (_source == null) return;
    _started = true;
    // `ui_museum_idle` rests on frame 0 under reduce motion (LOTTIE.md "When
    // each one plays"); an ambient loop, so never the one-shot 2× speed.
    if (_reduced) {
      _controller.rest(0);
    } else {
      _controller.playWhole(
        startMs: MuseumIdleFigurine.startMsOf(widget.figurineId),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final source = _source;
    final library =
        widget.library ??
        (get.isRegistered<FxLibrary>() ? get<FxLibrary>() : null);
    // The still figurine until the file and the art are both ready, or for
    // good when either failed (rule 3): the clip never draws over it.
    if (source == null ||
        library == null ||
        library[FxId.uiMuseumIdle] == null) {
      return FigurineImage(
        figurineId: widget.figurineId,
        size: MuseumIdleFigurine.box,
      );
    }
    return SizedBox.square(
      dimension: MuseumIdleFigurine.box,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: MuseumIdleFigurine.canvasLeft,
            top: MuseumIdleFigurine.canvasTop,
            width: MuseumIdleTokens.canvas,
            height: MuseumIdleTokens.canvas,
            child: Semantics(
              label: context.localizations.figurineName(widget.figurineId),
              image: true,
              excludeSemantics: true,
              child: LottieFxView(
                id: FxId.uiMuseumIdle,
                controller: _controller,
                library: library,
                images: source,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _FigurineSource implements FxImageSource {
  _FigurineSource(this.raster);

  final FxRaster raster;

  @override
  FxRaster? rasterFor(FxImageSlot slot, FxImageRequest request) =>
      slot == FxImageSlot.figurine ? raster : null;
}
