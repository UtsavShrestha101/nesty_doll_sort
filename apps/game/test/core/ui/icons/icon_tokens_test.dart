// Every glyph tokens v3 names draws from the bundled font (phase 4
// architecture §1.4): the font is a subset (tools/fonts/nesty_symbols.txt),
// so a glyph missing from it would draw nothing. C4b's `IconUses` maps each
// use to its `NestyIcons` member; this pins the generated names to the font.
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/icons/nesty_icons.gen.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

void main() {
  test('every tokens.json `icons` glyph is a NestyIcons member', () {
    expect(IconTokens.glyphs, hasLength(23));
    expect(
      IconTokens.glyphs.values.where((g) => !NestyIcons.byName.containsKey(g)),
      isEmpty,
    );
    expect(IconTokens.computerTag, 'computer');
    expect(NestyIcons.byName[IconTokens.shareIOS], NestyIcons.iosShare);
  });

  test('the layout sections name font glyphs too', () {
    for (final glyph in [
      RivalStripTokens.tagGlyph,
      RaceBarTokens.undoBadge,
      HomeTokens.recordsButtonGlyph,
      WinStarsTokens.movesChipIcon,
    ]) {
      expect(NestyIcons.byName, contains(glyph), reason: glyph);
    }
  });

  test(
    'the splash errors\' glyphs ship, ahead of tokens.json (lead note 2)',
    () {
      expect(NestyIcons.byName, contains('sd_card_alert'));
      expect(NestyIcons.byName, contains('inventory_2'));
      expect(NestyIcons.sdCardAlert.fontFamily, NestyIcons.fontFamily);
      expect(NestyIcons.inventory2.fontFamily, NestyIcons.fontFamily);
    },
  );
}
