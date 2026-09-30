import 'dart:convert';
import 'dart:io';

import 'package:nesty_render/svg_tools.dart';
import 'package:nesty_tools/src/assets/android_vector.dart';
import 'package:nesty_tools/src/assets/audio_formats.dart';
import 'package:nesty_tools/src/assets/png_formats.dart';
import 'package:nesty_tools/src/file_writes.dart';
import 'package:nesty_tools/src/fx/lottie_contract.dart';
import 'package:nesty_tools/src/fx/lottie_sources.dart';
import 'package:nesty_tools/src/tokens/sound_files.dart';
import 'package:path/path.dart' as p;

/// Repo-relative asset root of the game.
const gameAssetsDir = 'apps/game/assets';

/// Asset folders the sync owns completely: anything in them that the plan
/// does not produce is removed (or reported by `--check`). For `lottie/`
/// that includes any PNG: the placeholders never ship (PROGRESS D50).
const syncedAssetRoots = [
  'skins',
  'symbols',
  'board',
  'themes',
  'audio',
  gameLottieDir,
  'museum',
  'ui',
];

/// The `design/ui/` folders that ship as UI art (m7-3, phase 4 architecture
/// §1.3 and §3.4): `design/ui/<folder>/<name>.svg` →
/// `assets/ui/<folder>/<name>.svg`, metadata stripped and validated like the
/// board art. `design/ui/notification/` is the Android small icon (a
/// platform output, [notificationIconDrawable]); `design/ui/icons/` must
/// stay empty, since every icon use is a glyph of the bundled font (tokens
/// `icons.$note`).
const uiArtFolders = ['badges', 'chest', 'rivals', 'sprites', 'stars'];

/// The ten bundled museum figurine ids, in chapter order (m3-design §9.1,
/// §9.5). Must match `BundledCatalogRepository.figurineIds`; `tools/` does
/// not depend on `apps/game`, so this is the sync's own copy.
const defaultMuseumFigurineIds = [
  'classic',
  'sailor',
  'baker',
  'astronaut',
  'gardener',
  'snow',
  'circus',
  'musician',
  'royal',
  'explorer',
];

/// Board SVGs that are not copied: their pips are baked in for maxSize 6,
/// while the game draws pips itself on the `-blank` variants (spec §10.3).
const excludedBoardFiles = {'slot-stand.svg', 'tower-base.svg'};

/// The owner's audio contract in `design/audio/`: read by people, never
/// shipped.
const audioContractDoc = 'AUDIO.md';

final _themeName = RegExp(r'^ch(\d{2})_[a-z0-9_]+\.svg$');
final _audioName = RegExp(r'^([a-z0-9_]+)\.(wav|ogg)$');
final _svgName = RegExp(r'^[a-z0-9-]+\.svg$');
final _uiSvgName = RegExp(r'^[a-z0-9_]+\.svg$');

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

/// A generated file outside `apps/game/assets/` (a platform resource), by
/// its repo-relative [path]: the sync writes it and `--check` compares its
/// bytes, but it is not a Flutter asset.
final class PlannedOutput {
  PlannedOutput({
    required this.source,
    required this.path,
    required this.bytes,
  });

  /// Repo-relative design file.
  final String source;

  /// Repo-relative output, e.g. [notificationIconDrawable].
  final String path;

  final List<int> bytes;
}

/// Everything the sync would do, computed without touching the app assets.
final class AssetSyncPlan {
  AssetSyncPlan(this.assets, this.issues, {this.outputs = const []});

  final List<PlannedAsset> assets;

  /// The platform files generated from `design/` (the Android notification
  /// icon).
  final List<PlannedOutput> outputs;

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
///
/// [lottieTable] is the contract the Lottie exports are validated against
/// (tests pass a smaller one for a scratch repo). [museumFigurineIds] is the
/// expected `design/museum/png/` set, in the same way.
AssetSyncPlan planDesignAssetSync(
  Directory repoRoot, {
  List<LottieFileContract> lottieTable = lottieContracts,
  List<String> museumFigurineIds = defaultMuseumFigurineIds,
}) {
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

  // Audio: the SFX (WAV) and the music loops and jingles (Ogg Vorbis), byte
  // for byte after a format check (tokens.json `sound.format`, AUDIO.md).
  // Never AUDIO.md.
  final audio = <String>{}; // file names
  final oggFrames = <String, int>{}; // base name → frames
  for (final file in filesIn('audio')) {
    final name = p.basename(file.path);
    if (name == audioContractDoc) continue;
    final match = _audioName.firstMatch(name);
    if (match == null) {
      issues.add('${rel(file)}: unexpected file in design/audio');
      continue;
    }
    final bytes = file.readAsBytesSync();
    audio.add(name);
    if (match[2] == 'wav') {
      for (final issue in validateSfxWav(bytes)) {
        issues.add('${rel(file)}: $issue');
      }
    } else {
      final ogg = readOggVorbis(bytes);
      for (final issue in ogg.issues) {
        issues.add('${rel(file)}: $issue');
      }
      if (ogg.info case final info?) oggFrames[match[1]!] = info.lastGranule;
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

  // Lottie: design/lottie/*.json → lottie/<name>.json, byte for byte, after
  // validation against the LOTTIE.md contract (lib/src/fx/). Never
  // images/ (placeholders, D50) or LOTTIE.md.
  final lottie = readDesignLottie(repoRoot, contracts: lottieTable);
  issues.addAll(lottie.issues);
  for (final source in lottie.sources) {
    assets.add(
      PlannedAsset(
        category: gameLottieDir,
        source: source.path,
        destination: '$gameLottieDir/${source.name}.json',
        bytes: source.bytes,
        sourceSize: source.bytes.length,
      ),
    );
  }

  // Museum figurine art: design/museum/png/NN-<id>.png (+ its -locked
  // silhouette), byte for byte after validating the PNG signature and
  // 600×600 size (m3-design §9.5). The nested-<svg>/mix-blend-mode SVGs
  // beside it never ship (flutter_svg can't draw them, D18).
  final museumDir = Directory(p.join(design.path, 'museum', 'png'));
  if (!museumDir.existsSync()) {
    issues.add('design/museum/png: missing');
  } else {
    final expected = <String>{
      for (var i = 0; i < museumFigurineIds.length; i++) ...[
        '${(i + 1).toString().padLeft(2, '0')}-${museumFigurineIds[i]}.png',
        '${(i + 1).toString().padLeft(2, '0')}-${museumFigurineIds[i]}'
            '-locked.png',
      ],
    };
    final found = <String>{};
    for (final file
        in museumDir
            .listSync()
            .whereType<File>()
            .where((f) => !p.basename(f.path).startsWith('.'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path))) {
      final name = p.basename(file.path);
      if (!expected.contains(name)) {
        issues.add('${rel(file)}: not one of the expected museum figurines');
        continue;
      }
      found.add(name);
      final bytes = file.readAsBytesSync();
      for (final issue in validateMuseumPng(bytes)) {
        issues.add('${rel(file)}: $issue');
      }
      assets.add(
        PlannedAsset(
          category: 'museum',
          source: rel(file),
          destination: 'museum/$name',
          bytes: bytes,
          sourceSize: bytes.length,
        ),
      );
    }
    for (final missing in expected.difference(found).toList()..sort()) {
      issues.add('design/museum/png/$missing: missing');
    }
  }

  // UI art (m7-3): design/ui/<folder>/*.svg → ui/<folder>/*.svg, and the
  // Android notification icon from design/ui/notification/.
  final outputs = <PlannedOutput>[];
  final uiDir = Directory(p.join(design.path, 'ui'));
  if (!uiDir.existsSync()) {
    issues.add('design/ui: missing');
  } else {
    final entries = uiDir.listSync().toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    for (final entry in entries) {
      final name = p.basename(entry.path);
      if (name.startsWith('.')) continue;
      if (entry is! Directory) {
        issues.add('design/ui/$name: unexpected file in design/ui');
      } else if (name == 'icons') {
        for (final file in filesIn('ui/icons')) {
          issues.add(
            '${rel(file)}: icons ship as glyphs of the bundled font; add the '
            'glyph to tokens.json `icons` and tools/fonts/nesty_symbols.txt '
            'instead',
          );
        }
      } else if (name == 'notification') {
        final icon = File(p.join(repoRoot.path, notificationIconSource));
        for (final file in filesIn('ui/notification')) {
          if (file.path != icon.path) {
            issues.add(
              '${rel(file)}: unexpected file in design/ui/notification',
            );
          }
        }
      } else if (!uiArtFolders.contains(name)) {
        issues.add(
          'design/ui/$name: unknown UI art folder (expected '
          '${[...uiArtFolders, 'icons', 'notification'].join(', ')})',
        );
      }
    }
    for (final folder in uiArtFolders) {
      for (final file in filesIn('ui/$folder')) {
        final name = p.basename(file.path);
        if (!_uiSvgName.hasMatch(name)) {
          issues.add('${rel(file)}: UI art files are named [a-z0-9_]+.svg');
          continue;
        }
        addSvg('ui', file, 'ui/$folder/$name', validateSvg);
      }
    }
    final icon = File(p.join(repoRoot.path, notificationIconSource));
    if (!icon.existsSync()) {
      issues.add(
        "$notificationIconSource: missing (the daily reminder's small icon)",
      );
    } else {
      final vector = androidVectorOf(icon.readAsStringSync());
      for (final issue in vector.issues) {
        issues.add('$notificationIconSource: $issue');
      }
      if (vector.xml case final xml?) {
        outputs.add(
          PlannedOutput(
            source: notificationIconSource,
            path: notificationIconDrawable,
            bytes: utf8.encode(xml),
          ),
        );
      }
    }
  }

  _checkSymbolsCoverTokens(repoRoot, assets, issues);
  _checkAudioCoversTokens(repoRoot, audio, oggFrames, issues);

  final seen = <String>{};
  for (final a in assets) {
    if (!seen.add(a.destination)) {
      issues.add('${a.source}: two design files map to ${a.destination}');
    }
  }
  assets.sort((a, b) => a.destination.compareTo(b.destination));
  return AssetSyncPlan(assets, issues, outputs: outputs);
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

// Every file tokens.json's `sound` section names must ship in its format
// (SFX as WAV, jingles and music as Ogg), each loop exactly its `frames`
// long, and every shipped file must be one of them: the game preloads
// `SoundTokens.allFiles` and `jingleFiles` and streams `musicFiles`.
void _checkAudioCoversTokens(
  Directory repoRoot,
  Set<String> audio,
  Map<String, int> oggFrames,
  List<String> issues,
) {
  final tokens = File(p.join(repoRoot.path, 'design', 'tokens.json'));
  if (!tokens.existsSync()) return;
  final json = jsonDecode(tokens.readAsStringSync());
  if (json is! Map<String, Object?>) return;
  final SoundFiles? files;
  try {
    files = soundFilesOf(json);
  } on FormatException catch (e) {
    issues.add('design/tokens.json: ${e.message}');
    return;
  }
  if (files == null) return;
  final wanted = {
    for (final name in files.sfx) '$name.wav',
    for (final name in files.jingles) '$name.ogg',
    for (final name in files.musicFrames.keys) '$name.ogg',
  };
  for (final name in wanted.difference(audio)) {
    issues.add('design/audio: missing $name (tokens.json `sound` names it)');
  }
  for (final name in audio.difference(wanted)) {
    issues.add(
      'design/audio/$name: no tokens.json `sound` event or music track uses '
      'it',
    );
  }
  for (final MapEntry(key: name, value: frames) in files.musicFrames.entries) {
    final granule = oggFrames[name];
    if (granule != null && granule != frames) {
      issues.add(
        'design/audio/$name.ogg: the stream is $granule frames long, '
        'tokens.json `sound.music` says $frames',
      );
    }
  }
}

/// What [applyAssetSyncPlan] did (or, dry-run, would do).
final class AssetSyncResult {
  AssetSyncResult(
    this.outcomes,
    this.removed,
    this.missingPubspecDirs, {
    this.outputOutcomes = const {},
  });

  /// Destination → outcome.
  final Map<String, WriteOutcome> outcomes;

  /// Platform output path ([PlannedOutput.path]) → outcome.
  final Map<String, WriteOutcome> outputOutcomes;

  /// Stale files under the synced roots (removed unless dry-run).
  final List<String> removed;

  /// Asset directories `apps/game/pubspec.yaml` does not declare.
  final List<String> missingPubspecDirs;

  bool get hasDrift =>
      outcomes.values.any((o) => o != WriteOutcome.unchanged) ||
      outputOutcomes.values.any((o) => o != WriteOutcome.unchanged) ||
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
  final outputOutcomes = {
    for (final output in plan.outputs)
      output.path: writeBytesIfChanged(
        File(p.join(repoRoot.path, output.path)),
        output.bytes,
        dryRun: dryRun,
      ),
  };
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
    outputOutcomes: outputOutcomes,
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
