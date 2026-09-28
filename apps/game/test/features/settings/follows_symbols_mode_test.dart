import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/models/symbols_mode.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/features/settings/widgets/follows_symbols_mode.dart';
import 'package:nesty_render/nesty_render.dart' show DollSymbols;

/// `SymbolsModeBuilder` (Home's shelf, D91): it builds with the stored
/// Color symbols mode and rebuilds on each change made elsewhere.
void main() {
  late FakeDatabaseService database;
  late List<DollSymbols> built;

  setUp(() {
    database = FakeDatabaseService();
    built = [];
  });

  Widget builder() => RepositoryProvider<DatabaseService>.value(
    value: database,
    child: SymbolsModeBuilder(
      builder: (context, symbols) {
        built.add(symbols);
        return const SizedBox();
      },
    ),
  );

  testWidgets('builds with the stored mode, then follows each change', (
    tester,
  ) async {
    await tester.pumpWidget(builder());
    expect(built, [DollSymbols.large]);

    await database.setSymbolsMode(SymbolsMode.subtle);
    await tester.pump();
    expect(built.last, DollSymbols.subtle);

    await database.setSymbolsMode(SymbolsMode.large);
    await tester.pump();
    expect(built.last, DollSymbols.large);
  });

  testWidgets('stops listening once disposed', (tester) async {
    await tester.pumpWidget(builder());
    await tester.pumpWidget(const SizedBox());
    final count = built.length;

    await database.setSymbolsMode(SymbolsMode.subtle);
    await tester.pump();
    expect(built, hasLength(count));
    expect(tester.takeException(), isNull);
  });
}
