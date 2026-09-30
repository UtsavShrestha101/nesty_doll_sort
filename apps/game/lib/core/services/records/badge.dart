/// The twelve cosmetic badges of E8 (spec-prop §7.8; the draft list of
/// docs/plans/offline-game-brainstorm.md §3 E8, Q83; docs/plans/
/// m7-design.md §12). Badges pay nothing, never expire and are counted over
/// the player's lifetime, never over consecutive days.
///
/// [id] is what the save's `records.badges` stores (a storage contract:
/// never rename or reuse one). The names and art are placeholders until
/// Claude Design delivers them (`badgeName` in the ARB, request §I.6). The
/// order here is the Records screen's grid order and the order a win's new
/// badges are reported in.
enum BadgeId {
  /// Complete a family: the first win of any kind.
  firstFamily('first_family'),

  /// Open a glass case: win a board that started with one (spec §3.3).
  glassBreaker('glass_breaker'),

  /// Shatter ice: win a board on which an iced slot thawed (spec §3.4).
  iceMelter('ice_melter'),

  /// Win a board with `maxSize` 5 or more.
  tallOrder('tall_order'),

  /// Win a board with `maxSize` 6.
  grandNest('grand_nest'),

  /// Win campaign level 100.
  level100('level_100'),

  /// Win campaign level 200.
  level200('level_200'),

  /// Solve 7 dailies (any 7 dates, not in a row).
  dailies7('dailies_7'),

  /// Solve 30 dailies (any 30 dates).
  dailies30('dailies_30'),

  /// Win a vs Computer race (phase 2).
  firstRace('first_race'),

  /// Beat each of the three computer rivals at least once (phase 2).
  allRivals('all_rivals'),

  /// Collect every launch figurine (chapters 1–10, spec §7.2).
  museumFull('museum_full');

  const BadgeId(this.id);

  /// The id `records.badges` stores and the `badgeName` ARB select key.
  final String id;

  /// The badge stored as [id], or null for an unknown one (a newer app's,
  /// kept in the save but not shown).
  static BadgeId? tryFromId(Object? id) {
    for (final badge in values) {
      if (badge.id == id) return badge;
    }
    return null;
  }
}
