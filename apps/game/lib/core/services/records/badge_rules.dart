import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/repository/bundled_catalog_repository.dart';
import 'package:nesty_game/core/services/save/save_document.dart';

/// When each [BadgeId] is earned (spec-prop §7.8; docs/plans/m7-design.md
/// §12). Pure and deterministic: every trigger is a function of a won
/// level or of the save document, counted over the player's lifetime,
/// never over consecutive days, and nothing random (spec-prop §1.1).
///
/// Badges are only ever added, in two places:
/// - a win's one save update (`SaveService.recordLevelWin`): the won
///   level's [forWonLevel] badges plus the [derivable] ones of the
///   document after the win; those are the win's `newBadges` (a toast
///   each);
/// - `SaveService.load`: the [derivable] ones, silently (a migrated save,
///   or one from before a badge existed).
abstract final class BadgeRules {
  /// Campaign level 100 won: `highestLevel` moves past a campaign order
  /// when it is won (m3-design §3.5).
  static const int level100HighestLevel = 101;

  /// Campaign level 200 won.
  static const int level200HighestLevel = 201;

  /// Dailies solved for [BadgeId.dailies7] and [BadgeId.dailies30].
  static const int dailiesWeek = 7;
  static const int dailiesMonth = 30;

  /// `maxSize` of a [BadgeId.tallOrder] and a [BadgeId.grandNest] board.
  static const int tallMaxSize = 5;
  static const int grandMaxSize = 6;

  /// The launch figurines' chapters (ch01–ch10, spec §7.2): the Museum is
  /// full once all of them are in `museum`. Chapters published later (M4)
  /// add figurines but never take [BadgeId.museumFull] away.
  static final Set<String> launchFigurineChapters = {
    for (final chapter in BundledCatalogRepository.bundledChapters) chapter.id,
  };

  /// The badges winning [level] earns by itself (m7-design §12), whatever
  /// the mode (campaign, replay, bonus, daily; races in phase 2):
  /// - [BadgeId.glassBreaker]: it has a glass case. A win completes every
  ///   set, and a case breaks at its colour's first (spec §3.3, §5.3
  ///   rule 6), so every case on a won board was opened;
  /// - [BadgeId.iceMelter]: it has a slot whose ice is at most its set
  ///   count. Every completed set lowers every counter by 1 (spec §3.4),
  ///   so that ice shattered by the win;
  /// - [BadgeId.tallOrder]: `maxSize` 5 or more;
  /// - [BadgeId.grandNest]: `maxSize` 6.
  ///
  /// In [BadgeId] order.
  static List<BadgeId> forWonLevel(Level level) {
    var glass = false;
    var ice = false;
    for (final shelf in level.shelves) {
      for (final slot in shelf) {
        if (slot is LockedSlot) glass = true;
        if (slot.ice > 0 && slot.ice <= level.totalSets) ice = true;
      }
    }
    return [
      if (glass) BadgeId.glassBreaker,
      if (ice) BadgeId.iceMelter,
      if (level.maxSize >= tallMaxSize) BadgeId.tallOrder,
      if (level.maxSize >= grandMaxSize) BadgeId.grandNest,
    ];
  }

  /// The badges [doc] implies on its own (m7-design §12):
  /// - [BadgeId.firstFamily]: a family completed (`records.families`), or
  ///   any win at all (`stats.wins`: every win completes a family; a
  ///   schema-1 save has wins but no records);
  /// - [BadgeId.level100], [BadgeId.level200]: `highestLevel` past them;
  /// - [BadgeId.dailies7], [BadgeId.dailies30]: `records.dailies`;
  /// - [BadgeId.firstRace]: a race won against any rival;
  /// - [BadgeId.allRivals]: every rival beaten at least once;
  /// - [BadgeId.museumFull]: every [launchFigurineChapters] collected.
  ///
  /// The board badges ([forWonLevel]) are never derivable: the save keeps
  /// no list of the boards won.
  static Set<BadgeId> derivable(SaveDocument doc) {
    final rivals = doc.race.rivals;
    return {
      if (doc.records.families >= 1 || doc.stats.wins >= 1) BadgeId.firstFamily,
      if (doc.highestLevel >= level100HighestLevel) BadgeId.level100,
      if (doc.highestLevel >= level200HighestLevel) BadgeId.level200,
      if (doc.records.dailies >= dailiesWeek) BadgeId.dailies7,
      if (doc.records.dailies >= dailiesMonth) BadgeId.dailies30,
      if (rivals.any((rival) => rival.wins >= 1)) BadgeId.firstRace,
      if (rivals.isNotEmpty && rivals.every((rival) => rival.wins >= 1))
        BadgeId.allRivals,
      if (launchFigurineChapters.every(doc.museum.contains)) BadgeId.museumFull,
    };
  }

  /// [earned] minus what [records] already holds, in [BadgeId] order: the
  /// badges an update adds.
  static List<BadgeId> newlyEarned(
    Iterable<BadgeId> earned,
    SaveRecords records,
  ) {
    final set = earned.toSet();
    return [
      for (final badge in BadgeId.values)
        if (set.contains(badge) && !records.has(badge)) badge,
    ];
  }

  /// [doc] with every [derivable] badge added (unchanged when none is
  /// new): the load-time grant.
  static SaveDocument withDerivable(SaveDocument doc) {
    final fresh = newlyEarned(derivable(doc), doc.records);
    if (fresh.isEmpty) return doc;
    return doc.copyWith(
      records: doc.records.copyWith(
        badges: [...doc.records.badges, for (final badge in fresh) badge.id],
      ),
    );
  }
}
