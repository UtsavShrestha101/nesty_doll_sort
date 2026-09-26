import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_tools/src/levels/bundle_policy.dart';
import 'package:nesty_tools/src/levels/finding.dart';
import 'package:test/test.dart';

Nest nest(DollColor color, int outer, [int length = 1]) =>
    Nest.run(color, outer: outer, length: length);

/// One full set per color in [colors], each as two nests (the outer doll,
/// then the rest), on [rows] shelves of [perRow] slots (extra slots empty).
/// maxSize 3 unless given. [modify] swaps in special slots.
Level board({
  List<DollColor> colors = const [DollColor.red],
  int maxSize = 3,
  int rows = 2,
  int perRow = 3,
  Slot Function(int index, Slot slot)? modify,
}) {
  final nests = [
    for (final color in colors) ...[
      nest(color, maxSize),
      nest(color, maxSize - 1, maxSize - 1),
    ],
  ];
  var index = 0;
  return Level(
    id: 'T',
    maxSize: maxSize,
    shelves: [
      for (var r = 0; r < rows; r++)
        [
          for (var c = 0; c < perRow; c++)
            () {
              final i = index++;
              final Slot slot = OpenSlot(
                nest: i < nests.length ? nests[i] : null,
              );
              return modify == null ? slot : modify(i, slot);
            }(),
        ],
    ],
  );
}

List<String> check(
  int order,
  Level level, {
  Tier? declared,
  String? chapterId,
}) => [
  for (final f in BundlePolicy.check(
    order: order,
    chapterId: chapterId ?? BundlePolicy.chapterFor(order),
    declared: declared ?? DifficultyCurve.tierForLevel(order),
    level: level,
    subject: 'L$order',
  ))
    f.code,
];

SimulationResult sim(int casualWins, {int smartWins = 300}) =>
    SimulationResult.fromStats(
      casual: BotStats(runs: 300, wins: casualWins),
      smart: BotStats(runs: 300, wins: smartWins),
      seed: 0,
    );

/// A board with a tower: its simulated tier is a real measurement, so only
/// the tutorials may override it.
Level towerBoard() => board(
  colors: const [DollColor.red, DollColor.blue],
  modify: (i, slot) => i == 0
      ? TowerSlot([nest(DollColor.blue, 3), nest(DollColor.red, 3)])
      : i == 2
      ? OpenSlot()
      : slot,
);

List<Finding> tier(
  int order,
  Tier declared,
  SimulationResult simulation, {
  String? tierOverride,
  Level? level,
}) => BundlePolicy.checkTier(
  order: order,
  declared: declared,
  tierOverride: tierOverride,
  simulation: simulation,
  level: level ?? towerBoard(),
  subject: 'L$order',
);

const fourColors = [
  DollColor.red,
  DollColor.blue,
  DollColor.green,
  DollColor.yellow,
];

void main() {
  test('chapters are 20 levels (spec §7.1)', () {
    expect(BundlePolicy.chapterFor(1), 'ch01');
    expect(BundlePolicy.chapterFor(20), 'ch01');
    expect(BundlePolicy.chapterFor(21), 'ch02');
    expect(BundlePolicy.chapterFor(200), 'ch10');
    expect(
      check(
        21,
        board(colors: fourColors, rows: 3, perRow: 4),
        chapterId: 'ch01',
      ),
      [FindingCodes.chapter],
    );
  });

  group('spec §6.6 pattern E E M E M H M E M S', () {
    test('every order of the first two blocks', () {
      const pattern = 'EEMEMHMEMSEEMEMHMEMS';
      const byLetter = {
        'E': Tier.easy,
        'M': Tier.medium,
        'H': Tier.hard,
        'S': Tier.superhard,
      };
      final level = board(colors: fourColors, maxSize: 4, rows: 3, perRow: 4);
      for (var order = 10; order <= 15; order++) {
        final expected = byLetter[pattern[order - 1]]!;
        for (final declared in Tier.values) {
          final codes = check(
            order,
            order == 10 ? level : board(colors: fourColors, rows: 3, perRow: 4),
            declared: declared,
          );
          expect(
            codes.contains(FindingCodes.pattern),
            declared != expected,
            reason: 'L$order declared ${declared.id}',
          );
        }
      }
    });

    test('the tutorials are easy', () {
      expect(check(1, board(), declared: Tier.medium), [FindingCodes.pattern]);
      expect(check(1, board()), isEmpty);
    });
  });

  group('spec §3.7 schedule', () {
    test('L1 has one color, L2 two, L3–9 at most four', () {
      final two = board(colors: [DollColor.red, DollColor.blue]);
      expect(check(1, two), [FindingCodes.scheduleColors]);
      expect(check(2, board()), [FindingCodes.scheduleColors]);
      expect(check(2, two), isEmpty);
      final five = board(
        colors: [...fourColors, DollColor.pink],
        rows: 3,
        perRow: 4,
        maxSize: 3,
      );
      expect(check(9, five), [FindingCodes.scheduleColors]);
      expect(check(9, board(colors: fourColors, rows: 3, perRow: 4)), isEmpty);
      expect(
        check(
          11,
          board(colors: [...fourColors, DollColor.pink], rows: 3, perRow: 4),
        ),
        isEmpty,
        reason: 'the spec caps colors only up to L9',
      );
    });

    test(
      'maxSize: 3 before L10, 4 introduced at L10, capped at 4 until L71',
      () {
        final size4 = board(
          colors: [DollColor.red, DollColor.blue],
          maxSize: 4,
          perRow: 4,
        );
        final size3 = board(colors: [DollColor.red, DollColor.blue]);
        final size5 = board(
          colors: [DollColor.red, DollColor.blue],
          maxSize: 5,
          perRow: 4,
          rows: 3,
        );
        expect(check(9, size4), [FindingCodes.scheduleMaxSize]);
        expect(check(10, size3), [FindingCodes.scheduleMaxSize]);
        expect(check(10, size4), isEmpty);
        expect(check(11, size3), isEmpty, reason: 'smaller boards may return');
        expect(check(70, size5), [FindingCodes.scheduleMaxSize]);
        expect(check(71, size4), [FindingCodes.scheduleMaxSize]);
        expect(check(71, size5), isEmpty);
        expect(BundlePolicy.maxSizeCap(120), 5);
        expect(BundlePolicy.maxSizeCap(121), 6);
      },
    );

    Level withTower() => board(
      colors: [DollColor.red, DollColor.blue],
      maxSize: 3,
      modify: (i, slot) => i == 0
          ? TowerSlot([nest(DollColor.blue, 3), nest(DollColor.red, 3)])
          : slot,
    );
    Level withLock() => board(
      colors: [DollColor.red, DollColor.blue],
      modify: (i, slot) => i == 0
          ? LockedSlot(
              unlockColor: DollColor.blue,
              nest: nest(DollColor.red, 3),
            )
          : slot,
    );
    Level withIce() => board(
      colors: [DollColor.red, DollColor.blue],
      modify: (i, slot) =>
          i == 0 ? OpenSlot(nest: nest(DollColor.red, 3), ice: 1) : slot,
    );

    test('towers appear first at L16', () {
      expect(check(15, withTower()), [FindingCodes.scheduleTowers]);
      expect(check(16, board(colors: fourColors, rows: 3, perRow: 4)), [
        FindingCodes.scheduleTowers,
      ]);
      expect(check(16, withTower()), isEmpty);
      expect(check(17, board(colors: fourColors, rows: 3, perRow: 4)), isEmpty);
    });

    test('locks appear first at L31, ice at L51', () {
      expect(check(30, withLock()), [FindingCodes.scheduleLocked]);
      expect(check(31, withTower()), [FindingCodes.scheduleLocked]);
      expect(check(31, withLock()), isEmpty);
      expect(check(50, withIce()), [FindingCodes.scheduleIce]);
      expect(check(51, withLock()), [FindingCodes.scheduleIce]);
      expect(check(51, withIce()), isEmpty);
    });
  });

  group('M2 layout', () {
    test('2–3 shelves', () {
      expect(check(3, board(colors: fourColors, rows: 1, perRow: 5)), [
        FindingCodes.layoutShelves,
        FindingCodes.layoutRowSlots,
      ]);
      expect(check(3, board(colors: fourColors, rows: 4, perRow: 3)), [
        FindingCodes.layoutShelves,
      ]);
    });

    test('at most 4 slots per row', () {
      expect(check(3, board(colors: fourColors, rows: 3, perRow: 5)), [
        FindingCodes.layoutRowSlots,
        FindingCodes.layoutRowSlots,
        FindingCodes.layoutRowSlots,
      ]);
    });
  });

  group('tier (design A32)', () {
    test('the simulated tier must equal the declared one', () {
      expect(tier(3, Tier.medium, sim(150)), isEmpty);
      final mismatch = tier(3, Tier.medium, sim(195));
      expect(mismatch.map((f) => f.code), [FindingCodes.tierMismatch]);
      expect(mismatch.single.message, contains('easy'));
      expect(mismatch.single.message, contains('195/300'));
    });

    test('a tutorial may keep its tier with a reason', () {
      expect(
        tier(2, Tier.easy, sim(104), tierOverride: 'Teaches the swallow'),
        isEmpty,
      );
    });

    test('an override on any other board is an error, and does not excuse', () {
      expect(
        tier(
          3,
          Tier.medium,
          sim(300),
          tierOverride: 'Because',
        ).map((f) => f.code),
        [FindingCodes.tierOverrideNotTutorial, FindingCodes.tierMismatch],
      );
    });

    group('open slots only (D26: always easy, spec §3.7 / §6.6)', () {
      final open = board(colors: fourColors, rows: 3, perRow: 3);

      test('isOpenSlotsOnly', () {
        expect(BundlePolicy.isOpenSlotsOnly(open), isTrue);
        expect(BundlePolicy.isOpenSlotsOnly(towerBoard()), isFalse);
        expect(
          BundlePolicy.isOpenSlotsOnly(
            board(
              colors: fourColors,
              rows: 3,
              modify: (i, slot) => i == 8 ? OpenSlot(ice: 1) : slot,
            ),
          ),
          isFalse,
          reason: 'ice',
        );
        expect(
          BundlePolicy.isOpenSlotsOnly(
            board(
              colors: fourColors,
              rows: 3,
              modify: (i, slot) =>
                  i == 8 ? LockedSlot(unlockColor: DollColor.red) : slot,
            ),
          ),
          isFalse,
          reason: 'a glass case',
        );
      });

      test('keeps its §6.6 tier with a reason', () {
        expect(
          tier(
            6,
            Tier.hard,
            sim(300),
            tierOverride: 'Towerless; hard by splitting every family',
            level: open,
          ),
          isEmpty,
        );
      });

      test('still needs the reason to differ from the simulator', () {
        expect(tier(6, Tier.hard, sim(300), level: open).map((f) => f.code), [
          FindingCodes.tierMismatch,
        ]);
      });

      test('an override the simulator agrees with is still unneeded', () {
        expect(
          tier(
            4,
            Tier.easy,
            sim(300),
            tierOverride: 'Easy anyway',
            level: open,
          ).map((f) => f.code),
          [FindingCodes.tierOverrideUnneeded],
        );
      });

      test('a board with a tower may not override', () {
        expect(
          tier(
            17,
            Tier.medium,
            sim(300),
            tierOverride: 'Because',
            level: towerBoard(),
          ).map((f) => f.code),
          [FindingCodes.tierOverrideNotTutorial, FindingCodes.tierMismatch],
        );
      });
    });

    test('an unneeded override is a warning', () {
      final findings = tier(
        1,
        Tier.easy,
        sim(300),
        tierOverride: 'Just in case',
      );
      expect(findings.map((f) => f.code), [FindingCodes.tierOverrideUnneeded]);
      expect(findings.single.isError, isFalse);
    });

    test('expert only (smart below half) is a warning', () {
      final findings = tier(6, Tier.hard, sim(50, smartWins: 149));
      expect(findings.map((f) => f.code), [FindingCodes.expertOnly]);
      expect(findings.single.isError, isFalse);
      expect(tier(6, Tier.hard, sim(50, smartWins: 150)), isEmpty);
    });
  });
}
