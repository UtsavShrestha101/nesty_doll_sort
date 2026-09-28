import 'package:nesty_core/nesty_core.dart';

/// The mechanics with a one-time intro card (spec §3, §7.6, §10.2 #8;
/// frames 4.1–4.3; docs/plans/m3-design.md §10.4). The card shows once, on
/// the first board that has the mechanic (L16, L31 and L51 on the §3.7
/// schedule, or a daily or bonus board that meets it first).
enum IntroMechanic {
  /// Frame 4.1 "Towers!": a tower slot on the board.
  towers('towers'),

  /// Frame 4.2 "Glass Cases": a locked slot on the board.
  glass('glass'),

  /// Frame 4.3 "Ice": a slot with ice on the board.
  ice('ice');

  const IntroMechanic(this.id);

  /// The id kept in the save's `seenIntros` (a storage contract: never
  /// rename one).
  final String id;

  /// The mechanic with [id], or null.
  static IntroMechanic? tryFromId(String id) {
    for (final mechanic in values) {
      if (mechanic.id == id) return mechanic;
    }
    return null;
  }

  /// True when [level]'s starting board uses this mechanic. It reads the
  /// level's content, not a rule (CLAUDE.md rule 2).
  bool isIn(Level level) {
    for (final shelf in level.shelves) {
      for (final slot in shelf) {
        final found = switch (this) {
          towers => slot is TowerSlot,
          glass => slot is LockedSlot,
          ice => slot.ice > 0,
        };
        if (found) return true;
      }
    }
    return false;
  }

  /// The mechanics on [level], in card order (towers, glass, ice).
  static List<IntroMechanic> presentIn(Level level) => [
    for (final mechanic in values)
      if (mechanic.isIn(level)) mechanic,
  ];
}
