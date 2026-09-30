import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/share/fake_share_service.dart';
import 'package:nesty_game/core/services/share/share_service.dart';

void main() {
  test('records every text and origin, in order, and answers shared by '
      'default', () async {
    final service = FakeShareService();

    final first = await service.shareText('one');
    final second = await service.shareText(
      'two',
      origin: const Rect.fromLTWH(1, 2, 3, 4),
    );

    expect(first, ShareOutcome.shared);
    expect(second, ShareOutcome.shared);
    expect(service.shared, ['one', 'two']);
    expect(service.origins, [null, const Rect.fromLTWH(1, 2, 3, 4)]);
  });

  test('next lets a test script dismissed or unavailable', () async {
    final service = FakeShareService()..next = ShareOutcome.dismissed;
    expect(await service.shareText('hi'), ShareOutcome.dismissed);

    service.next = ShareOutcome.unavailable;
    expect(await service.shareText('hi'), ShareOutcome.unavailable);
  });
}
