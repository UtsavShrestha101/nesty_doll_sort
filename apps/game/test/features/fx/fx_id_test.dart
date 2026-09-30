import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/fx/fx_id.dart';

import 'support/design_lottie.dart';

void main() {
  test('one FxId per design/lottie file: 35 since m7-3', () {
    expect(FxId.values, hasLength(35));
    expect(
      FxId.values.map((id) => id.fileName).toList()..sort(),
      designLottieNames(),
    );
  });

  test('file names are unique and map back to their id', () {
    for (final id in FxId.values) {
      expect(FxId.fromFileName(id.fileName), id);
    }
    expect(FxId.fromFileName('doll_dance'), isNull);
  });

  test('assets ship under assets/lottie/', () {
    expect(FxId.dollPick.assetPath, 'assets/lottie/doll_pick.json');
    for (final id in FxId.values) {
      expect(id.assetPath, startsWith('${FxId.assetDirectory}/'));
    }
  });

  test('board clips are the doll, glow, glass (both cases), ice, dust, '
      'sparkle, hint and extra-slot files; everything else is a widget', () {
    final board = FxId.values.where((id) => id.host == FxHost.board).toSet();
    expect(board, {
      FxId.dollPick,
      FxId.dollMove,
      FxId.dollNest,
      FxId.dollSwallow,
      FxId.dollComplete,
      FxId.dollInvalid,
      FxId.dollReveal,
      FxId.fxSelectGlow,
      FxId.fxGlassUnlock,
      FxId.fxGlassUnlockTall,
      FxId.fxIce,
      FxId.fxDustPuff,
      FxId.fxSparkle,
      FxId.uiHintArrow,
      FxId.uiExtraSlot,
    });
  });
}
