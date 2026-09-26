import 'package:nesty_core/src/models/doll_color.dart';
import 'package:nesty_core/src/models/nest.dart';

/// A nest packed into one small int, the unit of the engine's board cells
/// (docs/plans/m1-core-design.md §2, spec §6.2 "encode each nest as
/// `(color, outerSize, len)` packed into an int").
///
/// Layout: `gold << 10 | color << 6 | outer << 3 | length`, where `color` is
/// a `DollColor.index` (4 bits), `outer` and `length` are 1–6 (3 bits each)
/// and `gold` is the size of a golden doll merged into a nest of another
/// color (0 = none, 3 bits; spec §3.5, v1.1). Every real nest has
/// `outer >= 1` and `length >= 1`, so a code is at least 9 and [empty] (0)
/// can mean "no nest". Codes stay below 2^13, so they fit a `Uint16List`
/// cell and every operation here is exact on the web.
///
/// Internal to nesty_core (not exported by the barrel).
abstract final class NestCode {
  /// No nest: an empty cell.
  static const int empty = 0;

  static const int _lengthMask = 0x7;
  static const int _outerShift = 3;
  static const int _sizeMask = 0x7;
  static const int _colorShift = 6;
  static const int _colorMask = 0xF;
  static const int _goldShift = 10;

  // Bit i set when DollColor.values[i] is wild (only gold, spec §3.5). Read
  // from the enum rather than hard-coded so the flag stays the one source.
  static final int _wildColors = DollColor.values.fold(
    0,
    (mask, color) => color.isWild ? mask | (1 << color.index) : mask,
  );

  /// The code of a nest of [color] (a `DollColor.index`) whose outer doll is
  /// [outer] and which holds [length] dolls. [gold] is the size of a golden
  /// doll inside a nest of another color, or 0.
  static int pack(int color, int outer, int length, [int gold = 0]) =>
      (gold << _goldShift) |
      (color << _colorShift) |
      (outer << _outerShift) |
      length;

  /// The code of [nest].
  static int of(Nest nest) =>
      pack(nest.color.index, nest.outerSize, nest.length);

  /// The `DollColor.index` of [code]: for a nest holding the golden doll,
  /// the color of its other dolls (spec §3.5).
  static int color(int code) => (code >> _colorShift) & _colorMask;

  /// Size of the outer (visible) doll.
  static int outer(int code) => (code >> _outerShift) & _sizeMask;

  /// Number of dolls in the nest.
  static int length(int code) => code & _lengthMask;

  /// Size of the innermost doll: `outer − length + 1`.
  static int inner(int code) =>
      ((code >> _outerShift) & _sizeMask) - (code & _lengthMask) + 1;

  /// Size of the golden doll merged into a nest of another color, or 0
  /// (spec §3.5). A nest made only of gold has color gold and 0 here.
  static int gold(int code) => (code >> _goldShift) & _sizeMask;

  /// True when color index [color] is wild (gold, spec §3.5).
  static bool isWildColor(int color) => ((_wildColors >> color) & 1) == 1;

  /// Spec §4 `colorsMatch(T, M)`, with the gold rule of §3.5: same color, or
  /// either nest is only gold ("matches any color"). A nest that contains
  /// gold among other dolls has their color, so it is compared by that.
  static bool colorsMatch(int a, int b) {
    final ca = color(a);
    final cb = color(b);
    return ca == cb || (((_wildColors >> ca) | (_wildColors >> cb)) & 1) == 1;
  }

  /// The nest made by putting [innerNest] inside [outerNest], which must
  /// satisfy `outer(innerNest) == inner(outerNest) − 1` and [colorsMatch].
  ///
  /// Spec §2.2: rule 2 (inside) is `merge(T, M)`, rule 3 (swallow) is
  /// `merge(M, T)`. With gold (§3.5) the merged nest takes the color of its
  /// non-gold dolls and remembers the golden doll's size. Spec §3.5 allows
  /// at most one golden doll per level, so at most one side carries one.
  static int merge(int outerNest, int innerNest) {
    final outerColor = color(outerNest);
    final innerColor = color(innerNest);
    final outerWild = isWildColor(outerColor);
    final innerWild = isWildColor(innerColor);
    var goldSize = gold(outerNest) | gold(innerNest);
    if (outerWild != innerWild) {
      // The only-gold side is a single golden doll (at most one per level).
      goldSize = outerWild ? outer(outerNest) : outer(innerNest);
    }
    return pack(
      outerWild ? innerColor : outerColor,
      outer(outerNest),
      length(outerNest) + length(innerNest),
      goldSize,
    );
  }

  /// True when [code] holds every size from [maxSize] down to 1, a full set
  /// that completes (spec §2.1, §4 "merged is full").
  static bool isFull(int code, int maxSize) =>
      outer(code) == maxSize && length(code) == maxSize;

  /// Dolls of the nest's own color, the golden doll excluded (spec §3.5,
  /// §5.3 rule 4 "gold dolls are exempt from this count").
  static int ownColorDolls(int code) {
    if (isWildColor(color(code))) return 0;
    return length(code) - (gold(code) == 0 ? 0 : 1);
  }

  /// The model view of [code].
  ///
  /// The `Nest` model has no golden doll inside a nest of another color yet,
  /// so such a nest reads back as its color's run.
  // TODO(v1.1): Nest view for a mixed gold nest (spec §3.5); needs a Nest
  // model that records the golden doll's position.
  static Nest toNest(int code) => Nest.run(
    DollColor.values[color(code)],
    outer: outer(code),
    length: length(code),
  );
}
