import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/models/symbols_mode.dart';
import 'package:nesty_game/core/services/database/settings_schema.dart';
import 'package:nesty_render/nesty_render.dart';

void main() {
  test('persists subtle and large under their spec tokens (D19, Q4)', () {
    expect(SymbolsMode.subtle.storageValue, 'subtle');
    expect(SymbolsMode.large.storageValue, 'large');
    for (final mode in SymbolsMode.values) {
      for (final fallback in SymbolsMode.values) {
        expect(
          SymbolsMode.fromStorage(mode.storageValue, fallback: fallback),
          mode,
        );
      }
    }
  });

  test('reads the legacy "assist" as large, but never writes it', () {
    expect(
      SymbolsMode.fromStorage('assist', fallback: SymbolsMode.subtle),
      SymbolsMode.large,
    );
    expect(
      SymbolsMode.values.map((mode) => mode.storageValue),
      isNot(contains('assist')),
    );
  });

  test('unknown, missing or mistyped values fall back to the fallback', () {
    for (final value in <Object?>[null, '', 'LARGE', 'from-the-future', 3]) {
      for (final fallback in SymbolsMode.values) {
        expect(
          SymbolsMode.fromStorage(value, fallback: fallback),
          fallback,
          reason: '$value',
        );
      }
    }
  });

  test('a fresh install draws large symbols (owner, PROGRESS D91)', () {
    expect(SettingsDefaults.symbols, SymbolsMode.large);
  });

  test('maps onto the renderer modes', () {
    expect(SymbolsMode.subtle.dollSymbols, DollSymbols.subtle);
    expect(SymbolsMode.large.dollSymbols, DollSymbols.large);
  });
}
