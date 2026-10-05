import 'dart:io';

import 'package:nesty_tools/src/fonts/ttf_cmap.dart';
import 'package:path/path.dart' as p;

/// Repo-relative folder of the fonts `tools/fonts/build_fonts.sh` installs.
const bundledFontsDir = 'apps/game/assets/fonts';

/// The weight each static file's style suffix names (`Nunito-Bold.ttf`):
/// the weight of its outlines, which for a script role family is not its
/// `OS/2` weight class (see [scriptFamilyName]).
const styleWeights = {
  'Thin': 100,
  'ExtraLight': 200,
  'Light': 300,
  'Regular': 400,
  'Medium': 500,
  'SemiBold': 600,
  'Bold': 700,
  'ExtraBold': 800,
  'Black': 900,
};

/// The two Latin roles of tokens.json `font` and the pubspec suffix of
/// their script families.
const fontRoles = {'display': 'Display', 'body': 'Body'};

/// The pubspec family of [designFamily]'s face for the Latin [role]
/// (`display` or `body`), e.g. `Baloo2Body` for "Baloo 2".
///
/// tokens.json `font.scripts.<script>.weights` maps each Latin role weight
/// to a script weight (m7-4 9.1: Devanagari body 700 → Baloo 2 600,
/// Japanese display 700 → M PLUS 800). A text style's `fontWeight` is the
/// Latin one and the engine matches it against each file's `OS/2` weight
/// class, so each role gets its own family whose files carry the Latin
/// weight they answer: `Baloo2Body-SemiBold.ttf` is Baloo 2 SemiBold with
/// weight class 700. One family per script could not map display 700 and
/// body 700 to different weights.
String scriptFamilyName(String designFamily, String role) {
  final suffix = fontRoles[role];
  if (suffix == null) throw ArgumentError.value(role, 'role');
  return '${designFamily.replaceAll(' ', '')}$suffix';
}

/// One bundled `<Family>-<Style>.ttf`.
final class BundledFont {
  BundledFont(this.family, this.style, this.path, this.info);

  final String family;
  final String style;
  final String path;
  final TtfInfo info;

  /// The weight of the file's outlines, from its style suffix.
  int get outlineWeight => styleWeights[style]!;

  @override
  String toString() => p.basename(path);
}

/// The bundled static fonts under [root]'s [bundledFontsDir], by family.
/// Files without a `-<Style>` suffix (the icon font) are skipped.
Map<String, List<BundledFont>> loadBundledFonts(Directory root) {
  final dir = Directory(p.join(root.path, bundledFontsDir));
  final families = <String, List<BundledFont>>{};
  final files = dir.listSync().whereType<File>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final file in files) {
    if (p.extension(file.path) != '.ttf') continue;
    final name = p.basenameWithoutExtension(file.path);
    final dash = name.lastIndexOf('-');
    if (dash == -1) continue;
    final style = name.substring(dash + 1);
    if (!styleWeights.containsKey(style)) {
      throw FormatException('${file.path}: unknown style "$style"');
    }
    final family = name.substring(0, dash);
    families
        .putIfAbsent(family, () => [])
        .add(
          BundledFont(
            family,
            style,
            file.path,
            TtfInfo.parse(file.readAsBytesSync()),
          ),
        );
  }
  return families;
}

/// The file of [family] the engine draws a [desired] weight from: CSS Fonts
/// level 3 weight matching on the files' `OS/2` weight classes, as Skia's
/// `matchStyleCSS3` does (pubspec's `weight:` is not read on mobile).
BundledFont matchWeight(List<BundledFont> family, int desired) {
  if (family.isEmpty) throw ArgumentError('an empty family');
  final byWeight = {for (final f in family) f.info.weightClass: f};
  final weights = byWeight.keys.toList()..sort();
  if (byWeight.containsKey(desired)) return byWeight[desired]!;
  final lighter = weights.where((w) => w < desired).toList().reversed;
  final heavier = weights.where((w) => w > desired);
  Iterable<int> order;
  if (desired >= 400 && desired <= 500) {
    order = [
      ...heavier.where((w) => w <= 500),
      ...lighter,
      ...heavier.where((w) => w > 500),
    ];
  } else if (desired < 400) {
    order = [...lighter, ...heavier];
  } else {
    order = [...heavier, ...lighter];
  }
  return byWeight[order.first]!;
}
