import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/gameplay/overlays/pause_dialog.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/support/screen_harness.dart';

/// M7 overflow suite (m7-design §18 "overflow"): the Pause dialog (frame
/// 3.9) at the five acceptance sizes and both text scales. Behaviour is
/// covered by `test/features/gameplay/overlays/pause_dialog_test.dart`,
/// which sweeps `screenSizes`.
void main() {
  setUpAll(loadBundledFonts);

  Widget dialog() => PauseDialog(
    level: 188,
    tier: Tier.superhard,
    settings: const PauseSettings(sound: true, music: false, haptics: true),
    library: FakeFxLibrary(),
    onSoundChanged: (_) {},
    onMusicChanged: (_) {},
    onHapticsChanged: (_) {},
    onResume: () {},
    onRestart: () {},
    onHome: () {},
    onSettings: () {},
  );

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      testWidgets(
        'fits ${size.width.toInt()}×${size.height.toInt()} at $scale× text',
        (tester) async {
          await pumpScreen(tester, dialog(), size: size, textScale: scale);
          await tester.pump(const Duration(milliseconds: 300));
          await expectAccessibleLayout(tester);
        },
      );
    }
  }
}
