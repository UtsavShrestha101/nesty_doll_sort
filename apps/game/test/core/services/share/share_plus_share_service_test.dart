import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/share/share_plus_share_service.dart';
import 'package:nesty_game/core/services/share/share_service.dart';
import 'package:share_plus/share_plus.dart' show ShareResultStatus;

/// Under `flutter test` there is no `share_plus` platform channel
/// registered (the same reason `url_link_launcher_test.dart` never mocks
/// one), so every call here exercises the same silent-failure path a
/// device with no share sheet, or a plugin error, would hit: rule 3 says
/// that must never throw or surface anything, only answer
/// [ShareOutcome.unavailable].
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('maps every ShareResultStatus to its ShareOutcome', () {
    expect(outcomeOf(ShareResultStatus.success), ShareOutcome.shared);
    expect(outcomeOf(ShareResultStatus.dismissed), ShareOutcome.dismissed);
    expect(outcomeOf(ShareResultStatus.unavailable), ShareOutcome.unavailable);
  });

  test('never throws with no platform channel registered, answering '
      'unavailable', () async {
    final outcome = await SharePlusShareService().shareText(
      'Nesty Daily · Sep 26, 2026',
    );
    expect(outcome, ShareOutcome.unavailable);
  });

  test('an iPad/Mac popover origin never throws either', () async {
    final outcome = await SharePlusShareService().shareText(
      'hi',
      origin: const Rect.fromLTWH(1, 2, 3, 4),
    );
    expect(outcome, ShareOutcome.unavailable);
  });
}
