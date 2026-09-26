import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/models/symbols_mode.dart';
import 'package:nesty_render/nesty_render.dart';

void main() {
  test('persists subtle and large under their spec tokens (D19, Q4)', () {
    expect(SymbolsMode.subtle.storageValue, 'subtle');
    expect(SymbolsMode.large.storageValue, 'large');
    for (final mode in SymbolsMode.values) {
      expect(SymbolsMode.fromStorage(mode.storageValue), mode);
    }
  });

  test('reads the legacy "assist" as large, but never writes it', () {
    expect(SymbolsMode.fromStorage('assist'), SymbolsMode.large);
    expect(
      SymbolsMode.values.map((mode) => mode.storageValue),
      isNot(contains('assist')),
    );
  });

  test('unknown, missing or mistyped values fall back to subtle', () {
    for (final value in <Object?>[null, '', 'LARGE', 'from-the-future', 3]) {
      expect(
        SymbolsMode.fromStorage(value),
        SymbolsMode.subtle,
        reason: '$value',
      );
    }
  });

  test('maps onto the renderer modes', () {
    expect(SymbolsMode.subtle.dollSymbols, DollSymbols.subtle);
    expect(SymbolsMode.large.dollSymbols, DollSymbols.large);
  });
}
