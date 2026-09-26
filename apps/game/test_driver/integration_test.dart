import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Host side of `flutter drive` for `integration_test/` (BACKLOG M2
/// "On-device playthrough", PROGRESS D57):
///
/// ```sh
/// cd apps/game
/// NESTY_SCREENSHOT_DIR=/some/dir flutter drive --flavor dev \
///   --driver test_driver/integration_test.dart \
///   --target integration_test/playthrough_test.dart -d <device>
/// ```
///
/// Every `binding.takeScreenshot(name)` the test takes is written here as
/// `<name>.png`, into `$NESTY_SCREENSHOT_DIR` or, by default,
/// `build/integration_test/screenshots/` (ignored by git). The screenshots
/// are not kept in the response data file: only the test result is.
Future<void> main() {
  final directory = Directory(
    Platform.environment['NESTY_SCREENSHOT_DIR'] ??
        'build/integration_test/screenshots',
  )..createSync(recursive: true);
  return integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      final file = File('${directory.path}/$name.png');
      await file.writeAsBytes(bytes);
      stdout.writeln('screenshot ${file.path} (${bytes.length} bytes)');
      return true;
    },
    responseDataCallback: (data) async {
      final summary = <String, dynamic>{...?data}..remove('screenshots');
      if (summary.isEmpty) return;
      await writeResponseData(summary);
    },
  );
}
