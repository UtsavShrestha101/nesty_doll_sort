import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:flutter/widgets.dart';
import 'package:nesty_render/nesty_render.dart'
    show ChapterTheme, loadSvgPicture;

/// One chapter theme's crop of its background art (tokens v3
/// `theme.chapters.N.thumb`, 1080×506 at x 105), drawn at a card's size:
/// the Shop's theme cards (158×74), Chapters' folded rows (84×42) and the
/// open chapter's header (358 wide, clipped to 92 tall). Phase 4
/// architecture §3.2, lead note 4.
///
/// An interface with an asset implementation and a fake (a solid
/// `palette.band` colour: no image), like [DailyBackgroundLoader]'s shape:
/// the widget below draws `palette.band` until an image lands, and for good
/// when it never does (rule 3, offline-first: the art is bundled, but a
/// failed decode is never an error the player sees).
abstract interface class ThemeThumbnailLoader {
  /// The crop of [theme] for a [box]-sized card at [devicePixelRatio], the
  /// art scaled to the box's width and top-aligned at the crop's `y`,
  /// clipped to the box. [locked] applies the Chapters' locked look
  /// (grayscale 0.7, brightness 1.06). Null while it can't be produced.
  /// Never throws.
  ///
  /// The caller must not dispose the image, and clones it to keep it: the
  /// loader keeps it in its LRU and disposes it when it is evicted.
  Future<ui.Image?> thumbnail(
    ChapterTheme theme, {
    required Size box,
    required double devicePixelRatio,
    bool locked = false,
  });

  /// A [thumbnail] already made, or null: a lookup that allocates nothing.
  ui.Image? cached(
    ChapterTheme theme, {
    required Size box,
    required double devicePixelRatio,
    bool locked = false,
  });

  /// The loader for widgets under [context]: the nearest
  /// [ThemeThumbnailScope], else the app-wide [AssetThemeThumbnailLoader].
  static ThemeThumbnailLoader of(BuildContext context) =>
      ThemeThumbnailScope.maybeOf(context) ?? AssetThemeThumbnailLoader.shared;
}

/// Overrides the [ThemeThumbnailLoader] below it (tests, previews).
class ThemeThumbnailScope extends InheritedWidget {
  const ThemeThumbnailScope({
    required this.loader,
    required super.child,
    super.key,
  });

  final ThemeThumbnailLoader loader;

  static ThemeThumbnailLoader? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeThumbnailScope>()?.loader;

  @override
  bool updateShouldNotify(ThemeThumbnailScope oldWidget) =>
      !identical(oldWidget.loader, loader);
}

/// The fake: no art, so a [ThemeThumbnail] keeps its `palette.band` box.
/// [requests] counts what was asked for, for a test.
class FakeThemeThumbnailLoader implements ThemeThumbnailLoader {
  FakeThemeThumbnailLoader();

  final List<({ChapterTheme theme, Size box, bool locked})> requests = [];

  @override
  Future<ui.Image?> thumbnail(
    ChapterTheme theme, {
    required Size box,
    required double devicePixelRatio,
    bool locked = false,
  }) async {
    requests.add((theme: theme, box: box, locked: locked));
    return null;
  }

  @override
  ui.Image? cached(
    ChapterTheme theme, {
    required Size box,
    required double devicePixelRatio,
    bool locked = false,
  }) => null;
}

/// The real loader (phase 4 architecture §3.2):
///
/// * it loads a theme's SVG once per crop, draws the crop into a
///   `PictureRecorder` at the target size × pixel ratio and disposes the
///   picture at once, so no full-size art stays in memory;
/// * an LRU of [smallCapacity] small images (the Shop's and the folded
///   rows'), and one header image (the widest box) kept apart, so the open
///   chapter's header never evicts a row;
/// * loads run one at a time, so ten cards scrolling in never decode ten
///   SVGs at once (rule 8's low-end budget).
class AssetThemeThumbnailLoader implements ThemeThumbnailLoader {
  AssetThemeThumbnailLoader({this.bundle});

  /// The app-wide loader: Chapters and the Shop share its cache.
  static final AssetThemeThumbnailLoader shared = AssetThemeThumbnailLoader();

  /// Overridden by tests; defaults to [rootBundle].
  final AssetBundle? bundle;

  /// A box at least this wide is the header's.
  static const double headerMinWidth = 300;

  /// The small images kept.
  static const int smallCapacity = 12;

  /// Capped like the theme background: a card is a fraction of a screen.
  static const double maxPixelRatio = 2;

  /// The locked look (Chapters; the menus spec 0.10): CSS `grayscale(.7)`
  /// then `brightness(1.06)`, as one colour matrix.
  static const List<double> lockedMatrix = [
    // grayscale(0.7): 0.3 of the colour kept.
    0.3 * 1.06 + 0.7 * 0.2126 * 1.06,
    0.7 * 0.7152 * 1.06,
    0.7 * 0.0722 * 1.06,
    0,
    0,
    0.7 * 0.2126 * 1.06, 0.3 * 1.06 + 0.7 * 0.7152 * 1.06,
    0.7 * 0.0722 * 1.06, 0, 0,
    0.7 * 0.2126 * 1.06, 0.7 * 0.7152 * 1.06,
    0.3 * 1.06 + 0.7 * 0.0722 * 1.06, 0, 0,
    0, 0, 0, 1, 0,
  ];

  // Insertion order is recency: a hit moves its key to the end.
  final LinkedHashMap<String, ui.Image> _small =
      LinkedHashMap<String, ui.Image>();
  final Map<String, ui.Image> _header = {};
  final Map<String, Future<ui.Image?>> _pending = {};
  Future<void> _queue = Future<void>.value();

  /// How many small images are kept now (for a test).
  int get smallCount => _small.length;

  /// How many header images are kept now (for a test): 1 at most.
  int get headerCount => _header.length;

  static String _key(ChapterTheme theme, Size box, double ratio, bool locked) =>
      '${theme.id}|${box.width}x${box.height}|$ratio|$locked';

  bool _isHeader(Size box) => box.width >= headerMinWidth;

  @override
  ui.Image? cached(
    ChapterTheme theme, {
    required Size box,
    required double devicePixelRatio,
    bool locked = false,
  }) {
    final ratio = math.min(devicePixelRatio, maxPixelRatio);
    final key = _key(theme, box, ratio, locked);
    if (_isHeader(box)) return _header[key];
    final hit = _small.remove(key);
    if (hit != null) _small[key] = hit;
    return hit;
  }

  @override
  Future<ui.Image?> thumbnail(
    ChapterTheme theme, {
    required Size box,
    required double devicePixelRatio,
    bool locked = false,
  }) {
    if (!box.width.isFinite ||
        !box.height.isFinite ||
        box.width <= 0 ||
        box.height <= 0) {
      return Future<ui.Image?>.value();
    }
    final ratio = math.min(devicePixelRatio, maxPixelRatio);
    final key = _key(theme, box, ratio, locked);
    final hit = cached(
      theme,
      box: box,
      devicePixelRatio: ratio,
      locked: locked,
    );
    if (hit != null) return Future<ui.Image?>.value(hit);
    return _pending.putIfAbsent(key, () {
      final done = Completer<ui.Image?>();
      // One at a time: each load waits for the one before it.
      _queue = _queue.then((_) async {
        try {
          done.complete(await _render(theme, box, ratio, locked, key));
        } on Object {
          done.complete();
        }
      });
      return done.future.whenComplete(() {
        // A block body: `remove` returns this very future, and an arrow
        // would make `whenComplete` wait on itself.
        _pending.remove(key);
      });
    });
  }

  Future<ui.Image?> _render(
    ChapterTheme theme,
    Size box,
    double ratio,
    bool locked,
    String key,
  ) async {
    try {
      final source = await (bundle ?? rootBundle).loadString(theme.assetKey());
      final info = await loadSvgPicture(source);
      try {
        final crop = theme.thumb;
        // The crop's width lands on the box's width (`NestyHub crop()`):
        // scale = w / 1080, the crop's top-left at the box's (0, 0).
        final scale = box.width / crop.width * ratio;
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        final width = math.max(1, (box.width * ratio).round());
        final height = math.max(1, (box.height * ratio).round());
        canvas.clipRect(
          Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        );
        if (locked) {
          canvas.saveLayer(
            null,
            Paint()..colorFilter = const ColorFilter.matrix(lockedMatrix),
          );
        }
        canvas
          ..translate(-crop.left * scale, -crop.top * scale)
          ..scale(scale)
          ..drawPicture(info.picture);
        if (locked) canvas.restore();
        final picture = recorder.endRecording();
        try {
          final image = picture.toImageSync(width, height);
          _store(key, box, image);
          return image;
        } finally {
          picture.dispose();
        }
      } finally {
        info.picture.dispose();
      }
    } on Object {
      // Rule 3: a failure keeps the card's flat `palette.band`.
      return null;
    }
  }

  void _store(String key, Size box, ui.Image image) {
    if (_isHeader(box)) {
      // One header image: the next chapter's replaces the last.
      for (final old in _header.values) {
        old.dispose();
      }
      _header
        ..clear()
        ..[key] = image;
      return;
    }
    _small[key] = image;
    while (_small.length > smallCapacity) {
      final oldest = _small.keys.first;
      _small.remove(oldest)?.dispose();
    }
  }

  /// Frees every image (tests).
  void clear() {
    for (final image in _small.values) {
      image.dispose();
    }
    for (final image in _header.values) {
      image.dispose();
    }
    _small.clear();
    _header.clear();
  }
}

/// A [ThemeThumbnailLoader] crop of [theme] in a [size] box with rounded
/// [radius] corners: `palette.band` until the image lands (and for good if
/// it never does), then the crop. A decorative image: it is excluded from
/// semantics (its card names the theme).
class ThemeThumbnail extends StatefulWidget {
  const ThemeThumbnail({
    required this.theme,
    required this.size,
    this.radius = 12,
    this.locked = false,
    this.loader,
    super.key,
  });

  final ChapterTheme theme;
  final Size size;
  final double radius;

  /// Chapters' locked look; the Shop's locked cards stay in full colour.
  final bool locked;

  /// Overrides [ThemeThumbnailLoader.of] (tests).
  final ThemeThumbnailLoader? loader;

  @override
  State<ThemeThumbnail> createState() => _ThemeThumbnailState();
}

class _ThemeThumbnailState extends State<ThemeThumbnail> {
  ui.Image? _image;
  int _request = 0;
  Object? _requestedFor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  @override
  void didUpdateWidget(ThemeThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.theme != widget.theme ||
        oldWidget.size != widget.size ||
        oldWidget.locked != widget.locked ||
        oldWidget.loader != widget.loader) {
      _load();
    }
  }

  void _load() {
    final loader = widget.loader ?? ThemeThumbnailLoader.of(context);
    final ratio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
    final id = (loader, widget.theme, widget.size, widget.locked, ratio);
    if (_requestedFor == id) return;
    _requestedFor = id;
    final ready = loader.cached(
      widget.theme,
      box: widget.size,
      devicePixelRatio: ratio,
      locked: widget.locked,
    );
    _setImage(ready);
    if (ready != null) return;
    final request = ++_request;
    unawaited(
      loader
          .thumbnail(
            widget.theme,
            box: widget.size,
            devicePixelRatio: ratio,
            locked: widget.locked,
          )
          .then((image) {
            if (!mounted || request != _request || image == null) return;
            setState(() => _setImage(image));
          }),
    );
  }

  /// Holds a clone: the loader may evict (and dispose) its own image while
  /// this card is still on screen.
  void _setImage(ui.Image? image) {
    _image?.dispose();
    _image = image?.clone();
  }

  @override
  void dispose() {
    _request++;
    _image?.dispose();
    _image = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: SizedBox.fromSize(
          size: widget.size,
          child: ColoredBox(
            color: widget.theme.fallbackColor,
            child: image == null
                ? null
                : RawImage(
                    image: image,
                    width: widget.size.width,
                    height: widget.size.height,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.medium,
                  ),
          ),
        ),
      ),
    );
  }
}
