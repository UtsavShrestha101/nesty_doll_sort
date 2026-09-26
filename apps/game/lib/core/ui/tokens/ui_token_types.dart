import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart';

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
