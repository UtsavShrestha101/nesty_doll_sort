// Validator: the level checks of spec §5.3, with issue codes and ARB args,
// shared by the admin (rules 1–8) and the game loader (rules 1–7, A6).
//
// Platform-neutral (levels built in code, no dart:io). Rule 7 runs the real
// rules engine; rule 8 runs an injected fake solver, so these tests pin the
// validator's handling of each verdict, not the search.
import 'package:nesty_core/nesty_core.dart';
// Rules 1–6 alone, so "passes" tests don't depend on the rules engine.
import 'package:nesty_core/src/validator/level_checks.dart';
import 'package:test/test.dart';

const red = DollColor.red;
const blue = DollColor.blue;
const green = DollColor.green;
const gold = DollColor.gold;

Nest nest(DollColor color, int outer, [int length = 1]) =>
    Nest.run(color, outer: outer, length: length);

/// Tutorial level 1 (design TUT1): valid, 2 moves.
List<List<Slot>> tut1Shelves() => [
  [OpenSlot(nest: nest(red, 3)), OpenSlot(), OpenSlot(nest: nest(red, 2))],
  [OpenSlot(), OpenSlot(nest: nest(red, 1)), OpenSlot()],
];

Level level(
  List<List<Slot>> shelves, {
  int maxSize = 3,
  String id = 'V1',
  int schemaVersion = 1,
  int? generatorVersion,
  int? seed,
}) => Level(
  id: id,
  maxSize: maxSize,
  shelves: shelves,
  schemaVersion: schemaVersion,
  generatorVersion: generatorVersion,
  seed: seed,
);

/// TUT1 with the given level fields.
Level tut1With({
  int maxSize = 3,
  String id = 'V1',
  int schemaVersion = 1,
  int? generatorVersion,
  int? seed,
}) => level(
  tut1Shelves(),
  maxSize: maxSize,
  id: id,
  schemaVersion: schemaVersion,
  generatorVersion: generatorVersion,
  seed: seed,
);

List<LevelIssue> issuesOf(Level level) =>
    Validator.validate(level, options: ValidationOptions.loader).issues;

List<String> codesOf(Level level) => [for (final i in issuesOf(level)) i.code];

/// The codes of rules 1–6 and the level-field checks only: what a valid
/// level must pass before rule 7 runs.
List<String> staticCodes(Level level) => [
  for (final i in checkLevel(level)) i.code,
];

Matcher isIssue(
  String code, {
  String path = '',
  String? slotId,
  Map<String, Object>? args,
}) => isA<LevelIssue>()
    .having((i) => i.code, 'code', code)
    .having((i) => i.severity, 'severity', IssueSeverity.error)
    .having((i) => i.path, 'path', path)
    .having((i) => i.slotId, 'slotId', slotId)
    .having((i) => i.message, 'message', isNotEmpty)
    .having((i) => i.args, 'args', args ?? anything);

/// Three towers whose tops are all size 3 and no empty slot: rules 1–6 hold,
/// but nothing can move (rule 7).
Level noFirstMoveLevel() => level([
  [
    TowerSlot([nest(red, 2, 2), nest(blue, 3)]),
    TowerSlot([nest(blue, 2, 2), nest(green, 3)]),
    TowerSlot([nest(green, 2, 2), nest(red, 3)]),
  ],
]);

/// A fake rule-8 search that records its calls.
final class FakeSolver {
  FakeSolver(this.result);

  final SolveResult result;
  final List<(GameState, int)> calls = [];

  SolveResult solve(GameState state, {int budget = SolverBudgets.admin}) {
    calls.add((state, budget));
    return result;
  }
}

void main() {
  group('rule 1 (schema version, maxSize 3–6)', () {
    test('schema.unsupportedVersion for a level built in code', () {
      expect(issuesOf(tut1With(schemaVersion: 2)), [
        isIssue(
          IssueCodes.unsupportedVersion,
          path: '/schemaVersion',
          args: {'version': 2, 'supported': 1},
        ),
      ]);
    });

    for (final maxSize in [0, 2, 7]) {
      test('level.maxSizeOutOfRange: $maxSize', () {
        // The size and count checks measure against maxSize, so they are
        // skipped rather than reporting every doll as well.
        expect(issuesOf(tut1With(maxSize: maxSize)), [
          isIssue(
            IssueCodes.maxSizeOutOfRange,
            path: '/maxSize',
            args: {'maxSize': maxSize, 'min': 3, 'max': 6},
          ),
        ]);
      });
    }

    test('maxSize 3 to 6 passes rule 1', () {
      for (var maxSize = 3; maxSize <= 6; maxSize++) {
        final run = level([
          [
            OpenSlot(nest: nest(red, maxSize, maxSize - 1)),
            OpenSlot(nest: nest(red, 1)),
          ],
        ], maxSize: maxSize);
        expect(staticCodes(run), isEmpty);
      }
    });
  });

  group('level fields (design A20, A21)', () {
    test('level.badId: empty', () {
      expect(issuesOf(tut1With(id: '')), [
        isIssue(
          IssueCodes.badId,
          path: '/id',
          args: {'id': '', 'maxLength': 64},
        ),
      ]);
    });

    test('level.badId: longer than 64 characters', () {
      final id = 'L' * 65;
      expect(issuesOf(tut1With(id: id)), [
        isIssue(
          IssueCodes.badId,
          path: '/id',
          args: {'id': id, 'maxLength': 64},
        ),
      ]);
      expect(
        staticCodes(tut1With(id: 'L' * 64)),
        isNot(contains(IssueCodes.badId)),
      );
    });

    test('schema.valueOutOfRange: seed outside [0, 2^53 − 1]', () {
      for (final seed in [-1, Prng.maxSeed + 1]) {
        expect(issuesOf(tut1With(seed: seed)), [
          isIssue(
            IssueCodes.valueOutOfRange,
            path: '/seed',
            args: {
              'field': 'seed',
              'value': seed,
              'min': 0,
              'max': Prng.maxSeed,
            },
          ),
        ]);
      }
      for (final seed in [0, Prng.maxSeed]) {
        expect(
          staticCodes(tut1With(seed: seed, generatorVersion: 1)),
          isNot(contains(IssueCodes.valueOutOfRange)),
        );
      }
    });

    test('schema.valueOutOfRange: ice above 2^31 − 1', () {
      // The engine keeps ice in 32-bit lists: 2^31 would wrap to a negative
      // counter and 2^32 to 0, both playing as thawed (spec §3.4).
      for (final ice in [LayoutLimits.maxIce + 1, 4294967296, Prng.maxSeed]) {
        final shelves = tut1Shelves();
        shelves[0][2] = OpenSlot(nest: nest(red, 2), ice: ice);
        expect(issuesOf(level(shelves)), [
          isIssue(
            IssueCodes.valueOutOfRange,
            path: '/shelves/0/2/ice',
            slotId: 'r0c2',
            args: {
              'field': 'ice',
              'value': ice,
              'min': 0,
              'max': LayoutLimits.maxIce,
            },
          ),
        ]);
      }
      // 2^31 − 1 is stored exactly: red2 never thaws, so rule 8 proves the
      // level unsolvable instead of passing a wrapped counter.
      final shelves = tut1Shelves();
      shelves[0][2] = OpenSlot(nest: nest(red, 2), ice: LayoutLimits.maxIce);
      expect(staticCodes(level(shelves)), isEmpty);
      expect(
        [for (final i in Validator.validate(level(shelves)).issues) i.code],
        [IssueCodes.unsolvable],
      );
    });

    test('schema.valueOutOfRange: generatorVersion below 1', () {
      expect(issuesOf(tut1With(generatorVersion: 0)), [
        isIssue(
          IssueCodes.valueOutOfRange,
          path: '/generatorVersion',
          args: {
            'field': 'generatorVersion',
            'value': 0,
            'min': 1,
            'max': 9007199254740991,
          },
        ),
      ]);
    });
  });

  group('rule 2 (1–4 shelves, 2–5 slots, room for 2 extra slots)', () {
    test('layout.shelfCount: no shelves', () {
      expect(issuesOf(level(const [])), [
        isIssue(
          IssueCodes.shelfCount,
          path: '/shelves',
          args: {'count': 0, 'min': 1, 'max': 4},
        ),
      ]);
    });

    test('layout.shelfCount: 5 shelves', () {
      final shelves = [
        for (var i = 0; i < 5; i++) [OpenSlot(), OpenSlot()],
      ];
      shelves[0] = [
        OpenSlot(nest: nest(red, 3, 2)),
        OpenSlot(nest: nest(red, 1)),
      ];
      expect(issuesOf(level(shelves)), [
        isIssue(
          IssueCodes.shelfCount,
          path: '/shelves',
          args: {'count': 5, 'min': 1, 'max': 4},
        ),
      ]);
    });

    test('layout.slotsPerShelf: 1 and 6 slots', () {
      final issues = issuesOf(
        level([
          [OpenSlot(nest: nest(red, 3, 2))],
          [for (var i = 0; i < 6; i++) OpenSlot()],
          [OpenSlot(nest: nest(red, 1)), OpenSlot()],
        ]),
      );
      expect(issues, [
        isIssue(
          IssueCodes.slotsPerShelf,
          path: '/shelves/0',
          args: {'row': 0, 'count': 1, 'min': 2, 'max': 5},
        ),
        isIssue(
          IssueCodes.slotsPerShelf,
          path: '/shelves/1',
          args: {'row': 1, 'count': 6, 'min': 2, 'max': 5},
        ),
      ]);
    });

    test('layout.noRoomForExtraSlots: 5 slots on the bottom shelf (D22)', () {
      final issues = issuesOf(
        level([
          [OpenSlot(nest: nest(red, 3, 2)), OpenSlot()],
          [
            OpenSlot(nest: nest(red, 1)),
            for (var i = 0; i < 4; i++) OpenSlot(),
          ],
        ]),
      );
      expect(issues, [
        isIssue(
          IssueCodes.noRoomForExtraSlots,
          path: '/shelves/1',
          args: {'count': 5, 'max': 4},
        ),
      ]);
    });

    test('5 slots are fine on any shelf but the bottom one', () {
      final shelves = [
        [
          OpenSlot(nest: nest(red, 3, 2)),
          for (var i = 0; i < 4; i++) OpenSlot(),
        ],
        [OpenSlot(nest: nest(red, 1)), OpenSlot(), OpenSlot(), OpenSlot()],
      ];
      expect(staticCodes(level(shelves)), isEmpty);
    });

    test('a 6-slot bottom shelf breaks both limits', () {
      expect(
        codesOf(
          level([
            [OpenSlot(nest: nest(red, 3, 2)), OpenSlot()],
            [
              OpenSlot(nest: nest(red, 1)),
              for (var i = 0; i < 5; i++) OpenSlot(),
            ],
          ]),
        ),
        [IssueCodes.slotsPerShelf, IssueCodes.noRoomForExtraSlots],
      );
    });
  });

  group('rule 3 (valid nests, none already full)', () {
    test('doll.sizeOutOfRange: each doll above maxSize, with its path', () {
      final issues = issuesOf(
        level([
          [
            OpenSlot(nest: nest(red, 5, 3)), // red5, red4, red3
            TowerSlot([nest(blue, 3), nest(blue, 4, 2)]),
          ],
          [OpenSlot(nest: nest(red, 2, 2)), OpenSlot(nest: nest(blue, 1))],
        ]),
      );
      final sizeIssues = [
        for (final i in issues)
          if (i.code == IssueCodes.dollSizeOutOfRange) i,
      ];
      expect(sizeIssues, [
        isIssue(
          IssueCodes.dollSizeOutOfRange,
          path: '/shelves/0/0/nest/0',
          slotId: 'r0c0',
          args: {'token': 'red5', 'size': 5, 'maxSize': 3},
        ),
        isIssue(
          IssueCodes.dollSizeOutOfRange,
          path: '/shelves/0/0/nest/1',
          slotId: 'r0c0',
          args: {'token': 'red4', 'size': 4, 'maxSize': 3},
        ),
        isIssue(
          IssueCodes.dollSizeOutOfRange,
          path: '/shelves/0/1/stack/1/0',
          slotId: 'r0c1',
          args: {'token': 'blue4', 'size': 4, 'maxSize': 3},
        ),
      ]);
    });

    test('nest.alreadyFull: open, locked and buried in a tower', () {
      final issues = issuesOf(
        level([
          [
            OpenSlot(nest: nest(red, 3, 3)),
            LockedSlot(unlockColor: red, nest: nest(blue, 3, 3)),
            TowerSlot([nest(green, 3, 3), nest(green, 3)]),
          ],
          [OpenSlot(nest: nest(green, 2, 2)), OpenSlot()],
        ]),
      );
      expect(issues, [
        isIssue(
          IssueCodes.alreadyFull,
          path: '/shelves/0/0/nest',
          slotId: 'r0c0',
          args: {'color': 'red'},
        ),
        isIssue(
          IssueCodes.alreadyFull,
          path: '/shelves/0/1/nest',
          slotId: 'r0c1',
          args: {'color': 'blue'},
        ),
        isIssue(
          IssueCodes.alreadyFull,
          path: '/shelves/0/2/stack/0',
          slotId: 'r0c2',
          args: {'color': 'green'},
        ),
      ]);
    });

    test('gold.notSupported: a gold nest (spec §3.5, D22)', () {
      final issues = issuesOf(
        level([
          [...tut1Shelves()[0]],
          [
            OpenSlot(),
            OpenSlot(nest: nest(red, 1)),
            OpenSlot(nest: nest(gold, 2)),
          ],
        ]),
      );
      expect(issues, [
        isIssue(
          IssueCodes.goldNotSupported,
          path: '/shelves/1/2/nest',
          slotId: 'r1c2',
          args: {'token': 'gold2'},
        ),
      ]);
    });

    test('gold.notSupported: a lock that opens on gold', () {
      final issues = issuesOf(
        level([
          [...tut1Shelves()[0]],
          [
            OpenSlot(),
            OpenSlot(nest: nest(red, 1)),
            LockedSlot(unlockColor: gold),
          ],
        ]),
      );
      expect(issues, [
        isIssue(
          IssueCodes.goldNotSupported,
          path: '/shelves/1/2/unlockColor',
          slotId: 'r1c2',
          args: {'token': 'gold'},
        ),
      ]);
    });
  });

  group('rule 4 (whole sets per color, gold exempt)', () {
    test('counts.notFullSets: a size is missing', () {
      expect(
        issuesOf(
          level([
            [OpenSlot(nest: nest(red, 3, 2)), OpenSlot()],
          ]),
        ),
        [
          isIssue(
            IssueCodes.notFullSets,
            args: {'color': 'red', 'size': 1, 'count': 0, 'expected': 1},
          ),
        ],
      );
    });

    test('counts.notFullSets: one doll too many', () {
      // Two red1 need two sets, so red2 and red3 are short: the first size
      // that is off is reported.
      expect(
        issuesOf(
          level([
            [OpenSlot(nest: nest(red, 3, 2)), OpenSlot(nest: nest(red, 1))],
            [OpenSlot(nest: nest(red, 1)), OpenSlot()],
          ]),
        ),
        [
          isIssue(
            IssueCodes.notFullSets,
            args: {'color': 'red', 'size': 2, 'count': 1, 'expected': 2},
          ),
        ],
      );
    });

    test('one issue per color, in DollColor order', () {
      final issues = issuesOf(
        level([
          [OpenSlot(nest: nest(blue, 2)), OpenSlot(nest: nest(red, 3))],
        ]),
      );
      expect(issues.map((i) => i.args['color']), ['red', 'blue']);
    });

    test('k = 2 full sets of one color is valid', () {
      final twoSets = level([
        [
          OpenSlot(nest: nest(red, 3)),
          OpenSlot(nest: nest(red, 2, 2)),
          OpenSlot(),
        ],
        [
          OpenSlot(nest: nest(red, 3)),
          OpenSlot(nest: nest(red, 2)),
          OpenSlot(nest: nest(red, 1)),
        ],
      ]);
      expect(staticCodes(twoSets), isEmpty);
    });

    test('gold is exempt from the count', () {
      expect(
        codesOf(
          level([
            [...tut1Shelves()[0]],
            [OpenSlot(nest: nest(gold, 3)), OpenSlot(nest: nest(red, 1))],
          ]),
        ),
        [IssueCodes.goldNotSupported],
      );
    });
  });

  group('rule 5 (towers at most 4 deep)', () {
    test('tower.tooDeep', () {
      final tower = TowerSlot([
        nest(blue, 1),
        nest(red, 2),
        nest(blue, 2),
        nest(red, 1),
        nest(blue, 3),
      ]);
      expect(
        issuesOf(
          level([
            [tower, OpenSlot(nest: nest(red, 3))],
          ]),
        ),
        [
          isIssue(
            IssueCodes.towerTooDeep,
            path: '/shelves/0/0/stack',
            slotId: 'r0c0',
            args: {'depth': 5, 'max': 4},
          ),
        ],
      );
    });

    test('a tower 4 deep is fine', () {
      final tower = TowerSlot([
        nest(blue, 1),
        nest(red, 2),
        nest(blue, 2),
        nest(red, 1),
      ]);
      expect(
        staticCodes(
          level([
            [
              tower,
              OpenSlot(nest: nest(red, 3)),
              OpenSlot(nest: nest(blue, 3)),
            ],
          ]),
        ),
        isEmpty,
      );
    });
  });

  group('rule 6 (lock colors present, not all sealed in the lock)', () {
    test('locked.colorAbsent', () {
      expect(
        issuesOf(
          level([
            [...tut1Shelves()[0]],
            [
              OpenSlot(),
              OpenSlot(nest: nest(red, 1)),
              LockedSlot(unlockColor: blue),
            ],
          ]),
        ),
        [
          isIssue(
            IssueCodes.lockColorAbsent,
            path: '/shelves/1/2/unlockColor',
            slotId: 'r1c2',
            args: {'color': 'blue'},
          ),
        ],
      );
    });

    test('locked.colorAllSealed', () {
      // With whole sets (rule 4), a lock can only hold every doll of a color
      // as one full nest, so rule 3 fires too; rule 6 still says why the
      // lock could never open.
      expect(
        issuesOf(
          level([
            [
              LockedSlot(unlockColor: red, nest: nest(red, 3, 3)),
              OpenSlot(nest: nest(blue, 3)),
            ],
            [OpenSlot(nest: nest(blue, 2, 2)), OpenSlot()],
          ]),
        ),
        [
          isIssue(
            IssueCodes.alreadyFull,
            path: '/shelves/0/0/nest',
            slotId: 'r0c0',
            args: {'color': 'red'},
          ),
          isIssue(
            IssueCodes.lockColorAllSealed,
            path: '/shelves/0/0/unlockColor',
            slotId: 'r0c0',
            args: {'color': 'red'},
          ),
        ],
      );
    });

    test('locked.colorAllSealed without full sets', () {
      expect(
        codesOf(
          level([
            [
              LockedSlot(unlockColor: red, nest: nest(red, 2, 2)),
              OpenSlot(nest: nest(blue, 3, 2)),
            ],
            [OpenSlot(nest: nest(blue, 1)), OpenSlot()],
          ]),
        ),
        [IssueCodes.notFullSets, IssueCodes.lockColorAllSealed],
      );
    });

    test('each lock is judged on its own (a mutual deadlock passes 6)', () {
      // Spec §5.3 rule 6 reads per lock; the deadlock is rule 8's to find
      // (test/fixtures/unsolvable/001_lock_deadlock.json).
      final deadlock = level([
        [
          LockedSlot(unlockColor: red, nest: nest(blue, 3, 2)),
          LockedSlot(unlockColor: blue, nest: nest(red, 3, 2)),
          OpenSlot(nest: nest(red, 1)),
        ],
        [OpenSlot(nest: nest(blue, 1)), OpenSlot()],
      ]);
      expect(staticCodes(deadlock), isEmpty);
    });
  });

  group('rules 7 and 8', () {
    test('moves.noLegalFirstMove', () {
      expect(issuesOf(noFirstMoveLevel()), [
        isIssue(IssueCodes.noLegalFirstMove),
      ]);
    });

    test('a level with no dolls has no legal first move', () {
      expect(
        codesOf(
          level([
            [OpenSlot(), OpenSlot()],
          ]),
        ),
        [IssueCodes.noLegalFirstMove],
      );
    });

    test('rules 7 and 8 do not run after an earlier error', () {
      // Needs no rules engine: the validator stops before rule 7.
      final solver = FakeSolver(
        SolveResult(verdict: SolveVerdict.solved, nodes: 1, branching: 1),
      );
      final broken = level(noFirstMoveLevel().shelves, id: '');
      final report = Validator.validate(
        broken,
        options: ValidationOptions(solver: solver.solve),
      );
      expect(report.issues.map((i) => i.code), [IssueCodes.badId]);
      expect(report.solve, isNull);
      expect(solver.calls, isEmpty);
    });

    group('rule 8 (the solver proves the level solvable)', () {
      final solved = SolveResult(
        verdict: SolveVerdict.solved,
        nodes: 17,
        branching: 2,
        solution: const [Move('r1c1', 'r0c2'), Move('r0c2', 'r0c0')],
      );

      test('solved: valid, and the report carries the search', () {
        final solver = FakeSolver(solved);
        final report = Validator.validate(
          tut1With(),
          options: ValidationOptions(solver: solver.solve, solverBudget: 1234),
        );
        expect(report.issues, isEmpty);
        expect(report.isValid, isTrue);
        expect(report.solve, solved);
        expect(solver.calls, hasLength(1));
        final (state, budget) = solver.calls.single;
        expect(state, GameState.initial(tut1With()));
        expect(budget, 1234);
      });

      test('solver.unsolvable', () {
        final result = SolveResult(
          verdict: SolveVerdict.unsolvable,
          nodes: 6,
          branching: 1.5,
        );
        final report = Validator.validate(
          tut1With(),
          options: ValidationOptions(solver: FakeSolver(result).solve),
        );
        expect(report.issues, [
          isIssue(IssueCodes.unsolvable, args: {'nodes': 6}),
        ]);
        expect(report.solve, result);
      });

      test('solver.unproven when the budget runs out (spec §6.3)', () {
        final result = SolveResult(
          verdict: SolveVerdict.unknown,
          nodes: 50,
          branching: 3,
        );
        final report = Validator.validate(
          tut1With(),
          options: ValidationOptions(
            solver: FakeSolver(result).solve,
            solverBudget: 50,
          ),
        );
        expect(report.issues, [
          isIssue(IssueCodes.unproven, args: {'nodes': 50, 'budget': 50}),
        ]);
        expect(report.isValid, isFalse);
      });

      test('solver.unproven when no solver is given', () {
        final report = Validator.validate(
          tut1With(),
          options: const ValidationOptions(solver: null),
        );
        expect(report.issues, [
          isIssue(
            IssueCodes.unproven,
            args: {'nodes': 0, 'budget': SolverBudgets.admin},
          ),
        ]);
        expect(report.isValid, isFalse);
        expect(report.solve, isNull);
      });

      test('the loader skips rule 8 (A6)', () {
        final solver = FakeSolver(solved);
        final report = Validator.validate(
          tut1With(),
          options: ValidationOptions(
            checkSolvable: false,
            solver: solver.solve,
          ),
        );
        expect(report.issues, isEmpty);
        expect(report.solve, isNull);
        expect(solver.calls, isEmpty);
      });

      test('rule 8 does not run when rule 7 fails', () {
        final solver = FakeSolver(solved);
        final report = Validator.validate(
          noFirstMoveLevel(),
          options: ValidationOptions(solver: solver.solve),
        );
        expect(report.issues.map((i) => i.code), [IssueCodes.noLegalFirstMove]);
        expect(solver.calls, isEmpty);
      });
    });
  });

  group('validateJson', () {
    test('a JSON that does not decode gives only the codec issues', () {
      final report = Validator.validateJson({
        'schemaVersion': 1,
        'id': '',
        'maxSize': 3,
        'shelves': [
          [
            {'type': 'tower', 'stack': <Object>[]},
          ],
        ],
      });
      expect(report.level, isNull);
      expect(report.issues.map((i) => i.code), [IssueCodes.towerEmptyAtStart]);
      expect(report.isValid, isFalse);
    });

    test('rule issues on a decoded level point into the input JSON', () {
      final json = LevelCodec.encode(
        level([
          [OpenSlot(nest: nest(red, 4, 2)), OpenSlot(nest: nest(red, 2, 2))],
        ], id: ''),
      );
      final report = Validator.validateJson(
        json,
        options: ValidationOptions.loader,
      );
      expect(report.level, isNotNull);
      expect(report.issues.map((i) => '${i.code} ${i.path}'), [
        'level.badId /id',
        'doll.sizeOutOfRange /shelves/0/0/nest/0',
      ]);
      for (final issue in report.issues) {
        expect(
          resolvePointer(json, issue.path),
          isNotNull,
          reason: '${issue.path} must exist in the JSON',
        );
      }
    });

    test('every rule path resolves in the level JSON', () {
      // Build one level that trips every path-carrying rule check.
      final messy = level(
        [
          [
            OpenSlot(nest: nest(red, 5, 3)),
            TowerSlot([for (var i = 0; i < 5; i++) nest(blue, 1)]),
            LockedSlot(unlockColor: green),
            LockedSlot(unlockColor: gold, nest: nest(gold, 1)),
            OpenSlot(nest: nest(red, 3, 3)),
            OpenSlot(),
          ],
          [OpenSlot()],
        ],
        id: '',
        seed: -1,
        generatorVersion: 0,
      );
      final json = LevelCodec.encode(messy);
      final issues = issuesOf(messy);
      expect(
        issues.map((i) => i.code).toSet(),
        containsAll([
          IssueCodes.badId,
          IssueCodes.valueOutOfRange,
          IssueCodes.slotsPerShelf,
          IssueCodes.dollSizeOutOfRange,
          IssueCodes.alreadyFull,
          IssueCodes.goldNotSupported,
          IssueCodes.notFullSets,
          IssueCodes.towerTooDeep,
          IssueCodes.lockColorAbsent,
        ]),
      );
      for (final issue in issues) {
        expect(
          resolvePointer(json, issue.path),
          isNotNull,
          reason: '${issue.code} ${issue.path}',
        );
        if (issue.slotId case final slotId?) {
          final position = messy.positionOf(slotId);
          expect(
            issue.path,
            startsWith('/shelves/${position.row}/${position.col}'),
          );
        }
      }
    });
  });

  group('every level issue code comes from Validator.validateJson', () {
    // One producer per code. Together with the detailed tests above and in
    // test/codec/level_codec_test.dart, this proves every code the codec and
    // the validator own can actually be emitted.
    final open = {'type': 'open', 'nest': null};
    Map<String, Object?> doc({
      Object? shelves,
      int maxSize = 3,
      Object? id = 'P',
      Map<String, Object?> extra = const {},
    }) => {
      'schemaVersion': 1,
      'id': id,
      'maxSize': maxSize,
      'shelves':
          shelves ??
          [
            [
              {
                'type': 'open',
                'nest': ['red3'],
              },
              open,
              {
                'type': 'open',
                'nest': ['red2', 'red1'],
              },
            ],
          ],
      ...extra,
    };
    Map<String, Object?> withSlot(Map<String, Object?> slot) => doc(
      shelves: [
        [
          {
            'type': 'open',
            'nest': ['red3'],
          },
          slot,
          {
            'type': 'open',
            'nest': ['red2', 'red1'],
          },
        ],
      ],
    );

    final producers = <String, (Object? Function(), ValidationOptions)>{
      IssueCodes.invalidJson: (() => null, ValidationOptions.loader),
      IssueCodes.unsupportedVersion: (
        () => doc(extra: {'schemaVersion': 3}),
        ValidationOptions.loader,
      ),
      IssueCodes.missingField: (
        () => doc()..remove('maxSize'),
        ValidationOptions.loader,
      ),
      IssueCodes.unknownField: (
        () => doc(extra: {'tier': 'easy'}),
        ValidationOptions.loader,
      ),
      IssueCodes.wrongType: (() => doc(id: 5), ValidationOptions.loader),
      IssueCodes.valueOutOfRange: (
        () => doc(extra: {'seed': -1}),
        ValidationOptions.loader,
      ),
      IssueCodes.badId: (() => doc(id: ''), ValidationOptions.loader),
      IssueCodes.unknownSlotType: (
        () => withSlot({'type': 'shelf'}),
        ValidationOptions.loader,
      ),
      IssueCodes.badDollToken: (
        () => withSlot({
          'type': 'open',
          'nest': ['red9'],
        }),
        ValidationOptions.loader,
      ),
      IssueCodes.unknownDollColor: (
        () => withSlot({
          'type': 'open',
          'nest': ['plum1'],
        }),
        ValidationOptions.loader,
      ),
      IssueCodes.dollSizeOutOfRange: (
        () => withSlot({
          'type': 'open',
          'nest': ['red4'],
        }),
        ValidationOptions.loader,
      ),
      IssueCodes.negativeIce: (
        () => withSlot({'type': 'open', 'nest': null, 'ice': -1}),
        ValidationOptions.loader,
      ),
      IssueCodes.goldNotSupported: (
        () => withSlot({
          'type': 'open',
          'nest': ['gold1'],
        }),
        ValidationOptions.loader,
      ),
      IssueCodes.maxSizeOutOfRange: (
        () => doc(maxSize: 8),
        ValidationOptions.loader,
      ),
      IssueCodes.shelfCount: (
        () => doc(shelves: <Object>[]),
        ValidationOptions.loader,
      ),
      IssueCodes.slotsPerShelf: (
        () => doc(
          shelves: [
            [
              {
                'type': 'open',
                'nest': ['red3', 'red2', 'red1'],
              },
            ],
          ],
        ),
        ValidationOptions.loader,
      ),
      IssueCodes.noRoomForExtraSlots: (
        () => doc(
          shelves: [
            [
              {
                'type': 'open',
                'nest': ['red3'],
              },
              {
                'type': 'open',
                'nest': ['red2', 'red1'],
              },
              open,
              open,
              open,
            ],
          ],
        ),
        ValidationOptions.loader,
      ),
      IssueCodes.emptyNest: (
        () => withSlot({'type': 'open', 'nest': <Object>[]}),
        ValidationOptions.loader,
      ),
      IssueCodes.mixedColors: (
        () => withSlot({
          'type': 'open',
          'nest': ['blue2', 'red1'],
        }),
        ValidationOptions.loader,
      ),
      IssueCodes.notConsecutive: (
        () => withSlot({
          'type': 'open',
          'nest': ['red3', 'red1'],
        }),
        ValidationOptions.loader,
      ),
      IssueCodes.alreadyFull: (
        () => doc(
          shelves: [
            [
              {
                'type': 'open',
                'nest': ['red3', 'red2', 'red1'],
              },
              open,
            ],
          ],
        ),
        ValidationOptions.loader,
      ),
      IssueCodes.notFullSets: (
        () => withSlot({
          'type': 'open',
          'nest': ['blue1'],
        }),
        ValidationOptions.loader,
      ),
      IssueCodes.towerTooDeep: (
        () => withSlot({
          'type': 'tower',
          'stack': [
            ['red3'],
            ['red2'],
            ['red1'],
            ['red3'],
            ['red2', 'red1'],
          ],
        }),
        ValidationOptions.loader,
      ),
      IssueCodes.towerEmptyAtStart: (
        () => withSlot({'type': 'tower', 'stack': <Object>[]}),
        ValidationOptions.loader,
      ),
      IssueCodes.lockColorAbsent: (
        () => withSlot({'type': 'locked', 'unlockColor': 'teal', 'nest': null}),
        ValidationOptions.loader,
      ),
      IssueCodes.lockColorAllSealed: (
        () => doc(
          shelves: [
            [
              {
                'type': 'locked',
                'unlockColor': 'red',
                'nest': ['red2', 'red1'],
              },
              open,
            ],
          ],
        ),
        ValidationOptions.loader,
      ),
      IssueCodes.noLegalFirstMove: (
        () => LevelCodec.encode(noFirstMoveLevel()),
        ValidationOptions.loader,
      ),
      IssueCodes.unsolvable: (
        () => doc(),
        ValidationOptions(
          solver: FakeSolver(
            SolveResult(
              verdict: SolveVerdict.unsolvable,
              nodes: 3,
              branching: 1,
            ),
          ).solve,
        ),
      ),
      IssueCodes.unproven: (() => doc(), const ValidationOptions(solver: null)),
    };

    test('covers every code except the bundle and generator ones', () {
      final levelCodes = IssueCodes.all.where(
        (code) => !code.startsWith('bundle.') && !code.startsWith('gen.'),
      );
      expect(producers.keys.toSet(), levelCodes.toSet());
    });

    for (final MapEntry(key: code, value: (json, options))
        in producers.entries) {
      test(code, () {
        final report = code == IssueCodes.invalidJson
            ? ValidationReport(issues: LevelCodec.decodeString('{').issues)
            : Validator.validateJson(json(), options: options);
        expect(report.issues.map((i) => i.code), contains(code));
        expect(report.isValid, isFalse);
      });
    }
  });

  group('ValidationOptions', () {
    test('compares by value, including the solver', () {
      SolveResult solve(GameState state, {int budget = 0}) =>
          SolveResult(verdict: SolveVerdict.solved, nodes: 0, branching: 0);
      expect(
        ValidationOptions(solver: solve),
        ValidationOptions(solver: solve),
      );
      expect(ValidationOptions(solver: solve), isNot(ValidationOptions.admin));
      expect(ValidationOptions.admin.solver, Solver.solve);
      expect(const ValidationOptions(solver: null).solver, isNull);
      expect(
        const ValidationOptions(checkSolvable: false),
        ValidationOptions.loader,
      );
    });

    test('toString says whether a solver is set', () {
      expect(
        const ValidationOptions(solver: null).toString(),
        contains('no solver'),
      );
      expect(ValidationOptions.admin.toString(), isNot(contains('no solver')));
    });
  });
}

/// The JSON value at RFC 6901 [pointer] in [json], or null when there is
/// none.
Object? resolvePointer(Object? json, String pointer) {
  if (pointer.isEmpty) return json;
  Object? node = json;
  for (final raw in pointer.substring(1).split('/')) {
    final segment = raw.replaceAll('~1', '/').replaceAll('~0', '~');
    if (node is Map) {
      if (!node.containsKey(segment)) return null;
      node = node[segment];
    } else if (node is List) {
      final index = int.tryParse(segment);
      if (index == null || index < 0 || index >= node.length) return null;
      node = node[index];
    } else {
      return null;
    }
    // `"nest": null` is a real value, so report presence, not the value.
    node ??= const _Present();
  }
  return node;
}

final class _Present {
  const _Present();
}
