import 'dart:async' show unawaited;
import 'dart:math' as math;
import 'dart:typed_data' show Float64List;
import 'dart:ui' as ui show Image;
import 'dart:ui'
    show
        Canvas,
        Color,
        FilterQuality,
        ImageShader,
        Offset,
        Paint,
        Rect,
        Size,
        TileMode;

import 'package:flutter/foundation.dart' show ChangeNotifier, debugPrint;
import 'package:flutter/services.dart' show AssetBundle;
import 'package:flutter_svg/flutter_svg.dart' show PictureInfo;
import 'package:nesty_render/src/board/board_geometry.dart';
import 'package:nesty_render/src/board/board_layout_constants.dart';
import 'package:nesty_render/src/board/board_shape.dart';
import 'package:nesty_render/src/raster/svg_raster.dart';
import 'package:nesty_render/src/tokens/render_tokens.gen.dart';

typedef _K = BoardLayoutConstants;

/// The 18 board pieces in `apps/game/assets/board/` (the design's
/// `design/board/`, synced by `sync_design_assets`), each with the box it is
/// drawn in on the 390×844 reference board, in reference px.
///
/// Every box comes from `design/prototypes/NestyBoard.dc.html`. Multiply it
/// by `SlotGeometry.furnitureScale` for a slot's piece, or by
/// `BoardGeometry.scale` for the plank.
enum BoardSprite {
  /// The stand under open and locked slots. NestyBoard:163.
  slotStand('slot-stand-blank', BoardTokens.standSize),

  /// The taller tower stand (spec §3.2). NestyBoard:163.
  towerBase('tower-base-blank', BoardTokens.towerStandSize),

  /// The pulsing booster stand (spec §3.6). It uses the plain stand's box.
  /// NestyBoard:163.
  extraSlot('extra-slot', BoardTokens.standSize),

  /// The shelf strip, tiled across the screen width. It is 40 tall, and
  /// `auto` wide from the art's own 390:40 ratio. NestyBoard:12.
  shelfPlank('shelf-plank', Size(_K.referenceWidth, _K.plankHeight)),

  /// Selection and hint-target glow. NestyBoard:167.
  glowRing('glow-ring', Size(_K.glowRingWidth, _K.glowRingHeight)),

  /// The hint's bouncing arrow. NestyBoard:208.
  hintArrow('hint-arrow', Size(_K.hintArrowWidth, _K.hintArrowHeight)),

  /// Glass case, intact (spec §3.3). NestyBoard:169.
  glassCase0('glass-case-0', BoardTokens.glassCaseSize),

  /// Glass case, cracked: the unlock clip's 200 ms frame.
  glassCase1('glass-case-1', BoardTokens.glassCaseSize),

  /// Glass case, shattered: the unlock clip's 400 ms frame.
  glassCase2('glass-case-2', BoardTokens.glassCaseSize),

  /// The tall glass case (m7-3, tokens v3 `layout.board.glassCaseTall`):
  /// over a sealed doll taller than `GlassCaseTallTokens.minDollHeight`
  /// (sizes 5 and 6), intact, cracked and shattered like [glassCase0]…
  /// [glassCase2]. Its box is `0.62h × 1.0133h` for the 150-unit reference
  /// doll: 93×152. `fx_glass_unlock_tall` plays over it (phase 4
  /// architecture §2.3; lane B places it).
  glassCaseTall0('glass-case-tall-0', glassCaseTallSize),
  glassCaseTall1('glass-case-tall-1', glassCaseTallSize),
  glassCaseTall2('glass-case-tall-2', glassCaseTallSize),

  /// Ice frames 0–3 (spec §3.4, `BoardLayout.iceFrame`). NestyBoard:180.
  ice0('ice-0', BoardTokens.iceOverlaySize),
  ice1('ice-1', BoardTokens.iceOverlaySize),
  ice2('ice-2', BoardTokens.iceOverlaySize),
  ice3('ice-3', BoardTokens.iceOverlaySize),

  /// The ice's final burst.
  iceShatter('ice-shatter', BoardTokens.iceOverlaySize),

  /// The family counter's 12×18 doll icon, an alpha mask the HUD tints
  /// `#FFE3B8` (NestyBoard:31). The HUD is not board-scaled, so request it
  /// at furniture scale 1.
  ///
  /// The same art is the wood-grain blank every buried tower nest shows,
  /// for every skin (tokens `layout.towerSilhouettes`, owner decision 3e,
  /// 2026-09-26): `DollPartRasters` draws it on the whole 512×768 artboard
  /// through [BoardSpriteLibrary.rasterizeArtboard], and the doll renderer
  /// draws that raster at each nest's true size (D21).
  dollSilhouette('doll-silhouette', Size(12, 18));

  const BoardSprite(this.assetName, this.designSize);

  /// The three pieces a chapter's own board wood replaces (tokens v4
  /// `theme.chapters.N.boardArt`, m7-4 A.5).
  bool get isThemedWood =>
      this == slotStand || this == towerBase || this == shelfPlank;

  /// The glass cases and the ice: pieces drawn at a slot's overlay scale
  /// (`SlotGeometry.overlayFurnitureScale`), which follows the dolls' fit
  /// factor on four shelves (m7-4 5.2).
  bool get isOverlay => switch (this) {
    glassCase0 ||
    glassCase1 ||
    glassCase2 ||
    glassCaseTall0 ||
    glassCaseTall1 ||
    glassCaseTall2 ||
    ice0 ||
    ice1 ||
    ice2 ||
    ice3 ||
    iceShatter => true,
    _ => false,
  };

  /// The tall case's box on the reference board: `GlassCaseTallTokens`'
  /// ratios × the 150-unit reference doll, rounded as the tokens' own
  /// example ("93×152 for h 150"), which is also the tall frames' Lottie
  /// slot (`glass_case_tall_*` 279×456 at 3×).
  static const glassCaseTallSize = Size(93, 152);

  /// File name in the board asset folder, without `.svg`.
  final String assetName;

  /// The box it is drawn in on the reference board, in reference px.
  final Size designSize;

  String get fileName => '$assetName.svg';

  /// True for the plank: it repeats across the screen, so it is rasterized
  /// as a whole tile and drawn through an [ImageShader], never cropped.
  bool get tiles => this == shelfPlank;

  static const _glassFrames = [glassCase0, glassCase1, glassCase2];
  static const _tallGlassFrames = [
    glassCaseTall0,
    glassCaseTall1,
    glassCaseTall2,
  ];
  static const _iceFrames = [ice0, ice1, ice2, ice3];

  /// The glass case at [frame]: 0 intact, 1 cracked, 2 shattered.
  static BoardSprite glassCase(int frame) {
    RangeError.checkValueInInterval(frame, 0, _glassFrames.length - 1, 'frame');
    return _glassFrames[frame];
  }

  /// The tall glass case at [frame]: 0 intact, 1 cracked, 2 shattered.
  static BoardSprite glassCaseTall(int frame) {
    RangeError.checkValueInInterval(
      frame,
      0,
      _tallGlassFrames.length - 1,
      'frame',
    );
    return _tallGlassFrames[frame];
  }

  /// The ice overlay at [frame] 0–3 (`BoardLayout.iceFrame`). The burst
  /// after frame 3 is [iceShatter].
  static BoardSprite ice(int frame) {
    RangeError.checkValueInInterval(frame, 0, _iceFrames.length - 1, 'frame');
    return _iceFrames[frame];
  }

  /// The stand a slot of [kind] stands on. NestyBoard:163: locked slots use
  /// the plain stand, with the glass case drawn over it.
  static BoardSprite standFor(SlotShapeKind kind) => switch (kind) {
    SlotShapeKind.open || SlotShapeKind.locked => slotStand,
    SlotShapeKind.tower => towerBase,
    SlotShapeKind.extra => extraSlot,
  };
}

/// One board sprite rasterized at one [pixelScale], cropped to its visible
/// pixels.
///
/// [draw] maps the full design box onto a destination rect, so callers pass
/// the layout's rects (`SlotGeometry.standRect`, `glassCaseRect`, `iceRect`,
/// `glowRingRect`) as they are and never see the crop.
///
/// It also fills a Lottie image slot whose declared box is the sprite's
/// [BoardSprite.designSize] (`glow_ring`, `hint_arrow`, `extra_slot`,
/// `glass_case_*`, `ice_*`): lottie 3.6.1 draws the bitmap at its own pixel
/// size, so the FX runtime compensates the layer with the raster's scale
/// [pixelScale] and its crop [cropOrigin] (docs/plans/m2-lottie-design.md
/// §3: `FxRaster(image, scale: pixelScale, origin: cropOrigin)`).
final class BoardSpriteImage {
  BoardSpriteImage._({
    required this.sprite,
    required this.image,
    required this.pixelScale,
    required this.offset,
    required this.fullWidth,
    required this.fullHeight,
    ImageShader? shader,
  }) : _shader = shader,
       cropOrigin = offset / pixelScale,
       tilePaint = shader == null ? null : (Paint()..shader = shader);

  final BoardSprite sprite;

  final ui.Image image;

  /// Image px per reference px (furniture scale × device pixel ratio).
  final double pixelScale;

  /// Where [image]'s top-left sits in the full design box, in image px: the
  /// transparent margin the crop removed.
  final Offset offset;

  /// [offset] in design (reference) px: where [image]'s top-left sits in the
  /// sprite's [BoardSprite.designSize] box. The `FxRaster.origin` of a
  /// Lottie image slot filled with this sprite; [pixelScale] is its scale.
  final Offset cropOrigin;

  /// The full design box in image px.
  final double fullWidth;
  final double fullHeight;

  /// For the tiled plank only: repeats [image] horizontally in reference px
  /// (see `BoardSprites.drawPlank`). Null for every other sprite.
  final Paint? tilePaint;

  final ImageShader? _shader;

  /// Default for [draw]: bilinear, because pulses and re-pitches draw
  /// sprites at fractional sizes.
  static final Paint _defaultPaint = Paint()..filterQuality = FilterQuality.low;

  int get byteSize => image.width * image.height * 4;

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  /// Draws the sprite's full design box into [dst] (logical px). Pass a
  /// [paint] to fade it (its colour's alpha applies).
  void draw(Canvas canvas, Rect dst, [Paint? paint]) {
    canvas
      ..save()
      ..translate(dst.left, dst.top)
      ..scale(dst.width / fullWidth, dst.height / fullHeight)
      ..drawImage(image, offset, paint ?? _defaultPaint)
      ..restore();
  }

  // ── End of hot path. ──

  void dispose() {
    _shader?.dispose();
    image.dispose();
  }
}

/// The board SVGs, parsed once and shared by every board for the app's
/// lifetime (the game's `SkinService`, the admin's preview).
///
/// It keeps the parsed pictures, so any sprite can be rasterized at any
/// scale later, and each sprite's crop box, found once by an alpha probe.
/// A sprite whose SVG fails to load or parse is listed in [failures] and
/// skipped: boards draw without it (CLAUDE.md rule 3, "fail gracefully").
final class BoardSpriteLibrary {
  BoardSpriteLibrary._(this._pictures, this.failures, this.onError);

  /// Loads `<basePath>/<name>.svg` for every [BoardSprite] from [bundle]:
  /// the game's `assets/board/`. With [themedPath] (a chapter's
  /// `assets/board/chNN`) its stand, tower base and plank come from there.
  static Future<BoardSpriteLibrary> load(
    AssetBundle bundle, {
    String basePath = 'assets/board',
    String? themedPath,
    void Function(Object error, StackTrace stack)? onError,
  }) async {
    final texts = <BoardSprite, String>{};
    final failures = <BoardSprite, Object>{};
    Future<void> read(BoardSprite sprite) async {
      try {
        // A chapter's own wood (m7-4 A.5) replaces the stand, tower base
        // and plank; a themed file that fails falls back to the shared one.
        final themed = themedPath != null && sprite.isThemedWood;
        try {
          texts[sprite] = await bundle.loadString(
            '${themed ? themedPath : basePath}/${sprite.fileName}',
            cache: false,
          );
        } on Object {
          if (!themed) rethrow;
          texts[sprite] = await bundle.loadString(
            '$basePath/${sprite.fileName}',
            cache: false,
          );
        }
      } on Object catch (error, stack) {
        failures[sprite] = error;
        _report(onError, error, stack, 'board sprite ${sprite.name}');
      }
    }

    await Future.wait([for (final sprite in BoardSprite.values) read(sprite)]);
    return _parse(texts, failures, onError);
  }

  /// Parses [svgs] (for tests, the admin, or a skin that ships its own
  /// board). Sprites missing from the map are listed in [failures].
  static Future<BoardSpriteLibrary> fromSvgs(
    Map<BoardSprite, String> svgs, {
    void Function(Object error, StackTrace stack)? onError,
  }) => _parse(Map.of(svgs), {}, onError);

  static Future<BoardSpriteLibrary> _parse(
    Map<BoardSprite, String> texts,
    Map<BoardSprite, Object> failures,
    void Function(Object error, StackTrace stack)? onError,
  ) async {
    final pictures = List<PictureInfo?>.filled(BoardSprite.values.length, null);
    Future<void> parse(BoardSprite sprite, String text) async {
      try {
        pictures[sprite.index] = await loadSvgPicture(text);
      } on Object catch (error, stack) {
        failures[sprite] = error;
        _report(onError, error, stack, 'board sprite ${sprite.name}');
      }
    }

    await Future.wait([
      for (final MapEntry(key: sprite, value: text) in texts.entries)
        parse(sprite, text),
    ]);
    for (final sprite in BoardSprite.values) {
      if (pictures[sprite.index] == null) {
        failures.putIfAbsent(sprite, () => StateError('no SVG was loaded'));
      }
    }
    return BoardSpriteLibrary._(pictures, Map.unmodifiable(failures), onError);
  }

  /// Longest side of the crop probe raster, in px. At that size one probe
  /// pixel is at most 3 art units (the silhouette's 768), and the crop keeps
  /// one probe pixel of margin.
  static const probeSide = 256;

  final List<PictureInfo?> _pictures;
  final _crops = List<Future<Rect>?>.filled(BoardSprite.values.length, null);
  bool _disposed = false;

  /// Sprites that could not be loaded, with the error. Unmodifiable.
  final Map<BoardSprite, Object> failures;

  /// Told about load, parse and raster failures. Without it they are only
  /// printed in debug builds.
  final void Function(Object error, StackTrace stack)? onError;

  bool isAvailable(BoardSprite sprite) =>
      !_disposed && _pictures[sprite.index] != null;

  /// The art's own size (its SVG width/height), or null when unavailable.
  Size? artSize(BoardSprite sprite) => _pictures[sprite.index]?.size;

  /// The part of the art that has any visible pixel, in SVG units, plus one
  /// probe pixel of margin. The plank keeps its whole tile. Found once per
  /// sprite by rasterizing it at [probeSide] and scanning the alpha.
  Future<Rect> cropBox(BoardSprite sprite) =>
      _crops[sprite.index] ??= _probe(sprite);

  /// Rasterizes [sprite] at [pixelScale] image px per reference px, cropped
  /// to [cropBox]. The caller owns the result and disposes it.
  ///
  /// The art is fitted into [BoardSprite.designSize] the way CSS draws an
  /// SVG background (`center/100% 100%` with the SVG's default
  /// `preserveAspectRatio`, xMidYMid meet): one scale, centred. The design
  /// boxes are within 1 % of each art's aspect ratio, so this differs from
  /// a stretch by well under a pixel.
  ///
  /// Throws [StateError] when the sprite is unavailable (see [failures]).
  Future<BoardSpriteImage> rasterize(
    BoardSprite sprite,
    double pixelScale,
  ) async {
    if (!pixelScale.isFinite || pixelScale <= 0) {
      throw ArgumentError.value(pixelScale, 'pixelScale', 'must be positive');
    }
    final info = _available(sprite);
    if (sprite.tiles) return _rasterizeTile(sprite, info, pixelScale);
    final box = sprite.designSize;
    final art = info.size;
    final fit = math.min(box.width / art.width, box.height / art.height);
    final artScale = fit * pixelScale; // image px per SVG unit
    final fullWidth = box.width * pixelScale;
    final fullHeight = box.height * pixelScale;
    final originX = (fullWidth - art.width * artScale) / 2;
    final originY = (fullHeight - art.height * artScale) / 2;
    final crop = await cropBox(sprite);
    _available(sprite);
    // Snap outwards to whole pixels, so a sprite drawn at its prepared scale
    // on a whole-pixel origin is sampled 1:1.
    final left = math.max(0, (originX + crop.left * artScale).floor());
    final top = math.max(0, (originY + crop.top * artScale).floor());
    final right = math.min(
      fullWidth.ceil(),
      (originX + crop.right * artScale).ceil(),
    );
    final bottom = math.min(
      fullHeight.ceil(),
      (originY + crop.bottom * artScale).ceil(),
    );
    final image = await rasterizePictures(
      [SvgRasterPart(info.picture)],
      width: math.max(1, right - left),
      height: math.max(1, bottom - top),
      scale: artScale,
      left: left - originX,
      top: top - originY,
    );
    return BoardSpriteImage._(
      sprite: sprite,
      image: image,
      pixelScale: pixelScale,
      offset: Offset(left.toDouble(), top.toDouble()),
      fullWidth: fullWidth,
      fullHeight: fullHeight,
    );
  }

  /// Rasterizes the whole art of [sprite] into a [widthPx] × [heightPx]
  /// image, uncropped and outside any design box: fitted like
  /// [rasterize] (one scale, centred). The caller owns the result.
  ///
  /// For art drawn on an artboard of its own rather than in a board box:
  /// `board/doll-silhouette.svg` is the 512×768 skin artboard, so at
  /// `512·r × 768·r` it lands exactly where a skin's layers do and
  /// `DollPartRasters` uses it as every skin's buried-nest silhouette
  /// (owner decision 3e).
  ///
  /// Throws [StateError] when the sprite is unavailable (see [failures]).
  Future<ui.Image> rasterizeArtboard(
    BoardSprite sprite, {
    required int widthPx,
    required int heightPx,
  }) async {
    if (widthPx < 1 || heightPx < 1) {
      throw ArgumentError('the artboard raster must be at least 1×1 px');
    }
    final info = _available(sprite);
    final art = info.size;
    final scale = math.min(widthPx / art.width, heightPx / art.height);
    return rasterizePictures(
      [SvgRasterPart(info.picture)],
      width: widthPx,
      height: heightPx,
      scale: scale,
      left: (art.width * scale - widthPx) / 2,
      top: (art.height * scale - heightPx) / 2,
    );
  }

  /// Releases the parsed pictures. Images already rasterized stay valid.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (var i = 0; i < _pictures.length; i++) {
      _pictures[i]?.picture.dispose();
      _pictures[i] = null;
    }
  }

  PictureInfo _available(BoardSprite sprite) {
    if (_disposed) throw StateError('BoardSpriteLibrary used after dispose');
    return _pictures[sprite.index] ??
        (throw StateError(
          'board sprite ${sprite.name} is unavailable: ${failures[sprite]}',
        ));
  }

  /// The plank: a whole number of pixels wide with the art spanning it
  /// exactly, so the repeat has no seam, and a shader that maps the image
  /// back to reference px (NestyBoard:12, `repeat-x 0 0/auto 40px`).
  Future<BoardSpriteImage> _rasterizeTile(
    BoardSprite sprite,
    PictureInfo info,
    double pixelScale,
  ) async {
    final box = sprite.designSize;
    final art = info.size;
    final width = math.max(1, (box.width * pixelScale).round());
    final artScale = width / art.width;
    final height = math.max(1, (art.height * artScale).round());
    final image = await rasterizePictures(
      [SvgRasterPart(info.picture)],
      width: width,
      height: height,
      scale: artScale,
    );
    final toReference = box.width / width;
    final shader = ImageShader(
      image,
      TileMode.repeated,
      // The plank is drawn exactly one tile tall; clamping keeps bilinear
      // sampling at its bottom edge from wrapping to its top.
      TileMode.clamp,
      Float64List.fromList([
        toReference, 0, 0, 0, //
        0, toReference, 0, 0, //
        0, 0, 1, 0, //
        0, 0, 0, 1, //
      ]),
      filterQuality: FilterQuality.low,
    );
    return BoardSpriteImage._(
      sprite: sprite,
      image: image,
      pixelScale: pixelScale,
      offset: Offset.zero,
      fullWidth: box.width * pixelScale,
      fullHeight: box.height * pixelScale,
      shader: shader,
    );
  }

  Future<Rect> _probe(BoardSprite sprite) async {
    final info = _available(sprite);
    final art = info.size;
    final full = Offset.zero & art;
    if (sprite.tiles) return full;
    final scale = probeSide / math.max(art.width, art.height);
    final image = await rasterizePictures(
      [SvgRasterPart(info.picture)],
      width: (art.width * scale).ceil(),
      height: (art.height * scale).ceil(),
      scale: scale,
    );
    try {
      final bounds = await alphaBounds(image);
      if (bounds == null) return full;
      // One probe pixel of margin: an antialiased edge too faint to register
      // at probe size can still show at a larger one.
      return Rect.fromLTRB(
        (bounds.left - 1) / scale,
        (bounds.top - 1) / scale,
        (bounds.right + 1) / scale,
        (bounds.bottom + 1) / scale,
      ).intersect(full);
    } finally {
      image.dispose();
    }
  }
}

/// The board sprites of one board at one device pixel ratio: every piece
/// rasterized once at `logical size × layout scale × DPR` (CLAUDE.md rule 8,
/// render §1 "board_sprites"), plus the tiled plank shader.
///
/// [prepare] rasterizes what the layout always shows: the plank, each
/// slot's stand, the glow ring and the hint arrow at every furniture scale
/// on the board, and the intact glass case when a slot is locked. The other
/// glass and ice frames are rasterized lazily: pass them to `prepare` as
/// `also` when the level has them, [ensure] them ahead of an animation, or
/// let the first [image] miss start them. Listeners are told whenever
/// images land, so a `CustomPainter` can repaint.
///
/// Lookups ([image], [standFor], [forSlot]) and drawing ([drawPlanks],
/// [drawPlank], `BoardSpriteImage.draw`) allocate nothing. A lookup that
/// misses returns the nearest scale it has (drawn resized) while the exact
/// one is rasterized, so a re-layout never blinks.
///
/// One instance per board or level; [dispose] releases its images. The
/// [library] is shared and outlives it.
final class BoardSprites extends ChangeNotifier {
  BoardSprites(
    this.library, {
    void Function(Object error, StackTrace stack)? onError,
  }) : assert(BoardSprite.values.length <= _codeStride, 'widen _codeStride'),
       _onError = onError ?? library.onError;

  final BoardSpriteLibrary library;

  final void Function(Object error, StackTrace stack)? _onError;

  /// Scale keys: pixel scales quantized to 1/1024, so slots whose scales
  /// differ only by floating-point noise share one image.
  static const _keyResolution = 1024;

  /// A (sprite, scale key) pair packs into one int (`key × 32 + index`), so
  /// the pending and failed sets never allocate. It stays far below 2^53, so
  /// the packing is the same on the web (the admin). 32 since the tall glass
  /// frames made 18 sprites.
  static const _codeStride = 32;

  static final Paint _plankFallback = Paint()
    // The plank front's mid tone (shelf-plank.svg, gradient `fr` at .45),
    // drawn only when the plank art is missing or not rasterized yet.
    ..color = const Color(0xFFDCA15D);

  final _images = List<List<BoardSpriteImage>>.generate(
    BoardSprite.values.length,
    (_) => <BoardSpriteImage>[],
    growable: false,
  );
  final _pending = <int, Future<void>>{};
  final _failed = <int>{};
  double _devicePixelRatio = 0;
  int _generation = 0;
  bool _disposed = false;

  /// The device pixel ratio of the latest [prepare] (0 before the first).
  double get devicePixelRatio => _devicePixelRatio;

  bool get isPrepared => _devicePixelRatio > 0;

  /// Bytes held by this board's images (RGBA8).
  int get byteSize {
    var total = 0;
    for (final list in _images) {
      for (final image in list) {
        total += image.byteSize;
      }
    }
    return total;
  }

  int get imageCount {
    var count = 0;
    for (final list in _images) {
      count += list.length;
    }
    return count;
  }

  /// The images held for [sprite], one per scale. For tests and budgets.
  List<BoardSpriteImage> imagesOf(BoardSprite sprite) =>
      List.unmodifiable(_images[sprite.index]);

  /// Rasterizes the sprites [geometry] always shows, plus [also] (e.g. the
  /// ice frames a level starts with) at every furniture scale on the board,
  /// for a screen of [devicePixelRatio]. Call it at level load, behind the
  /// route transition, and again when the layout changes (an extra slot, a
  /// resize).
  ///
  /// Pass [BoardSprite.extraSlot] in [also] while the +Slot booster can
  /// still be used, so its stand is ready before the bottom row re-pitches.
  ///
  /// Once the new images are in, images at scales [geometry] no longer uses
  /// are released; lazily added frames at live scales are kept, so a
  /// re-layout mid-level keeps whatever is on screen. Never throws for a
  /// sprite that fails: it is reported and skipped.
  Future<void> prepare(
    BoardGeometry geometry, {
    required double devicePixelRatio,
    Iterable<BoardSprite> also = const [],
  }) async {
    if (_disposed) throw StateError('BoardSprites used after dispose');
    if (!devicePixelRatio.isFinite || devicePixelRatio <= 0) {
      throw ArgumentError.value(
        devicePixelRatio,
        'devicePixelRatio',
        'must be positive',
      );
    }
    final generation = ++_generation;
    _devicePixelRatio = devicePixelRatio;
    final extra = also.toSet();
    final wanted = <int, double>{}; // code → exact pixel scale
    final liveKeys = <int>{};
    void want(BoardSprite sprite, double furnitureScale) {
      final key = _keyOf(furnitureScale * devicePixelRatio);
      liveKeys.add(key);
      wanted.putIfAbsent(
        key * _codeStride + sprite.index,
        () => furnitureScale * devicePixelRatio,
      );
    }

    want(BoardSprite.shelfPlank, geometry.scale);
    // The HUD's family-counter icon is not board-scaled.
    liveKeys.add(_keyOf(devicePixelRatio));
    if (extra.remove(BoardSprite.dollSilhouette)) {
      want(BoardSprite.dollSilhouette, 1);
    }
    for (final slot in geometry.slots) {
      final scale = slot.furnitureScale;
      want(BoardSprite.standFor(slot.kind), scale);
      want(BoardSprite.glowRing, scale);
      want(BoardSprite.hintArrow, scale);
      if (slot.kind == SlotShapeKind.locked) {
        // A case is the normal one or the tall one (m7-3), never both.
        want(
          slot.usesTallCase
              ? BoardSprite.glassCaseTall0
              : BoardSprite.glassCase0,
          slot.overlayFurnitureScale,
        );
      }
      for (final sprite in extra) {
        want(sprite, scale);
      }
    }
    await Future.wait([
      for (final MapEntry(key: code, value: pixelScale) in wanted.entries)
        _start(code, pixelScale),
    ]);
    if (_disposed || generation != _generation) return;
    _evictExcept(liveKeys);
    notifyListeners();
  }

  /// Rasterizes [sprite] at [furnitureScale] now, e.g. the cracked and
  /// shattered glass as soon as a completion will unlock a case (the unlock
  /// clip starts 700 ms later). Requires a prior [prepare].
  Future<void> ensure(BoardSprite sprite, double furnitureScale) {
    if (_disposed) throw StateError('BoardSprites used after dispose');
    if (!isPrepared) throw StateError('call prepare() before ensure()');
    final key = _keyOf(furnitureScale * _devicePixelRatio);
    return _start(
      key * _codeStride + sprite.index,
      furnitureScale * _devicePixelRatio,
    );
  }

  /// Releases every image of [sprites] (e.g. the glass frames once the last
  /// case has shattered).
  void release(Iterable<BoardSprite> sprites) {
    var changed = false;
    for (final sprite in sprites) {
      final list = _images[sprite.index];
      changed |= list.isNotEmpty;
      for (final image in list) {
        image.dispose();
      }
      list.clear();
    }
    if (changed && !_disposed) notifyListeners();
  }

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  /// [sprite] for a piece of [furnitureScale] (`SlotGeometry.furnitureScale`;
  /// the board scale for the plank; 1 for the HUD), or null.
  ///
  /// On a miss this returns the nearest scale held (or null when none is).
  /// When nothing held is within [missTolerance] of the scale, the miss
  /// starts rasterizing the exact scale and listeners are told when it
  /// lands; otherwise the near one is drawn resized. So an animation that
  /// passes a changing scale (a re-pitch, a pulse) starts a handful of
  /// rasterizations at most, not one per frame (review RENDER-6). Animate by
  /// scaling the destination rect and pass the slot's resting
  /// `furnitureScale` here. Null before the first [prepare] and for a
  /// sprite that failed.
  BoardSpriteImage? image(BoardSprite sprite, double furnitureScale) {
    if (_disposed || _devicePixelRatio <= 0) return null;
    final pixelScale = furnitureScale * _devicePixelRatio;
    final key = _keyOf(pixelScale);
    final list = _images[sprite.index];
    BoardSpriteImage? nearest;
    var nearestDistance = 0;
    for (var i = 0; i < list.length; i++) {
      final candidate = list[i];
      final distance = (_keyOf(candidate.pixelScale) - key).abs();
      if (distance == 0) return candidate;
      if (nearest == null || distance < nearestDistance) {
        nearest = candidate;
        nearestDistance = distance;
      }
    }
    if (nearest == null ||
        (nearest.pixelScale - pixelScale).abs() > missTolerance * pixelScale) {
      _request(key * _codeStride + sprite.index, furnitureScale);
    }
    return nearest;
  }

  /// How far (as a fraction of the scale) a held image may be from a
  /// requested scale before [image] rasterizes the exact one.
  static const double missTolerance = 0.1;

  /// The stand, tower base or extra-slot sprite for [slot], drawn in
  /// `slot.standRect`.
  BoardSpriteImage? standFor(SlotGeometry slot) =>
      image(BoardSprite.standFor(slot.kind), slot.furnitureScale);

  /// [sprite] at [slot]'s furniture scale: the glass cases and the ice at
  /// its overlay scale (`SlotGeometry.overlayFurnitureScale`).
  BoardSpriteImage? forSlot(BoardSprite sprite, SlotGeometry slot) => image(
    sprite,
    sprite.isOverlay ? slot.overlayFurnitureScale : slot.furnitureScale,
  );

  /// Every shelf plank of [geometry], drawn first (NestyBoard:12).
  void drawPlanks(Canvas canvas, BoardGeometry geometry) {
    final shelves = geometry.shelves;
    for (var i = 0; i < shelves.length; i++) {
      drawPlank(canvas, shelves[i]);
    }
  }

  /// One plank: the tile repeated across `shelf.plankRect` from x 0 of the
  /// canvas (NestyBoard:12, `left:0;right:0`, `repeat-x 0 0`). A flat wood
  /// colour stands in until the tile exists.
  void drawPlank(Canvas canvas, ShelfGeometry shelf) {
    final rect = shelf.plankRect;
    final scale = rect.height / _K.plankHeight;
    final paint = image(BoardSprite.shelfPlank, scale)?.tilePaint;
    if (paint == null) {
      canvas.drawRect(rect, _plankFallback);
      return;
    }
    canvas
      ..save()
      ..clipRect(rect)
      ..translate(0, rect.top)
      ..scale(scale)
      ..drawPaint(paint)
      ..restore();
  }

  // ── End of hot path. ──

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final list in _images) {
      for (final image in list) {
        image.dispose();
      }
      list.clear();
    }
    super.dispose();
  }

  static int _keyOf(double pixelScale) => (pixelScale * _keyResolution).round();

  /// A lookup's first miss: allocates once per (sprite, scale), never on
  /// the steady-state path.
  void _request(int code, double furnitureScale) {
    if (_pending.containsKey(code) || _failed.contains(code)) return;
    unawaited(_start(code, furnitureScale * _devicePixelRatio));
  }

  /// Starts rasterizing [code]'s sprite at [pixelScale], the exact scale of
  /// its first request (the key only dedupes), unless it exists, is
  /// pending or failed.
  Future<void> _start(int code, double pixelScale) {
    final pending = _pending[code];
    if (pending != null) return pending;
    final sprite = BoardSprite.values[code % _codeStride];
    final key = code ~/ _codeStride;
    if (_failed.contains(code) || _has(sprite, key)) return Future.value();
    if (!library.isAvailable(sprite)) {
      _failed.add(code);
      return Future.value();
    }
    final job = _rasterize(code, sprite, key, pixelScale);
    _pending[code] = job;
    return job;
  }

  Future<void> _rasterize(
    int code,
    BoardSprite sprite,
    int key,
    double pixelScale,
  ) async {
    try {
      final image = await library.rasterize(sprite, pixelScale);
      if (_disposed || _has(sprite, key)) {
        image.dispose();
        return;
      }
      _images[sprite.index].add(image);
      notifyListeners();
    } on Object catch (error, stack) {
      _failed.add(code);
      _report(_onError, error, stack, 'board sprite ${sprite.name}');
    } finally {
      // The removed future is this job itself, already completing.
      unawaited(_pending.remove(code));
    }
  }

  bool _has(BoardSprite sprite, int key) {
    final list = _images[sprite.index];
    for (var i = 0; i < list.length; i++) {
      if (_keyOf(list[i].pixelScale) == key) return true;
    }
    return false;
  }

  void _evictExcept(Set<int> liveKeys) {
    for (final list in _images) {
      list.removeWhere((image) {
        if (liveKeys.contains(_keyOf(image.pixelScale))) return false;
        image.dispose();
        return true;
      });
    }
  }
}

void _report(
  void Function(Object error, StackTrace stack)? onError,
  Object error,
  StackTrace stack,
  String what,
) {
  if (onError != null) {
    onError(error, stack);
  } else {
    debugPrint('$what failed: $error');
  }
}
