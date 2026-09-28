import 'dart:ui' show Color;

/// The flat stand-ins a board piece draws as when its art is unavailable
/// (the fake env, or a board SVG that failed to load: CLAUDE.md rule 3),
/// shared by the board's slots and shelves and the intro cards' pictures
/// of the same pieces (frames 4.1–4.3).
abstract final class BoardStandIns {
  /// A glass case (spec §3.3).
  static const Color glass = Color(0x66CFE9F7);

  /// An ice overlay (spec §3.4).
  static const Color ice = Color(0x809ED3F2);

  /// A slot stand or tower base.
  static const Color stand = Color(0xFFB9793F);
}
