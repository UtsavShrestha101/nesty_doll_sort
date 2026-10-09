import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `bootstrap` can't run in a host test (it calls `runApp` in its own
/// zone), so its order is read from the source. `faults_test` re-registers
/// the level generator in the `beforeRunApp` seam; anything started before
/// the seam that holds the `LevelResolver` keeps the real generator, and
/// the fault never shows (D314: the widget's bridge did).
void main() {
  test('the widget bridge starts after the test seam', () {
    final source = File('lib/bootstrap.dart').readAsStringSync();
    final seam = source.indexOf('await beforeRunApp?.call();');
    final bridge = source.indexOf('get<HomeWidgetBridge>().start();');
    expect(seam, isNonNegative);
    expect(bridge, isNonNegative);
    expect(bridge, greaterThan(seam));
  });
}
