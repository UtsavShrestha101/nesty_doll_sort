import 'dart:io';

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_tools/src/levels/authored_levels.dart';
import 'package:nesty_tools/src/levels/finding.dart';
import 'package:nesty_tools/src/levels/level_paths.dart';
import 'package:nesty_tools/src/levels/manifest.dart';
import 'package:path/path.dart' as p;

/// One level to validate, solve, simulate or report, with the play metadata
/// its source file has (a bundle or the manifest have it; a level file
/// doesn't).
final class LevelInput {
  const LevelInput({
    required this.source,
    required this.level,
    this.order,
    this.chapterId,
    this.declaredTier,
    this.tierOverride,
  });

  /// The file it came from, relative to the repo root.
  final String source;

  final Level level;
  final int? order;
  final String? chapterId;
  final Tier? declaredTier;
  final String? tierOverride;

  /// How reports name it: the level id.
  String get label => level.id;
}

/// The levels read from some paths, and what went wrong reading them.
final class LoadedInputs {
  const LoadedInputs(this.inputs, this.findings);

  final List<LevelInput> inputs;
  final List<Finding> findings;
}

/// Reads every level in [paths] (resolved against [cwd]). A path may be a
/// level file (spec §5.1), a bundle (`format: nesty.levels`), the manifest
/// (`format: nesty.levels.manifest`, its levels from `authored/`), or a
/// directory, whose `*.json` files are read in name order. The kind is told
/// from the content, never guessed from the file name.
LoadedInputs loadLevelInputs(
  List<String> paths, {
  required Directory root,
  required Directory cwd,
}) {
  final inputs = <LevelInput>[];
  final findings = <Finding>[];
  for (final path in paths) {
    final resolved = p.normalize(p.join(cwd.path, path));
    if (FileSystemEntity.isDirectorySync(resolved)) {
      final files = [
        for (final f in Directory(resolved).listSync().whereType<File>())
          if (f.path.endsWith('.json')) f,
      ]..sort((a, b) => a.path.compareTo(b.path));
      if (files.isEmpty) {
        findings.add(
          Finding(
            FindingCodes.unreadable,
            'No *.json files in this folder',
            subject: LevelPaths.display(root, Directory(resolved)),
          ),
        );
      }
      for (final file in files) {
        _loadFile(file, root, inputs, findings);
      }
    } else {
      _loadFile(File(resolved), root, inputs, findings);
    }
  }
  return LoadedInputs(inputs, findings);
}

void _loadFile(
  File file,
  Directory root,
  List<LevelInput> inputs,
  List<Finding> findings,
) {
  final subject = LevelPaths.display(root, file);
  final json = readJsonFile(file, root: root, findings: findings);
  if (json == null) return;
  final value = json.value;
  final format = value is Map ? value['format'] : null;

  if (format == LevelBundle.format) {
    final decoded = LevelBundleCodec.decode(value);
    findings.addAll([
      for (final issue in decoded.issues)
        Finding.fromIssue(issue, subject: subject),
    ]);
    for (final entry in decoded.bundle?.levels ?? const <LevelBundleEntry>[]) {
      inputs.add(
        LevelInput(
          source: subject,
          level: entry.level,
          order: entry.order,
          chapterId: entry.chapterId,
          declaredTier: entry.tier,
        ),
      );
    }
  } else if (format == LevelManifest.format) {
    final authored = loadAuthoredLevels(file, root: root);
    findings.addAll(authored.findings);
    for (final level in authored.levels) {
      inputs.add(
        LevelInput(
          source: LevelPaths.display(root, level.file),
          level: level.level,
          order: level.entry.order,
          chapterId: level.entry.chapterId,
          declaredTier: level.entry.tier,
          tierOverride: level.entry.tierOverride,
        ),
      );
    }
  } else {
    final decoded = LevelCodec.decode(value);
    findings.addAll([
      for (final issue in decoded.issues)
        Finding.fromIssue(issue, subject: subject),
    ]);
    final level = decoded.level;
    if (level != null) inputs.add(LevelInput(source: subject, level: level));
  }
}
