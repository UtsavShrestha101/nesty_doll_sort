import 'dart:convert';
import 'dart:io';

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_tools/src/levels/finding.dart';
import 'package:nesty_tools/src/levels/level_paths.dart';
import 'package:nesty_tools/src/levels/manifest.dart';
import 'package:path/path.dart' as p;

/// One manifest entry with its decoded level file.
final class AuthoredLevel {
  const AuthoredLevel(this.entry, this.level, this.file);

  final ManifestEntry entry;
  final Level level;
  final File file;

  /// The bundle entry this level becomes. The reward follows the declared
  /// tier (spec §7.3, design A27). [par] is the star rating's par, the
  /// solver's optimum (spec-prop §7.10, D146): `bundle build` passes it,
  /// and null writes no `par` key.
  LevelBundleEntry toBundleEntry({int? par}) => LevelBundleEntry(
    order: entry.order,
    chapterId: entry.chapterId,
    tier: entry.tier,
    version: entry.version,
    rewardCoins: entry.tier.defaultRewardCoins,
    level: level,
    par: par,
  );
}

/// The manifest and every authored level it names, or the findings that
/// stop them from becoming a bundle.
final class AuthoredLevels {
  AuthoredLevels({
    required this.manifest,
    required List<AuthoredLevel> levels,
    required List<Finding> findings,
  }) : levels = List.unmodifiable(levels),
       findings = List.unmodifiable(findings);

  /// Null when the manifest itself couldn't be read.
  final LevelManifest? manifest;

  /// The entries whose level file decoded, in play order.
  final List<AuthoredLevel> levels;

  final List<Finding> findings;

  /// True when every entry has its level and nothing is wrong: the bundle
  /// may be built.
  bool get isComplete =>
      manifest != null &&
      levels.length == manifest!.levels.length &&
      !findings.any((f) => f.isError);

  /// The bundle these levels make (design §4). Only meaningful when
  /// [isComplete]. [pars] maps a level id to its par (spec-prop §7.10); a
  /// level missing from it gets no `par` key.
  LevelBundle toBundle({Map<String, int> pars = const {}}) => LevelBundle(
    levelsVersion: manifest!.levelsVersion,
    levels: [
      for (final level in levels)
        level.toBundleEntry(par: pars[level.entry.id]),
    ],
  );
}

/// Reads [manifestFile] and the level file of each of its entries
/// (`authored/<id>.json` next to it). Findings name files relative to
/// [root].
///
/// Every level file must decode without issues and carry its entry's id, and
/// every `*.json` in `authored/` must be in the manifest, so no level is
/// silently left out of the bundle.
AuthoredLevels loadAuthoredLevels(
  File manifestFile, {
  required Directory root,
}) {
  final subject = LevelPaths.display(root, manifestFile);
  final findings = <Finding>[];
  final json = readJsonFile(manifestFile, root: root, findings: findings);
  if (json == null) {
    return AuthoredLevels(manifest: null, levels: const [], findings: findings);
  }
  final parse = parseManifest(json.value, subject: subject);
  findings.addAll(parse.findings);
  final manifest = parse.manifest;
  if (manifest == null) {
    return AuthoredLevels(manifest: null, levels: const [], findings: findings);
  }

  final levels = <AuthoredLevel>[];
  for (final entry in manifest.levels) {
    final file = LevelPaths.authoredFile(manifestFile, entry.id);
    final fileSubject = LevelPaths.display(root, file);
    if (!file.existsSync()) {
      findings.add(
        Finding(
          FindingCodes.missingLevelFile,
          'Entry ${entry.order} (${entry.id}) has no level file',
          subject: fileSubject,
        ),
      );
      continue;
    }
    final level = readJsonFile(file, root: root, findings: findings);
    if (level == null) continue;
    final decoded = LevelCodec.decode(level.value);
    findings.addAll([
      for (final issue in decoded.issues)
        Finding.fromIssue(issue, subject: fileSubject),
    ]);
    final decodedLevel = decoded.level;
    if (decodedLevel == null) continue;
    if (decodedLevel.id != entry.id) {
      findings.add(
        Finding(
          FindingCodes.idMismatch,
          'The file\'s id is "${decodedLevel.id}" but the manifest names it '
          '"${entry.id}"',
          subject: fileSubject,
          path: '/id',
        ),
      );
      continue;
    }
    levels.add(AuthoredLevel(entry, decodedLevel, file));
  }

  final authoredDir = Directory(p.join(manifestFile.parent.path, 'authored'));
  if (authoredDir.existsSync()) {
    final named = {for (final entry in manifest.levels) '${entry.id}.json'};
    final stray = [
      for (final file in authoredDir.listSync().whereType<File>())
        if (file.path.endsWith('.json') &&
            !named.contains(p.basename(file.path)))
          file,
    ]..sort((a, b) => a.path.compareTo(b.path));
    for (final file in stray) {
      findings.add(
        Finding(
          FindingCodes.strayLevelFile,
          'Not in the manifest, so it would never ship: add an entry for it '
          'or delete it',
          subject: LevelPaths.display(root, file),
        ),
      );
    }
  }
  return AuthoredLevels(manifest: manifest, levels: levels, findings: findings);
}

/// Spec §5.2, §13.3: a level's `version` goes up whenever its board changes,
/// because the game restores an in-progress save only while the version
/// matches. Compares [next] with the [previous] bundle by level id; a board
/// that changed at the same (or a lower) version is an error.
List<Finding> checkVersionBumps(LevelBundle previous, LevelBundle next) {
  final previousById = {
    for (final entry in previous.levels) entry.level.id: entry,
  };
  return [
    for (final entry in next.levels)
      if (previousById[entry.level.id] case final old?)
        if (entry.version < old.version)
          Finding(
            FindingCodes.versionNotBumped,
            'version went down from ${old.version} to ${entry.version}; a '
            'level\'s version only goes up (spec §5.2)',
            subject: entry.level.id,
          )
        else if (entry.version == old.version && entry.level != old.level)
          Finding(
            FindingCodes.versionNotBumped,
            'The board changed but version is still ${entry.version}: raise '
            'its "version" in the manifest, so a saved game of the old board '
            'is not restored (spec §5.2, §13.3)',
            subject: entry.level.id,
          ),
  ];
}

/// The parsed JSON of [file], or null after adding an
/// `input.unreadable` / `input.invalidJson` finding. Wrapped in a record so
/// a file holding `null` is still a value.
({Object? value})? readJsonFile(
  File file, {
  required Directory root,
  required List<Finding> findings,
}) {
  final subject = LevelPaths.display(root, file);
  final String text;
  try {
    text = file.readAsStringSync();
  } on FileSystemException catch (e) {
    findings.add(Finding(FindingCodes.unreadable, e.message, subject: subject));
    return null;
  }
  try {
    return (value: jsonDecode(text));
  } on FormatException catch (e) {
    findings.add(
      Finding(
        FindingCodes.invalidJson,
        'Not valid JSON: ${e.message}',
        subject: subject,
      ),
    );
    return null;
  }
}
