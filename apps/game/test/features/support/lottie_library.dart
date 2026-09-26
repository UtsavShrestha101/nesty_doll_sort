import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_id.dart';

import '../fx/support/fx_test_art.dart';

/// An [FakeFxLibrary] holding every shipped widget-hosted file (the HUD,
/// overlays and screens: `FxHost.widget`), parsed the way the game parses
/// them (`fromBytes`, no images), with the 1×1 blank. Real IO: call it
/// inside `tester.runAsync`.
Future<FakeFxLibrary> widgetLottieLibrary() async {
  final library = FakeFxLibrary()..blank = transparentPixel;
  for (final id in FxId.values) {
    if (id.host != FxHost.widget) continue;
    library.compositions[id] = await shippedOnce(id);
  }
  await library.load();
  return library;
}
