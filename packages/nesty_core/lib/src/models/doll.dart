import 'package:nesty_core/src/models/doll_color.dart';

/// One doll: a [color] and a [size] from 1 (smallest) up to the level's
/// `maxSize` (spec §2.1).
///
/// Dolls rarely travel alone: the board holds `Nest`s, which store their
/// dolls as a compact run. `Doll` is the view the codec, the renderer and the
/// tests use for a single doll.
final class Doll {
  /// Creates a doll. [size] must be in [minSize]..[maxSize]; the level codec
  /// checks tokens before it constructs one (spec §5.3), so this is only
  /// asserted.
  const Doll(this.color, this.size)
    : assert(
        size >= minSize && size <= maxSize,
        'Doll size must be $minSize..$maxSize (spec §2.1)',
      );

  /// The smallest doll size (spec §2.1).
  static const int minSize = 1;

  /// The largest doll size any level may use (spec §2.1: `maxSize` is 3–6).
  static const int maxSize = 6;

  final DollColor color;
  final int size;

  /// The compact level-JSON token, such as `"red4"` (spec §5.1).
  String get token => '${color.id}$size';

  @override
  bool operator ==(Object other) =>
      other is Doll && other.color == color && other.size == size;

  @override
  int get hashCode => Object.hash(color, size);

  @override
  String toString() => token;
}
