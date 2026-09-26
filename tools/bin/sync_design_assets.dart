// Copies the design handoff's runtime assets into apps/game/assets:
//   skins/<id>/skin.svg + skin.json, symbols/*.svg, board/*.svg (not the
//   baked-pip stands), themes/chNN/background.svg, audio/*.wav
// SVGs lose their C2PA <metadata> and are validated against spec §12.2
// (package:nesty_render/svg_tools.dart). Only changed files are written;
// files the design no longer has are removed.
//
// Usage: dart run nesty_tools:sync_design_assets [--check]
//   --check  write nothing; exit 1 on any drift (CI).
import 'dart:io';

import 'package:nesty_tools/src/assets/design_asset_sync.dart';
import 'package:nesty_tools/src/cli_args.dart';
import 'package:nesty_tools/src/file_writes.dart';
import 'package:nesty_tools/src/repo_root.dart';

void main(List<String> arguments) {
  final CliArgs args;
  try {
    args = CliArgs.parse(arguments, flags: {'check', 'help'});
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    exitCode = 64;
    return;
  }
  if (args.flag('help')) {
    stdout.writeln('Usage: dart run nesty_tools:sync_design_assets [--check]');
    return;
  }
  final check = args.flag('check');
  final root = findRepoRoot();
  final plan = planDesignAssetSync(root);
  if (plan.issues.isNotEmpty) {
    stderr.writeln('Design assets failed validation; nothing was written:');
    for (final issue in plan.issues) {
      stderr.writeln('  $issue');
    }
    exitCode = 1;
    return;
  }
  final result = applyAssetSyncPlan(plan, root, dryRun: check);

  stdout.writeln('Design assets → $gameAssetsDir${check ? ' (check)' : ''}');
  for (final category in syncedAssetRoots) {
    final assets = plan.assets.where((a) => a.category == category).toList();
    final counts = <WriteOutcome, int>{};
    for (final a in assets) {
      final outcome = result.outcomes[a.destination]!;
      counts[outcome] = (counts[outcome] ?? 0) + 1;
    }
    final source = assets.fold<int>(0, (sum, a) => sum + a.sourceSize);
    final shipped = assets.fold<int>(0, (sum, a) => sum + a.bytes.length);
    stdout.writeln(
      '  ${category.padRight(8)} ${assets.length.toString().padLeft(3)} files'
      '  ${_kb(shipped).padLeft(8)}'
      '${source == shipped ? '' : ' (−${_kb(source - shipped)} metadata)'}'
      '  ${WriteOutcome.values.where(counts.containsKey).map((o) => '${counts[o]} ${o.name}').join(', ')}',
    );
  }
  for (final removed in result.removed) {
    stdout.writeln('  ${check ? 'stale  ' : 'removed'} $removed');
  }
  if (check) {
    for (final entry in result.outcomes.entries) {
      if (entry.value != WriteOutcome.unchanged) {
        stdout.writeln('  ${entry.value.name.padRight(9)} ${entry.key}');
      }
    }
  }
  if (result.missingPubspecDirs.isNotEmpty) {
    stderr.writeln(
      'apps/game/pubspec.yaml does not declare these asset directories:\n'
      '${result.missingPubspecDirs.map((d) => '    - $d').join('\n')}',
    );
    exitCode = 1;
  }
  if (check && result.hasDrift) {
    stderr.writeln(
      'App assets are out of sync with design/. Run: '
      'dart run nesty_tools:sync_design_assets',
    );
    exitCode = 1;
  }
}

String _kb(int bytes) => '${(bytes / 1024).toStringAsFixed(1)} KB';
