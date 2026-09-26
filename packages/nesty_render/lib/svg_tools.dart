/// Flutter-free SVG checks shared by the design asset sync
/// (`tools/bin/sync_design_assets.dart`), the admin's skin upload (M5) and
/// the game's skin loader: metadata stripping, the renderable-subset rules
/// of spec §12.2 and the `skin.json` schema.
///
/// This library imports only `package:xml` (no `dart:ui`, no Flutter), so
/// pure-Dart tools can use it with `dart run`. The test
/// `svg_tools_purity_test.dart` keeps it that way.
library;

export 'package:nesty_render/src/svg_tools/skin_manifest_validator.dart';
export 'package:nesty_render/src/svg_tools/svg_issue.dart';
export 'package:nesty_render/src/svg_tools/svg_sanitizer.dart';
export 'package:nesty_render/src/svg_tools/svg_validator.dart';
