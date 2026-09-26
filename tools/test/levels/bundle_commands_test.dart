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
        ..writeLevel('L0003', tutorial2('L0003'))
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
        ..writeLevel('L0003', tutorial2('L0003'))
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
      // medium with a reason (D26).
      repo
        ..writeLevel('L0003', tutorial2('L0003'))
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
