import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_tools/src/levels/finding.dart';
import 'package:nesty_tools/src/levels/layout_signature.dart';

/// One bundled level in play order, for the checks that compare a level
/// with its neighbours ([BundlePolicy.checkVariety]).
typedef OrderedLevel = ({int order, Level level, String subject});

/// What `nesty_levels bundle check` requires of the bundled levels beyond
/// validation rules 1–8 (design §4): the declared tier follows the spec §6.6
/// pattern and matches the simulator (A32), chapters are 20 levels (§7.1),
/// mechanics arrive on the spec §3.7 schedule, boards fit the layouts the M2
/// game draws, no two neighbours share a layout, and from L31 the smart bot
/// wins at least half its runs (brainstorm §3 E12).
abstract final class BundlePolicy {
  /// The guided tutorials (spec §7.6: L1 nesting, L2 swallow). They may
  /// keep a declared tier the simulator disagrees with (design §4), as may
  /// open-slot-only boards ([isOpenSlotsOnly], D26).
  static const Set<int> tutorialOrders = {1, 2};

  /// True when every slot of [level] is an open slot without ice.
  ///
  /// Such a board can't simulate as anything but easy (D26, resolving the
  /// §3.7 / §6.6 / A32 conflict): each color with pieces left still holds
  /// the same number k of dolls of every size, so for each size s > 1 the
  /// nests whose inner doll is s are as many as those whose outer doll is
  /// s − 1. A color that isn't complete therefore always has a legal merge,
  /// every merge lowers the nest count by 1, and the casual bot (a merge 70%
  /// of the time, spec §6.4) always wins well inside the move cap. Towers
  /// arrive at L16, locks at L31 and ice at L51 (§3.7), so L3–L15 can't
  /// reach the medium, hard and superhard tiers the §6.6 pattern gives them.
  /// Those levels keep their §6.6 tier (its badge and coins, §7.3) with a
  /// `tierOverride` reason.
  static bool isOpenSlotsOnly(Level level) => level.shelves.every(
    (shelf) => shelf.every((slot) => slot is OpenSlot && slot.ice == 0),
  );

  /// Levels per chapter (spec §7.1).
  static const int levelsPerChapter = 20;

  /// Shelves per board: the M2 layout has presets for 2 and 3 shelves only
  /// (design-foundation §1; 1 and 4 shelves are undesigned, D22).
  static const int minShelves = 2;

  /// See [minShelves].
  static const int maxShelves = 3;

  /// Authored slots per shelf: the M2 layout plans at most 4 per row
  /// (design §4), which also leaves the bottom row room for both extra slots
  /// (owner override D22).
  static const int maxRowSlots = 4;

  /// The first play order where an expert-only level (the smart bot wins
  /// under half its runs, spec §6.4) is an error rather than a warning
  /// (brainstorm §3 E12): the levels from L31 are made for M7 (D90), while
  /// L1–L30 were authored and accepted in M2.
  static const int expertOnlyErrorFrom = 31;

  /// The chapter id of play order [order]: `ch01` for 1–20, `ch02` for
  /// 21–40, …
  static String chapterFor(int order) =>
      'ch${((order - 1) ~/ levelsPerChapter + 1).toString().padLeft(2, '0')}';

  /// The largest `maxSize` spec §3.7 allows at [order]: 3 until maxSize 4
  /// arrives at L10, 4 until L71, 5 until the occasional maxSize 6 from
  /// L121.
  static int maxSizeCap(int order) => order < 10
      ? 3
      : order < 71
      ? 4
      : order < 121
      ? 5
      : 6;

  /// The §6.6 pattern, the chapter, the §3.7 schedule and the M2 layout for
  /// the level at [order] declared as [declared] in [chapterId]. [subject]
  /// names the level in findings.
  static List<Finding> check({
    required int order,
    required String chapterId,
    required Tier declared,
    required Level level,
    required String subject,
  }) {
    final findings = <Finding>[];
    void error(String code, String message) =>
        findings.add(Finding(code, message, subject: subject));

    final expectedTier = DifficultyCurve.tierForLevel(order);
    if (declared != expectedTier) {
      error(
        FindingCodes.pattern,
        'L$order is declared ${declared.id}, but the spec §6.6 pattern '
        '(E E M E M H M E M S per 10 levels) makes it ${expectedTier.id}',
      );
    }
    final expectedChapter = chapterFor(order);
    if (chapterId != expectedChapter) {
      error(
        FindingCodes.chapter,
        'L$order is in chapter $chapterId, but chapters are '
        '$levelsPerChapter levels each (spec §7.1), so it belongs in '
        '$expectedChapter',
      );
    }

    // --- Spec §3.7 introduction schedule ---
    final features = _Features.of(level);
    final cap = maxSizeCap(order);
    if (level.maxSize > cap) {
      error(
        FindingCodes.scheduleMaxSize,
        'maxSize ${level.maxSize} at L$order: spec §3.7 allows at most '
        '$cap there',
      );
    }
    for (final (intro, size) in const [(10, 4), (71, 5)]) {
      if (order == intro && level.maxSize != size) {
        error(
          FindingCodes.scheduleMaxSize,
          'L$intro introduces maxSize $size (spec §3.7), but its maxSize is '
          '${level.maxSize}',
        );
      }
    }
    // Spec §3.7: from L121, "occasional maxSize 6 'super hard' levels", so a
    // board of sixes is always a superhard slot of the §6.6 pattern
    // (brainstorm §4: L130, L140 … L200).
    if (level.maxSize == 6 && expectedTier != Tier.superhard) {
      error(
        FindingCodes.scheduleMaxSize,
        'maxSize 6 at L$order, a ${expectedTier.id} slot: spec §3.7 keeps '
        'maxSize 6 for super hard levels',
      );
    }
    final colors = features.colors;
    if (order == 1 && colors != 1) {
      error(
        FindingCodes.scheduleColors,
        'L1 teaches nesting with 1 color (spec §3.7); it has $colors',
      );
    } else if (order == 2 && colors != 2) {
      error(
        FindingCodes.scheduleColors,
        'L2 teaches the swallow with 2 colors (spec §3.7); it has $colors',
      );
    } else if (order >= 3 && order <= 9 && colors > 4) {
      error(
        FindingCodes.scheduleColors,
        'L3–9 use up to 4 colors (spec §3.7); L$order has $colors',
      );
    }
    _mechanic(
      error,
      order: order,
      intro: 16,
      present: features.towers,
      code: FindingCodes.scheduleTowers,
      name: 'tower slots',
    );
    _mechanic(
      error,
      order: order,
      intro: 31,
      present: features.locked,
      code: FindingCodes.scheduleLocked,
      name: 'locked slots',
    );
    _mechanic(
      error,
      order: order,
      intro: 51,
      present: features.ice,
      code: FindingCodes.scheduleIce,
      name: 'ice',
    );

    // --- M2 layout (design §4) ---
    final shelves = level.shelves.length;
    if (shelves < minShelves || shelves > maxShelves) {
      error(
        FindingCodes.layoutShelves,
        '$shelves shelves: the M2 board layout draws $minShelves–$maxShelves '
        '(design §4)',
      );
    }
    for (var row = 0; row < shelves; row++) {
      final slots = level.shelves[row].length;
      if (slots > maxRowSlots) {
        error(
          FindingCodes.layoutRowSlots,
          'Shelf $row has $slots slots: the M2 board layout plans at most '
          '$maxRowSlots per row (design §4)',
        );
      }
    }
    return findings;
  }

  /// Spec §3.7: a mechanic appears first at its [intro] level, not before.
  static void _mechanic(
    void Function(String code, String message) error, {
    required int order,
    required int intro,
    required bool present,
    required String code,
    required String name,
  }) {
    if (order < intro && present) {
      error(code, 'L$order uses $name, which spec §3.7 introduces at L$intro');
    } else if (order == intro && !present) {
      error(code, 'L$intro introduces $name (spec §3.7), but has none');
    }
  }

  /// Design A32: the simulated tier must equal the declared one. A tutorial
  /// ([tutorialOrders]) or an open-slot-only [level] ([isOpenSlotsOnly],
  /// D26) may keep its declared tier with a [tierOverride] reason; anywhere
  /// else an override is an error and does not excuse a mismatch. An
  /// expert-only level (smart win rate below 0.5, spec §6.4) is an error
  /// from [expertOnlyErrorFrom] (brainstorm §3 E12) and a warning before.
  static List<Finding> checkTier({
    required int order,
    required Tier declared,
    required String? tierOverride,
    required SimulationResult simulation,
    required Level level,
    required String subject,
  }) {
    final findings = <Finding>[];
    final simulated = simulation.tier;
    final overridable =
        tutorialOrders.contains(order) || isOpenSlotsOnly(level);
    if (tierOverride != null && !overridable) {
      findings.add(
        Finding(
          FindingCodes.tierOverrideNotTutorial,
          'Only the tutorials (L${tutorialOrders.join(', L')}) and boards '
          'of open slots without ice may override the simulated tier '
          '(design §4, D26)',
          subject: subject,
        ),
      );
    }
    if (simulated != declared) {
      if (tierOverride == null || !overridable) {
        findings.add(
          Finding(
            FindingCodes.tierMismatch,
            'Declared ${declared.id}, but the simulator says ${simulated.id} '
            '(casual ${simulation.casual.wins}/${simulation.casual.runs} '
            'wins, spec §6.4). Rework the board, or re-order the levels',
            subject: subject,
          ),
        );
      }
    } else if (tierOverride != null && overridable) {
      findings.add(
        Finding(
          FindingCodes.tierOverrideUnneeded,
          'The simulator agrees with the declared ${declared.id}; drop the '
          'tierOverride',
          subject: subject,
          severity: FindingSeverity.warning,
        ),
      );
    }
    if (simulation.expertOnly) {
      final isError = order >= expertOnlyErrorFrom;
      findings.add(
        Finding(
          FindingCodes.expertOnly,
          'Expert only: the smart bot wins ${simulation.smart.wins}/'
          '${simulation.smart.runs}, below half (spec §6.4)'
          '${isError ? '. From L$expertOnlyErrorFrom a bundled level must '
                    'not be expert only (E12): rework the board' : ''}',
          subject: subject,
          severity: isError ? FindingSeverity.error : FindingSeverity.warning,
        ),
      );
    }
    return findings;
  }

  /// Brainstorm §3 E12: two consecutive [levels] (in play order) must not
  /// share a [LayoutSignature], or the second reads as a reskin of the
  /// first. The tutorials ([tutorialOrders]) are exempt among themselves:
  /// they teach one move on one small board each. Only orders that follow
  /// each other are compared, so a level missing from the list (a file that
  /// didn't load, already reported) never pairs up two others.
  static List<Finding> checkVariety(List<OrderedLevel> levels) {
    final findings = <Finding>[];
    for (var i = 1; i < levels.length; i++) {
      final previous = levels[i - 1];
      final current = levels[i];
      if (current.order != previous.order + 1) continue;
      if (tutorialOrders.contains(previous.order) &&
          tutorialOrders.contains(current.order)) {
        continue;
      }
      final signature = LayoutSignature.of(current.level);
      if (signature != LayoutSignature.of(previous.level)) continue;
      findings.add(
        Finding(
          FindingCodes.varietySameLayout,
          'L${current.order} has the same layout as L${previous.order} '
          '(${previous.subject}): $signature. Consecutive levels need '
          'another shape, tower count or depth, glass, ice, color count or '
          'maxSize (E12)',
          subject: current.subject,
        ),
      );
    }
    return findings;
  }
}

/// The mechanics a board uses, for the §3.7 schedule.
final class _Features {
  _Features(
    this.colors, {
    required this.towers,
    required this.locked,
    required this.ice,
  });

  factory _Features.of(Level level) {
    final colors = <DollColor>{};
    var towers = false;
    var locked = false;
    var ice = false;
    for (final shelf in level.shelves) {
      for (final slot in shelf) {
        for (final nest in slot.nests) {
          for (final doll in nest.dolls) {
            if (!doll.color.isWild) colors.add(doll.color);
          }
        }
        towers |= slot is TowerSlot;
        locked |= slot is LockedSlot;
        ice |= slot.ice > 0;
      }
    }
    return _Features(colors.length, towers: towers, locked: locked, ice: ice);
  }

  /// Distinct doll colors, gold excluded.
  final int colors;
  final bool towers;
  final bool locked;
  final bool ice;
}
