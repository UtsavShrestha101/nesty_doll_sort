import 'dart:convert';
import 'dart:io';

import 'package:nesty_render/svg_tools.dart';
import 'package:nesty_tools/src/file_writes.dart';
import 'package:path/path.dart' as p;

/// Repo-relative asset root of the game.
const gameAssetsDir = 'apps/game/assets';

/// Asset folders the sync owns completely: anything in them that the plan
/// does not produce is removed (or reported by `--check`).
const syncedAssetRoots = ['skins', 'symbols', 'board', 'themes', 'audio'];

/// Board SVGs that are not copied: their pips are baked in for maxSize 6,
/// while the game draws pips itself on the `-blank` variants (spec §10.3).
const excludedBoardFiles = {'slot-stand.svg', 'tower-base.svg'};

final _themeName = RegExp(r'^ch(\d{2})_[a-z0-9_]+\.svg$');
final _wavName = RegExp(r'^[a-z0-9_]+\.wav$');
final _svgName = RegExp(r'^[a-z0-9-]+\.svg$');

/// One file the sync will write, relative to [gameAssetsDir].
final class PlannedAsset {
  PlannedAsset({
    required this.category,
    required this.source,
    required this.destination,
    required this.bytes,
    required this.sourceSize,
  });

  /// One of [syncedAssetRoots].
  final String category;

  /// Repo-relative design file.
  final String source;

  /// Path under `apps/game/assets/`, e.g. `skins/classic/skin.svg`.
  final String destination;

  /// The content to write (sanitized for SVGs).
  final List<int> bytes;

  /// Size of the design file, to report what stripping saved.
  final int sourceSize;
}

/// Everything the sync would do, computed without touching the app assets.
final class AssetSyncPlan {
  AssetSyncPlan(this.assets, this.issues);

  final List<PlannedAsset> assets;

  /// Validation problems (`source: issue`). Non-empty → nothing is written.
  final List<String> issues;

  /// The asset directories `apps/game/pubspec.yaml` must declare, one per
  /// folder because Flutter asset directory entries are not recursive.
  List<String> get assetDirectories {
    final dirs = {
      for (final a in assets) 'assets/${p.posix.dirname(a.destination)}/',
    }.toList()..sort();
    return dirs;
  }
}

/// Builds the sync plan from `design/` under [repoRoot].
AssetSyncPlan planDesignAssetSync(Directory repoRoot) {
  final design = Directory(p.join(repoRoot.path, 'design'));
  final assets = <PlannedAsset>[];
  final issues = <String>[];

  String rel(File f) =>
      p.posix.joinAll(p.split(p.relative(f.path, from: repoRoot.path)));

  void addSvg(
    String category,
    File file,
    String destination,
    List<SvgIssue> Function(String) validate,
  ) {
    final raw = file.readAsStringSync();
    final clean = stripSvgMetadata(raw);
    for (final issue in validate(clean)) {
      issues.add('${rel(file)}: $issue');
    }
    if (clean.contains('c2pa')) {
      issues.add('${rel(file)}: C2PA data survived stripping');
    }
    assets.add(
      PlannedAsset(
        category: category,
        source: rel(file),
        destination: destination,
        bytes: utf8.encode(clean),
        sourceSize: file.lengthSync(),
      ),
    );
  }

  List<File> filesIn(String sub) {
    final dir = Directory(p.join(design.path, sub));
    if (!dir.existsSync()) {
      issues.add('design/$sub: missing');
      return const [];
    }
    return dir
        .listSync()
        .whereType<File>()
        .where((f) => !p.basename(f.path).startsWith('.'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
  }

  // Skins: design/skins/<id>/<id>.svg + skin.json → skins/<id>/skin.{svg,json}.
  final skinsDir = Directory(p.join(design.path, 'skins'));
  final skinDirs = skinsDir.existsSync()
      ? (skinsDir.listSync().whereType<Directory>().toList()
          ..sort((a, b) => a.path.compareTo(b.path)))
      : <Directory>[];
  if (skinDirs.isEmpty) issues.add('design/skins: no skins found');
  for (final dir in skinDirs) {
    final id = p.basename(dir.path);
    final svg = File(p.join(dir.path, '$id.svg'));
    final json = File(p.join(dir.path, 'skin.json'));
    if (!svg.existsSync() || !json.existsSync()) {
      issues.add('design/skins/$id: needs $id.svg and skin.json');
      continue;
    }
    addSvg('skins', svg, 'skins/$id/skin.svg', validateSkinSvg);
    Object? manifest;
    try {
      manifest = jsonDecode(json.readAsStringSync());
    } on FormatException catch (e) {
      issues.add('${rel(json)}: not JSON (${e.message})');
    }
    for (final issue in validateSkinManifest(manifest, expectedSkinId: id)) {
      issues.add('${rel(json)}: $issue');
    }
    assets.add(
      PlannedAsset(
        category: 'skins',
        source: rel(json),
        destination: 'skins/$id/skin.json',
        bytes: json.readAsBytesSync(),
        sourceSize: json.lengthSync(),
      ),
    );
  }

  for (final file in filesIn('symbols')) {
    final name = p.basename(file.path);
    if (!_svgName.hasMatch(name)) {
      issues.add('${rel(file)}: unexpected file in design/symbols');
      continue;
    }
    addSvg('symbols', file, 'symbols/$name', validateSvg);
  }

  for (final file in filesIn('board')) {
    final name = p.basename(file.path);
    if (excludedBoardFiles.contains(name)) continue;
    if (!_svgName.hasMatch(name)) {
      issues.add('${rel(file)}: unexpected file in design/board');
      continue;
    }
    addSvg('board', file, 'board/$name', validateSvg);
  }

  for (final file in filesIn('themes')) {
    final name = p.basename(file.path);
    final match = _themeName.firstMatch(name);
    if (match == null) {
      issues.add('${rel(file)}: theme files are named chNN_<slug>.svg');
      continue;
    }
    addSvg('themes', file, 'themes/ch${match[1]}/background.svg', validateSvg);
  }

  for (final file in filesIn('audio')) {
    final name = p.basename(file.path);
    if (!_wavName.hasMatch(name)) {
      issues.add('${rel(file)}: unexpected file in design/audio');
      continue;
    }
    final bytes = file.readAsBytesSync();
    if (!_isWav(bytes)) {
      issues.add('${rel(file)}: not a RIFF/WAVE file');
    }
    assets.add(
      PlannedAsset(
        category: 'audio',
        source: rel(file),
        destination: 'audio/$name',
        bytes: bytes,
        sourceSize: bytes.length,
      ),
    );
  }

  _checkSymbolsCoverTokens(repoRoot, assets, issues);

  final seen = <String>{};
  for (final a in assets) {
    if (!seen.add(a.destination)) {
      issues.add('${a.source}: two design files map to ${a.destination}');
    }
  }
  assets.sort((a, b) => a.destination.compareTo(b.destination));
  return AssetSyncPlan(assets, issues);
}

// Every dollColor symbol named in tokens.json must ship, or a doll would
// render without its color-blind symbol (spec §12.3).
void _checkSymbolsCoverTokens(
  Directory repoRoot,
  List<PlannedAsset> assets,
  List<String> issues,
) {
  final tokens = File(p.join(repoRoot.path, 'design', 'tokens.json'));
  if (!tokens.existsSync()) return;
  final json = jsonDecode(tokens.readAsStringSync());
  final colors = json is Map<String, Object?> ? json['dollColor'] : null;
  if (colors is! Map<String, Object?>) return;
  final symbols = {
    for (final a in assets)
      if (a.category == 'symbols')
        p.posix.basenameWithoutExtension(a.destination),
  };
  for (final MapEntry(key: id, value: color) in colors.entries) {
    final symbol = color is Map<String, Object?> ? color['symbol'] : null;
    if (symbol is String && !symbols.contains(symbol)) {
      issues.add('design/symbols: missing $symbol.svg (dollColor.$id)');
    }
  }
}

bool _isWav(List<int> bytes) =>
    bytes.length > 12 &&
    String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
    String.fromCharCodes(bytes.sublist(8, 12)) == 'WAVE';

/// What [applyAssetSyncPlan] did (or, dry-run, would do).
final class AssetSyncResult {
  AssetSyncResult(this.outcomes, this.removed, this.missingPubspecDirs);

  /// Destination → outcome.
  final Map<String, WriteOutcome> outcomes;

  /// Stale files under the synced roots (removed unless dry-run).
  final List<String> removed;

  /// Asset directories `apps/game/pubspec.yaml` does not declare.
  final List<String> missingPubspecDirs;

  bool get hasDrift =>
      outcomes.values.any((o) => o != WriteOutcome.unchanged) ||
      removed.isNotEmpty ||
      missingPubspecDirs.isNotEmpty;
}

/// Writes [plan] into `apps/game/assets` under [repoRoot]: only files whose
/// bytes changed, and removes files the plan no longer produces. With
/// [dryRun] nothing changes on disk.
AssetSyncResult applyAssetSyncPlan(
  AssetSyncPlan plan,
  Directory repoRoot, {
  bool dryRun = false,
}) {
  if (plan.issues.isNotEmpty) {
    throw StateError('Refusing to sync: the plan has validation issues.');
  }
  final assetsRoot = p.join(repoRoot.path, gameAssetsDir);
  final outcomes = <String, WriteOutcome>{};
  for (final asset in plan.assets) {
    outcomes[asset.destination] = writeBytesIfChanged(
      File(p.join(assetsRoot, asset.destination)),
      asset.bytes,
      dryRun: dryRun,
    );
  }
  final planned = {for (final a in plan.assets) a.destination};
  final removed = <String>[];
  for (final category in syncedAssetRoots) {
    final dir = Directory(p.join(assetsRoot, category));
    if (!dir.existsSync()) continue;
    final files = dir.listSync(recursive: true).whereType<File>().toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    for (final file in files) {
      final relative = p.posix.joinAll(
        p.split(p.relative(file.path, from: assetsRoot)),
      );
      if (planned.contains(relative)) continue;
      removed.add(relative);
      if (!dryRun) file.deleteSync();
    }
    if (!dryRun) _removeEmptyDirs(dir);
  }
  return AssetSyncResult(
    outcomes,
    removed,
    _missingPubspecDirs(repoRoot, plan.assetDirectories),
  );
}

void _removeEmptyDirs(Directory dir) {
  for (final child in dir.listSync().whereType<Directory>()) {
    _removeEmptyDirs(child);
    if (child.listSync().isEmpty) child.deleteSync();
  }
}

List<String> _missingPubspecDirs(Directory repoRoot, List<String> dirs) {
  final pubspec = File(p.join(repoRoot.path, 'apps', 'game', 'pubspec.yaml'));
  if (!pubspec.existsSync()) return dirs;
  final declared = {
    for (final m in RegExp(
      r'^\s*-\s*(assets/\S+)\s*$',
      multiLine: true,
    ).allMatches(pubspec.readAsStringSync()))
      m[1]!,
  };
  return [
    for (final d in dirs)
      if (!declared.contains(d)) d,
  ];
}
