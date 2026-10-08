import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart' show Matrix4;

// Value types for the generated ui_tokens.gen.dart. Hand-written (and
// editable) so helpers can live here while the values stay generated from
// design/tokens.json.

/// One layer of a CSS `box-shadow` from tokens.json `shadow.*`.
///
/// [BoxShadow] cannot draw `inset` layers (the 2 px white top highlight of
/// every tactile surface), so the tokens keep the full CSS model and widgets
/// paint inset layers themselves.
@immutable
final class NestyShadow {
  const NestyShadow({
    required this.color,
    this.inset = false,
    this.dx = 0,
    this.dy = 0,
    this.blur = 0,
    this.spread = 0,
  });

  final bool inset;
  final double dx;
  final double dy;
  final double blur;
  final double spread;
  final Color color;

  /// The equivalent outer [BoxShadow]. Only valid for non-inset layers.
  BoxShadow toBoxShadow() {
    assert(!inset, 'BoxShadow cannot draw an inset shadow');
    return BoxShadow(
      color: color,
      offset: Offset(dx, dy),
      blurRadius: blur,
      spreadRadius: spread,
    );
  }

  /// True for a CSS "solid edge" layer (`0 Npx 0 color`): the bottom lip of
  /// every tactile surface, which shrinks to `AppShadowTokens.pressedEdge`
  /// when pressed (design/README.md "Tactile depth").
  bool get isSolidEdge =>
      !inset && dx == 0 && dy > 0 && blur == 0 && spread == 0;

  NestyShadow copyWith({
    bool? inset,
    double? dx,
    double? dy,
    double? blur,
    double? spread,
    Color? color,
  }) => NestyShadow(
    inset: inset ?? this.inset,
    dx: dx ?? this.dx,
    dy: dy ?? this.dy,
    blur: blur ?? this.blur,
    spread: spread ?? this.spread,
    color: color ?? this.color,
  );

  @override
  bool operator ==(Object other) =>
      other is NestyShadow &&
      other.inset == inset &&
      other.dx == dx &&
      other.dy == dy &&
      other.blur == blur &&
      other.spread == spread &&
      other.color == color;

  @override
  int get hashCode => Object.hash(inset, dx, dy, blur, spread, color);
}

/// A gradient stop position: a fraction of the gradient line, or an
/// absolute offset in logical px from its start (CSS `14px`).
@immutable
final class TokenStop {
  const TokenStop.fraction(double this.fraction) : px = null;
  const TokenStop.px(double this.px) : fraction = null;

  final double? fraction;
  final double? px;

  /// This stop as a fraction of a gradient line [extent] px long.
  double resolve(double extent) =>
      fraction ?? (extent <= 0 ? 0 : (px! / extent).clamp(0, 1).toDouble());
}

/// A linear gradient with at least one px stop, which only becomes a
/// [LinearGradient] once the painted extent is known (the wood bar's
/// `#BD7B40 14px`).
@immutable
final class PxLinearGradient {
  const PxLinearGradient({
    required this.begin,
    required this.end,
    required this.colors,
    required this.stops,
  });

  final Alignment begin;
  final Alignment end;
  final List<Color> colors;
  final List<TokenStop> stops;

  /// The gradient for a box whose gradient line is [extent] px long (the
  /// bar's height for a vertical gradient).
  LinearGradient resolve(double extent) => LinearGradient(
    begin: begin,
    end: end,
    colors: colors,
    stops: [for (final stop in stops) stop.resolve(extent)],
  );
}

/// Tokens v6 (m7-6) `gradient.figurinePanel*`: a CSS
/// `radial-gradient(ellipse <rx>% <ry>% at <x>% <y>%, …)` on a
/// [RadialGradient] whose `radius` is 0.5 and whose `center` is [center].
/// Flutter's radial gradient is a circle of `radius × shortestSide`; this
/// scales that circle about [center] into the CSS ellipse, [radiusX] of the
/// box's width by [radiusY] of its height, so the stops land where the
/// design's do on any box.
@immutable
final class EllipseGradientTransform extends GradientTransform {
  const EllipseGradientTransform({
    required this.center,
    required this.radiusX,
    required this.radiusY,
  });

  /// The gradient's centre (the same as its `center`).
  final Alignment center;

  /// The ellipse's horizontal radius ÷ the box width.
  final double radiusX;

  /// The ellipse's vertical radius ÷ the box height.
  final double radiusY;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    final circle = bounds.shortestSide * 0.5;
    if (circle <= 0) return Matrix4.identity();
    final c = center.withinRect(bounds);
    return Matrix4.identity()
      ..translateByDouble(c.dx, c.dy, 0, 1)
      ..scaleByDouble(
        radiusX * bounds.width / circle,
        radiusY * bounds.height / circle,
        1,
        1,
      )
      ..translateByDouble(-c.dx, -c.dy, 0, 1);
  }

  @override
  bool operator ==(Object other) =>
      other is EllipseGradientTransform &&
      other.center == center &&
      other.radiusX == radiusX &&
      other.radiusY == radiusY;

  @override
  int get hashCode => Object.hash(center, radiusX, radiusY);
}

/// Repeating diagonal stripes (tokens.json `gradient.progressFill.stripes`).
@immutable
final class TokenStripes {
  const TokenStripes({
    required this.angleDeg,
    required this.color,
    required this.onPx,
    required this.offPx,
  });

  final double angleDeg;
  final Color color;
  final double onPx;
  final double offPx;
}

/// Repeating wood-grain lines (tokens.json `gradient.woodBar.overlay`).
@immutable
final class WoodGrainToken {
  const WoodGrainToken({
    required this.color,
    required this.lineWidth,
    required this.spacing,
    required this.vertical,
  });

  final Color color;
  final double lineWidth;

  /// Distance between line starts, in logical px.
  final double spacing;

  /// True for vertical lines.
  final bool vertical;
}

/// How a sound event picks its file.
enum SoundPick {
  /// Always the single file.
  single,

  /// A random file of the list each time.
  random,

  /// The file for the current combo step (1-based index into the list).
  comboStep,
}

/// The audio files behind one sound event (tokens.json `sound.events`).
/// File names are base names in `assets/audio/` without extension.
@immutable
final class SoundCue {
  const SoundCue(this.files, {this.pick = SoundPick.single});

  final List<String> files;
  final SoundPick pick;
}

/// A solid stroke of tokens v3: a ring, an edge or an inset line
/// (`2px #FFFDF7`, `3px #4E5FD9`).
@immutable
final class TokenStroke {
  const TokenStroke({required this.width, required this.color});

  final double width;
  final Color color;

  /// The same stroke as a [BorderSide].
  BorderSide toBorderSide() => BorderSide(color: color, width: width);
}

/// A skin's Shop colours (tokens v3 `shop.skins.<id>`): its card and detail
/// panel gradients (top to bottom), the panel's solid edge and the caption
/// on the card.
@immutable
final class ShopSkinColors {
  const ShopSkinColors({
    required this.card,
    required this.panel,
    required this.edge,
    required this.caption,
  });

  final List<Color> card;
  final List<Color> panel;
  final Color edge;
  final Color caption;
}

/// A ribbon's four tinted fills (tokens v4 `winRibbon.default`,
/// `versus.ribbon`, a chapter's `ribbonTail` / `ribbonFold`; LOTTIE.md "Tint
/// and width"): `ui_win_ribbon` and `ui_chapter_ribbon` take them through
/// colour delegates on `WinRibbonTokens`' key paths. `hi_fill` keeps its
/// authored white.
@immutable
final class RibbonColors {
  const RibbonColors({
    required this.band,
    required this.edge,
    required this.tail,
    required this.fold,
  });

  final Color band;
  final Color edge;
  final Color tail;
  final Color fold;
}

/// The display face of the current locale (m7-5 item 28): Turkish draws
/// every Fredoka role in Baloo 2, whole strings, because Fredoka has no
/// ğ Ğ İ ş Ş. The generated Fredoka styles are getters through [of];
/// `LocaleScriptScope` sets the mapping with [use]. Each style's mapped copy
/// is cached, so reading a token in a frame makes no new object.
abstract final class DisplayFace {
  static Object? _owner;
  static TextStyle Function(TextStyle) _map = _same;
  static final _cache = Map<TextStyle, TextStyle>.identity();

  static TextStyle _same(TextStyle style) => style;

  /// Maps every display style through [map] from now on; [owner] (the
  /// locale's script) keeps a rebuild with the same script from clearing
  /// the cache.
  static void use(Object owner, TextStyle Function(TextStyle) map) {
    if (identical(owner, _owner)) return;
    _owner = owner;
    _map = map;
    _cache.clear();
  }

  /// [style], a const style, in the current locale's display face (cached
  /// by identity).
  static TextStyle of(TextStyle style) => _cache[style] ??= _map(style);

  /// [style], one built on the fly (a fitted size), in the current locale's
  /// display face; not cached, so a new style never grows the cache.
  static TextStyle apply(TextStyle style) => _map(style);
}
