/// The doll colors of spec §12.3, declared in table order.
///
/// Only the facts that game rules and the level codec need live here: the
/// stable codec [id] and whether the color is wild. Display names, hex values
/// and symbols are presentation concerns and live in `nesty_render` / ARB
/// strings, which keeps this package free of UI knowledge (CLAUDE.md rule 2).
enum DollColor {
  red('red'),
  orange('orange'),
  yellow('yellow'),
  green('green'),
  teal('teal'),
  blue('blue'),
  purple('purple'),
  pink('pink'),
  navy('navy'),
  brown('brown'),

  /// The golden doll counts as any color when merging (spec §3.5).
  gold('gold', isWild: true);

  const DollColor(this.id, {this.isWild = false});

  /// Stable identifier written by the level codec, e.g. the `red` in `"red4"`
  /// (spec §5.1).
  ///
  /// Kept separate from [name] so renaming a Dart identifier can never change
  /// the level format. Ids are lowercase ASCII letters only, so the codec can
  /// split `"<color><size>"` at the first digit.
  final String id;

  /// True only for [gold], which matches any color when merging (spec §3.5).
  ///
  /// The rules engine's `colorsMatch(T, M)` (spec §4) reads this flag.
  final bool isWild;

  // Built once: fromId runs for every doll of every level the codec decodes.
  static final Map<String, DollColor> _byId = {
    for (final color in values) color.id: color,
  };

  /// Returns the color whose [id] is exactly [id].
  ///
  /// Throws a [FormatException] for anything else, including different case
  /// or surrounding whitespace. Levels come from Firestore and bundled JSON,
  /// and a strict parse lets the loader reject a bad level (spec §5.3)
  /// instead of guessing.
  static DollColor fromId(String id) {
    final color = _byId[id];
    if (color == null) {
      throw FormatException(
        'Unknown doll color id "$id". Expected one of: '
        '${values.map((c) => c.id).join(', ')}.',
        id,
      );
    }
    return color;
  }
}
