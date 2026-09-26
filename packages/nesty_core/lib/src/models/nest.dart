import 'package:nesty_core/src/models/doll.dart';
import 'package:nesty_core/src/models/doll_color.dart';

/// One or more dolls of the same color nested together (spec §2.1).
///
/// Spec §2.1 requires the sizes, listed outer to inner, to be consecutive and
/// decreasing, so a nest is fully described by its [color], its [outerSize]
/// and its [length]. Storing exactly that makes an invalid nest such as
/// `[red4, red2]` impossible to build (docs/plans/m1-core-design.md §2). The
/// level codec reports such input as an issue instead (spec §5.3 rule 3).
///
/// The spec calls the outer doll `dolls.first` and the inner one
/// `dolls.last`; [outer], [inner] and [dolls] give the same views.
final class Nest {
  const Nest._(this.color, this.outerSize, this.length);

  /// The run of [length] dolls of [color] whose outer doll has size [outer]:
  /// sizes `outer, outer − 1, …, outer − length + 1`.
  ///
  /// Throws a [RangeError] unless `1 <= outer <= 6` and
  /// `1 <= length <= outer` (the inner doll is at least size 1).
  factory Nest.run(DollColor color, {required int outer, required int length}) {
    RangeError.checkValueInInterval(outer, Doll.minSize, Doll.maxSize, 'outer');
    RangeError.checkValueInInterval(length, 1, outer, 'length');
    return Nest._(color, outer, length);
  }

  /// The nest made of [dolls] (outer to inner), or null when they don't form
  /// one: the list is empty, the colors differ, or the sizes are not
  /// consecutive and decreasing (spec §2.1).
  ///
  /// Gold (§3.5, v1.1) is treated like any other color here: `[gold3]` is a
  /// nest, `[red4, gold3]` is not yet. Mixed gold nests arrive with the v1.1
  /// gold rules, which also reserve bits for the gold position in the
  /// engine's nest code (docs/plans/m1-core-design.md §2).
  static Nest? tryFromDolls(List<Doll> dolls) {
    if (dolls.isEmpty) return null;
    final first = dolls.first;
    for (var i = 0; i < dolls.length; i++) {
      final doll = dolls[i];
      if (doll.color != first.color || doll.size != first.size - i) {
        return null;
      }
      if (doll.size < Doll.minSize || doll.size > Doll.maxSize) return null;
    }
    return Nest._(first.color, first.size, dolls.length);
  }

  final DollColor color;

  /// Size of the outer (largest, visible) doll.
  final int outerSize;

  /// Number of dolls in the nest, at least 1.
  final int length;

  /// Size of the inner (smallest) doll.
  int get innerSize => outerSize - length + 1;

  /// The visible doll (spec §2.1: `outer = dolls.first`).
  Doll get outer => Doll(color, outerSize);

  /// The innermost doll (spec §2.1: `inner = dolls.last`).
  Doll get inner => Doll(color, innerSize);

  /// Every doll, outer to inner. Builds a new unmodifiable list on each call,
  /// so hot paths should use [outerSize], [innerSize] and [containsSize].
  List<Doll> get dolls => List.unmodifiable([
    for (var size = outerSize; size >= innerSize; size--) Doll(color, size),
  ]);

  /// True when this nest holds every size from [maxSize] down to 1: a full
  /// set, which completes (spec §2.1, §4 "merged is full").
  bool isFullSet(int maxSize) => outerSize == maxSize && innerSize == 1;

  /// True when a doll of [size] is inside this nest. The pip bar under a slot
  /// shows exactly these sizes (spec §10.3).
  bool containsSize(int size) => size <= outerSize && size >= innerSize;

  @override
  bool operator ==(Object other) =>
      other is Nest &&
      other.color == color &&
      other.outerSize == outerSize &&
      other.length == length;

  @override
  int get hashCode => Object.hash(color, outerSize, length);

  /// The level-JSON shape, for example `[red4, red3]` (spec §5.1).
  @override
  String toString() => '[${dolls.join(', ')}]';
}
