import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_tools/src/levels/finding.dart';
import 'package:nesty_tools/src/levels/level_paths.dart';
import 'package:test/test.dart';

import 'support/scratch_repo.dart';

void main() {
  late ScratchRepo repo;
  setUp(() => repo = ScratchRepo.create());
  tearDown(() => repo.delete());

  LevelBundle committed() =>
      LevelBundleCodec.decodeString(repo.read(LevelPaths.bundle)).bundle!;

  group('bundle build', () {
    test('writes the canonical bundle of the manifest (design §4)', () {
      repo.writeTutorials();
      final run = repo.run(['bundle', 'build']);
      expect(run.exitCode, 0, reason: '$run');
      expect(run.out, contains('created'));
      expect(run.out, contains('2 levels'));

      final text = repo.read(LevelPaths.bundle);
      final bundle = LevelBundleCodec.decodeString(text).bundle!;
      expect(LevelBundleCodec.encodeString(bundle), text);
      expect(bundle.levelsVersion, 0);
      expect([for (final e in bundle.levels) e.level.id], ['L0001', 'L0002']);
      final first = bundle.levels.first;
      expect(first.order, 1);
      expect(first.chapterId, 'ch01');
      expect(first.tier, Tier.easy);
      expect(first.version, 1);
      expect(first.rewardCoins, Tier.easy.defaultRewardCoins);
      expect(first.level, LevelCodec.decodeString(tutorial1('L0001')).level);
    });

    test('is deterministic: a second build changes nothing', () {
      repo.writeTutorials();
      repo.run(['bundle', 'build']);
      final before = repo.read(LevelPaths.bundle);
      final run = repo.run(['bundle', 'build']);
      expect(run.exitCode, 0);
      expect(run.out, contains('unchanged'));
      expect(repo.read(LevelPaths.bundle), before);
    });

    test('rewards follow the declared tier (spec §7.3, design A27)', () {
      repo
        ..writeTutorials()
        ..writeLevel('L0003', tutorial1('L0003'))
        ..writeManifest([
          manifestEntry(1, 'L0001'),
          manifestEntry(2, 'L0002', tier: 'hard'),
          manifestEntry(3, 'L0003', tier: 'superhard'),
        ], levelsVersion: 5);
      expect(repo.run(['bundle', 'build']).exitCode, 0);
      final bundle = committed();
      expect(bundle.levelsVersion, 5);
      expect([for (final e in bundle.levels) e.rewardCoins], [10, 25, 50]);
    });

    test('refuses a changed board at the same version (spec §13.3)', () {
      repo.writeTutorials();
      repo.run(['bundle', 'build']);
      final before = repo.read(LevelPaths.bundle);
      repo.writeLevel('L0002', tutorial1('L0002'));

      final run = repo.run(['bundle', 'build']);
      expect(run.exitCode, 1);
      expect(run.err, contains(FindingCodes.versionNotBumped));
      expect(run.err, contains('L0002'));
      expect(run.err, contains('Nothing written'));
      expect(repo.read(LevelPaths.bundle), before);

      repo.writeManifest([
        manifestEntry(1, 'L0001'),
        manifestEntry(2, 'L0002', version: 2),
      ]);
      expect(repo.run(['bundle', 'build']).exitCode, 0);
      expect(committed().levels.last.version, 2);
    });

    test('a version may not go down', () {
      repo
        ..writeTutorials()
        ..writeManifest([
          manifestEntry(1, 'L0001', version: 3),
          manifestEntry(2, 'L0002'),
        ]);
      repo.run(['bundle', 'build']);
      repo.writeManifest([
        manifestEntry(1, 'L0001'),
        manifestEntry(2, 'L0002'),
      ]);
      final run = repo.run(['bundle', 'build']);
      expect(run.exitCode, 1);
      expect(run.err, contains('went down'));
    });

    test('metadata changes need no version bump', () {
      repo.writeTutorials();
      repo.run(['bundle', 'build']);
      repo.writeManifest([
        manifestEntry(1, 'L0001'),
        manifestEntry(2, 'L0002', tier: 'medium'),
      ]);
      expect(repo.run(['bundle', 'build']).exitCode, 0);
      expect(committed().levels.last.tier, Tier.medium);
    });

    test('fails loudly on a missing, stray, mismatched or broken level '
        'file', () {
      repo
        ..writeManifest([
          manifestEntry(1, 'L0001'),
          manifestEntry(2, 'L0002'),
          manifestEntry(3, 'L0003'),
        ])
        ..writeLevel('L0002', tutorial2('Other'))
        ..writeLevel('L0003', '{"schemaVersion": 1, "id": "L0003"}')
        ..writeLevel('L0099', tutorial1('L0099'));
      final run = repo.run(['bundle', 'build']);
      expect(run.exitCode, 1);
      expect(run.err, contains(FindingCodes.missingLevelFile));
      expect(run.err, contains('tools/levels/authored/L0001.json'));
      expect(run.err, contains(FindingCodes.idMismatch));
      expect(run.err, contains(IssueCodes.missingField));
      expect(run.err, contains(FindingCodes.strayLevelFile));
      expect(run.err, contains('L0099.json'));
      expect(repo.file(LevelPaths.bundle).existsSync(), isFalse);
    });

    test('a manifest problem stops the build', () {
      repo.writeTutorials();
      repo.write('tools/levels/manifest.json', '{"format": ');
      final run = repo.run(['bundle', 'build']);
      expect(run.exitCode, 1);
      expect(run.err, contains(FindingCodes.invalidJson));
      expect(repo.file(LevelPaths.bundle).existsSync(), isFalse);
    });

    // Spec-prop §7.10: "**Par** is the fewest moves that solve the level
    // from its start, the solver's optimal solution (§6.3). It is computed
    // when the level bundle is built, and checked with it." The tutorials'
    // optima are hand-worked (design §4; nesty_core's
    // test/solver/fixture_expectations.dart): L1 2 moves, L2 3.
    test('writes each level\'s par, the solver\'s optimal length, after '
        'rewardCoins', () {
      repo.writeTutorials();
      final run = repo.run(['bundle', 'build']);
      expect(run.exitCode, 0, reason: '$run');
      expect(run.out, contains('par 2–3'));
      expect([for (final e in committed().levels) e.par], [2, 3]);
      final text = repo.read(LevelPaths.bundle);
      expect(text, contains('"rewardCoins": 10,\n      "par": 2,\n'));
      expect(text, contains('"rewardCoins": 10,\n      "par": 3,\n'));
    });

    test('an unsolvable level has no par: build.parUnproven, nothing '
        'written', () {
      repo.writeTutorials();
      repo.run(['bundle', 'build']);
      final before = repo.read(LevelPaths.bundle);
      // The lock deadlock fixture: rules 1–7 hold, rule 8 fails.
      repo.writeLevel(
        'L0002',
        '{"schemaVersion":1,"id":"L0002","maxSize":3,"shelves":['
            '[{"type":"locked","unlockColor":"blue","nest":["red3","red2"]},'
            '{"type":"locked","unlockColor":"red","nest":["blue3","blue2"]}],'
            '[{"type":"open","nest":["red1"]},{"type":"open","nest":["blue1"]},'
            '{"type":"open","nest":null}]]}',
      );
      final run = repo.run(['bundle', 'build']);
      expect(run.exitCode, 1);
      expect(run.err, contains('L0002: ${FindingCodes.parUnproven}'));
      expect(run.err, contains('proved it unsolvable'));
      expect(run.err, contains('L0002: ${IssueCodes.unsolvable}'));
      expect(run.err, isNot(contains('L0001: ')));
      expect(run.err, contains('Nothing written'));
      expect(repo.read(LevelPaths.bundle), before);
    });

    test('a level failing rules 1–7 has no par either', () {
      repo
        ..writeTutorials()
        ..writeLevel(
          'L0002',
          tutorial1('L0002').replaceFirst('"nest":["red1"]', '"nest":null'),
        );
      final run = repo.run(['bundle', 'build']);
      expect(run.exitCode, 1);
      expect(run.err, contains('L0002: ${FindingCodes.parUnproven}'));
      expect(run.err, contains('rules 1–7 fail'));
      expect(run.err, contains('L0002: ${IssueCodes.notFullSets}'));
      expect(repo.file(LevelPaths.bundle).existsSync(), isFalse);
    });

    test('takes no arguments', () {
      repo.writeTutorials();
      expect(repo.run(['bundle', 'build', '--force']).exitCode, 64);
      expect(repo.run(['bundle', 'ship']).exitCode, 64);
    });
  });

  group('bundle check', () {
    test('passes on a fresh bundle of valid levels and prints the table', () {
      repo.writeTutorials();
      repo.run(['bundle', 'build']);
      final run = repo.run(['bundle', 'check']);
      expect(run.exitCode, 0, reason: '$run');
      expect(run.out, contains('order'));
      expect(run.out, contains('simulated'));
      expect(run.out, contains('L0001'));
      expect(run.out, contains('bundle check (2 levels): OK'));
    });

    test('fails when the bundle is missing or stale', () {
      repo.writeTutorials();
      final missing = repo.run(['bundle', 'check']);
      expect(missing.exitCode, 1);
      expect(missing.err, contains(FindingCodes.bundleMissing));

      repo.run(['bundle', 'build']);
      repo.writeManifest([
        manifestEntry(1, 'L0001'),
        manifestEntry(2, 'L0002'),
      ], levelsVersion: 1);
      final stale = repo.run(['bundle', 'check']);
      expect(stale.exitCode, 1);
      expect(stale.err, contains(FindingCodes.bundleDrift));
    });

    test('a hand edit of the bundle is drift', () {
      repo.writeTutorials();
      repo.run(['bundle', 'build']);
      repo.write(
        LevelPaths.bundle,
        repo
            .read(LevelPaths.bundle)
            .replaceFirst('"rewardCoins": 10', '"rewardCoins": 11'),
      );
      final run = repo.run(['bundle', 'check']);
      expect(run.exitCode, 1);
      expect(run.err, contains(FindingCodes.bundleDrift));
    });

    test('an edited par is a bundle.parMismatch naming both values', () {
      repo.writeTutorials();
      repo.run(['bundle', 'build']);
      repo.write(
        LevelPaths.bundle,
        repo.read(LevelPaths.bundle).replaceFirst('"par": 2,', '"par": 5,'),
      );
      final run = repo.run(['bundle', 'check']);
      expect(run.exitCode, 1);
      expect(
        run.err,
        contains(
          'L0001: ${FindingCodes.parMismatch}: committed 5, the solver\'s 2',
        ),
      );
      expect(run.err, contains(FindingCodes.bundleDrift));
      expect(run.err, isNot(contains('L0002: ${FindingCodes.parMismatch}')));
    });

    test('a missing or unreadable par is a bundle.parMismatch too', () {
      repo.writeTutorials();
      repo.run(['bundle', 'build']);
      final built = repo.read(LevelPaths.bundle);
      repo.write(
        LevelPaths.bundle,
        built.replaceFirst('      "par": 3,\n', ''),
      );
      final missing = repo.run(['bundle', 'check']);
      expect(missing.exitCode, 1);
      expect(
        missing.err,
        contains(
          'L0002: ${FindingCodes.parMismatch}: no par committed, the '
          'solver\'s 3',
        ),
      );

      // The codec reads a bad par as a warning and no par (D146).
      repo.write(
        LevelPaths.bundle,
        built.replaceFirst('"par": 3,', '"par": 0,'),
      );
      final zero = repo.run(['bundle', 'check']);
      expect(zero.exitCode, 1);
      expect(
        zero.err,
        contains('L0002: ${FindingCodes.parMismatch}: no par committed'),
      );
    });

    test('a bundle from before stars fails for every level', () {
      repo.writeTutorials();
      repo.run(['bundle', 'build']);
      repo.write(
        LevelPaths.bundle,
        repo
            .read(LevelPaths.bundle)
            .replaceAll(RegExp(r'      "par": \d+,\n'), ''),
      );
      final run = repo.run(['bundle', 'check']);
      expect(run.exitCode, 1);
      expect(run.err, contains('L0001: ${FindingCodes.parMismatch}'));
      expect(run.err, contains('L0002: ${FindingCodes.parMismatch}'));
      // `bundle build` repairs it, and only the par lines change.
      expect(repo.run(['bundle', 'build']).exitCode, 0);
      expect(repo.run(['bundle', 'check']).exitCode, 0);
    });

    test('a stale bundle with a same-version board change says so', () {
      repo.writeTutorials();
      repo.run(['bundle', 'build']);
      repo.writeLevel('L0002', tutorial1('L0002'));
      final run = repo.run(['bundle', 'check']);
      expect(run.exitCode, 1);
      expect(run.err, contains(FindingCodes.bundleDrift));
      expect(run.err, contains(FindingCodes.versionNotBumped));
    });

    test('the simulated tier must match the declared one (design A32)', () {
      // The L1 tutorial board simulates easy; L3 must be medium (§6.6).
      repo
        ..writeTutorials()
        ..writeLevel('L0003', tutorial1('L0003'))
        ..writeManifest([
          manifestEntry(1, 'L0001'),
          manifestEntry(2, 'L0002'),
          manifestEntry(3, 'L0003', tier: 'medium'),
        ]);
      repo.run(['bundle', 'build']);
      final run = repo.run(['bundle', 'check']);
      expect(run.exitCode, 1);
      expect(run.err, contains('L0003: ${FindingCodes.tierMismatch}'));
      expect(run.err, isNot(contains(FindingCodes.pattern)));
    });

    test('the declared tier must follow the §6.6 pattern', () {
      repo
        ..writeTutorials()
        ..writeLevel('L0003', tutorial1('L0003'))
        ..writeManifest([
          manifestEntry(1, 'L0001'),
          manifestEntry(2, 'L0002'),
          manifestEntry(3, 'L0003'),
        ]);
      repo.run(['bundle', 'build']);
      final run = repo.run(['bundle', 'check']);
      expect(run.exitCode, 1);
      expect(run.err, contains('L0003: ${FindingCodes.pattern}'));
      expect(run.err, isNot(contains(FindingCodes.tierMismatch)));
    });

    test('tier overrides: tutorials and open-slot boards only (D26); an '
        'unneeded one warns', () {
      repo
        ..writeTutorials()
        ..writeManifest([
          manifestEntry(1, 'L0001', tierOverride: 'Guided tutorial'),
          manifestEntry(2, 'L0002'),
        ]);
      repo.run(['bundle', 'build']);
      final warned = repo.run(['bundle', 'check']);
      expect(warned.exitCode, 0, reason: '$warned');
      expect(
        warned.err,
        contains('warning L0001: ${FindingCodes.tierOverrideUnneeded}'),
      );

      // An open-slot-only board always simulates easy, so L3 keeps its §6.6
      // medium with a reason (D26). It is the one-color board, so it doesn't
      // repeat L2's layout (E12).
      repo
        ..writeLevel('L0003', tutorial1('L0003'))
        ..writeManifest([
          manifestEntry(1, 'L0001'),
          manifestEntry(2, 'L0002'),
          manifestEntry(
            3,
            'L0003',
            tier: 'medium',
            tierOverride: 'Towerless: medium by its layout',
          ),
        ]);
      repo.run(['bundle', 'build']);
      final accepted = repo.run(['bundle', 'check']);
      expect(accepted.exitCode, 0, reason: '$accepted');
      expect(accepted.err, isNot(contains(FindingCodes.tierMismatch)));

      // A board with a tower is measured by the simulator: no override.
      repo
        ..writeLevel(
          'L0003',
          '{"schemaVersion":1,"id":"L0003","maxSize":3,"shelves":['
              '[{"type":"tower","stack":[["blue3"],["red3"]]},'
              '{"type":"open","nest":null},{"type":"open","nest":["blue2"]}],'
              '[{"type":"open","nest":["red2","red1"]},'
              '{"type":"open","nest":null},{"type":"open","nest":["blue1"]}]'
              ']}',
        )
        ..writeManifest([
          manifestEntry(1, 'L0001'),
          manifestEntry(2, 'L0002'),
          manifestEntry(3, 'L0003', tier: 'medium', tierOverride: 'Please'),
        ]);
      repo.run(['bundle', 'build']);
      final refused = repo.run(['bundle', 'check']);
      expect(refused.exitCode, 1);
      expect(refused.err, contains(FindingCodes.tierOverrideNotTutorial));
      expect(refused.err, contains(FindingCodes.tierMismatch));
    });

    test('rules 1–8, the schedule and the layout are all checked', () {
      // L2 as a one-color level breaks the §3.7 schedule; L0003 breaks rule 4
      // (red has no size 1) and has 4 shelves.
      repo
        ..writeTutorials()
        ..writeLevel('L0002', tutorial1('L0002'))
        ..writeLevel(
          'L0003',
          '{"schemaVersion":1,"id":"L0003","maxSize":3,"shelves":['
              '[{"type":"open","nest":["red3"]},{"type":"open","nest":null}],'
              '[{"type":"open","nest":["red2"]},{"type":"open","nest":null}],'
              '[{"type":"open","nest":null},{"type":"open","nest":null}],'
              '[{"type":"open","nest":null},{"type":"open","nest":null}]]}',
        )
        ..writeManifest([
          manifestEntry(1, 'L0001'),
          manifestEntry(2, 'L0002'),
          manifestEntry(3, 'L0003', tier: 'medium'),
        ]);
      repo.run(['bundle', 'build']);
      final run = repo.run(['bundle', 'check']);
      expect(run.exitCode, 1);
      expect(run.err, contains('L0002: ${FindingCodes.scheduleColors}'));
      expect(run.err, contains('L0003: ${IssueCodes.notFullSets}'));
      expect(run.err, contains('L0003: ${FindingCodes.layoutShelves}'));
      expect(run.out, contains(IssueCodes.notFullSets));
    });

    test('two neighbours with one layout fail (E12)', () {
      // L3 and L4 repeat L2's layout exactly (3,3 shelves, no towers, 2
      // colors, maxSize 3); L3 keeps its medium tier by the open-slot
      // override (D26). L1 and L2 always differ (1 color and 2, spec §3.7).
      repo
        ..writeTutorials()
        ..writeLevel('L0003', tutorial2('L0003'))
        ..writeLevel('L0004', tutorial2('L0004'))
        ..writeManifest([
          manifestEntry(1, 'L0001'),
          manifestEntry(2, 'L0002'),
          manifestEntry(
            3,
            'L0003',
            tier: 'medium',
            tierOverride: 'Towerless: medium by its layout',
          ),
          manifestEntry(4, 'L0004'),
        ]);
      repo.run(['bundle', 'build']);
      final run = repo.run(['bundle', 'check']);
      expect(run.exitCode, 1);
      expect(
        run.err,
        contains('error L0003: ${FindingCodes.varietySameLayout}'),
        reason: 'L3 is no tutorial, so it may not repeat L2',
      );
      expect(
        run.err,
        contains('error L0004: ${FindingCodes.varietySameLayout}'),
      );
      expect(run.err, contains('the same layout as L3 (L0003)'));
      expect(
        run.err,
        isNot(contains('L0002: ${FindingCodes.varietySameLayout}')),
      );
    });

    test('an unsolvable level fails rule 8', () {
      // Two glass cases that each seal the other's color (the lock deadlock
      // fixture): rule 6 holds per lock, but no set can ever complete.
      repo
        ..writeTutorials()
        ..writeLevel(
          'L0002',
          '{"schemaVersion":1,"id":"L0002","maxSize":3,"shelves":['
              '[{"type":"locked","unlockColor":"blue","nest":["red3","red2"]},'
              '{"type":"locked","unlockColor":"red","nest":["blue3","blue2"]}],'
              '[{"type":"open","nest":["red1"]},{"type":"open","nest":["blue1"]},'
              '{"type":"open","nest":null}]]}',
        );
      repo.run(['bundle', 'build']);
      final run = repo.run(['bundle', 'check']);
      expect(run.exitCode, 1);
      expect(run.err, contains('L0002: ${IssueCodes.unsolvable}'));
      expect(run.err, contains('L0002: ${FindingCodes.scheduleLocked}'));
    });
  });
}
