import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';

/// Every host test starts in the Latin script: the locale's script and its
/// display face are process-wide (`LocaleScriptScope` sets them as it
/// builds), so a test that drew Turkish (Baloo 2) must not hand its face to
/// the next one (m7-5 item 28).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  setUp(() {
    LocaleScript.current = LocaleScript.latin;
    DisplayFace.use(LocaleScript.latin, LocaleScript.latin.display);
  });
  await testMain();
}
