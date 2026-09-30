import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/records/cubit/records_cubit.dart';
import 'package:nesty_game/features/records/pages/records_page.dart';
import 'package:nesty_game/features/records/widgets/record_stat_cell.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../../helpers/level_fixtures.dart';

/// The Records screen (E8; docs/plans/m7-design.md §12, §15.2) over a real
/// [RecordsCubit] built from fakes: the lifetime records, "Computer" on
/// every race row, and the badge grid.
///
/// No test here calls `cubit.close()`. Like `MuseumCubit`, [RecordsCubit]
/// only holds a `SaveService.changes` subscription (no timer of its own), so
/// flutter_test's pending-timer check doesn't need it closed, and awaiting
/// `close()` inside `testWidgets` reproducibly hung this sandbox (CLAUDE.md
/// "Widget-test harness facts": `Bloc.close()` never completes in the
/// fake-async zone; use `tester.runAsync`, never await it here).
void main() {
  setUpAll(loadBundledFonts);

  final levels = FakeLevelRepository(
    entries: [
      for (var order = 1; order <= 10; order++) entryFor(level, order: order),
    ],
  );

  RecordsCubit build(SaveDocument document) =>
      RecordsCubit(FakeSaveService(initial: document), levels);

  Future<void> pumpRecords(WidgetTester tester, RecordsCubit cubit) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<RecordsCubit>.value(
          value: cubit,
          child: const RecordsPage(),
        ),
      ),
    );
    await cubit.load();
    await tester.pump();
  }

  testWidgets('the six stats, the races card with a Computer tag on every '
      'row, the best-moves link and the badge grid (frame 10.6)', (
    tester,
  ) async {
    final cubit = build(
      const SaveDocument(
        coins: 40,
        highestLevel: 6,
        records: SaveRecords(
          families: 14,
          dolls: 1284,
          dailies: 9,
          longestRun: 12,
          badges: ['first_family', 'glass_breaker'],
        ),
        race: RaceProgress(
          rivals: [
            RivalProgress(unlocked: true, wins: 3),
            RivalProgress(unlocked: true, wins: 1),
            RivalProgress(),
          ],
        ),
      ),
    );
    await pumpRecords(tester, cubit);

    expect(find.text('Records'), findsOneWidget);
    // No coin pill (frame 10.6): back and the title only.
    expect(find.text('40'), findsNothing);
    expect(find.text('5'), findsOneWidget); // levels won: highestLevel 6 - 1
    expect(find.text('Levels won'), findsOneWidget);
    // Every family completed (spec-prop §7.9), a plain count: never the
    // Museum's "of 10" (the device run read "2 of 10" after two wins, Q159).
    expect(find.text('14'), findsOneWidget);
    expect(find.text('Families completed'), findsOneWidget);
    expect(find.textContaining(' of 10'), findsNothing);
    expect(find.text('1,284'), findsOneWidget);
    expect(find.text('Dolls nested'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('Daily puzzles solved'), findsOneWidget);
    expect(find.text('12 days'), findsOneWidget);
    expect(find.text('Longest streak'), findsOneWidget);
    // Stars: no level in this fixture has a par, so nothing to earn yet.
    expect(find.text('0 of 0'), findsOneWidget);
    expect(find.text('Stars'), findsOneWidget);
    // "Levels with 3 stars" is not drawn in frame 10.6.
    expect(find.text('Levels with 3 stars'), findsNothing);

    // Races won: portrait, name, the Computer tag beside every name and the
    // wins on the right; a locked rival has a dash.
    expect(find.text('Races won'), findsOneWidget);
    expect(find.text('Pebble'), findsOneWidget);
    expect(find.text('Button'), findsOneWidget);
    expect(find.text('Comet'), findsOneWidget);
    expect(find.byType(ComputerTag), findsNWidgets(3));
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('–'), findsOneWidget);
    expect(find.byIcon(NestyIcons.bolt), findsNothing, reason: 'never bolt');

    expect(find.text('Best moves by level'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pump();

    expect(find.text('Badges'), findsOneWidget);
    expect(find.text('2/12'), findsOneWidget);
    expect(find.text('Snug as a Doll'), findsOneWidget);
    expect(find.text('Glass Act'), findsOneWidget);
  });

  testWidgets('the races card reads to a screen reader as "computer '
      'player", with the wins, and a locked rival says so', (tester) async {
    final handle = tester.ensureSemantics();
    final cubit = build(
      const SaveDocument(
        race: RaceProgress(
          rivals: [
            RivalProgress(unlocked: true, wins: 3),
            RivalProgress(unlocked: true),
            RivalProgress(),
          ],
        ),
      ),
    );
    await pumpRecords(tester, cubit);
    expect(
      find.bySemanticsLabel('Pebble, computer player, races won: 3'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Button, computer player, races won: 0'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Comet, computer player, not unlocked yet'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Levels won, 0'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('a rival with no wins shows an en dash, never a 0 or a loss', (
    tester,
  ) async {
    final cubit = build(const SaveDocument());
    await pumpRecords(tester, cubit);
    // Rival 1 is unlocked but unbeaten; 2 and 3 are locked.
    expect(find.text('–'), findsNWidgets(3));
  });

  testWidgets('the stats grid is two columns, cells in one row the same '
      'height', (tester) async {
    final cubit = build(const SaveDocument());
    await pumpRecords(tester, cubit);
    final cells = find.byType(RecordStatCell);
    expect(cells, findsNWidgets(6));
    final first = tester.getRect(cells.at(0));
    final second = tester.getRect(cells.at(1));
    expect(second.left, greaterThan(first.right));
    expect(second.top, first.top);
    expect(second.height, first.height);
    final third = tester.getRect(cells.at(2));
    expect(third.left, first.left);
    expect(third.top, greaterThan(first.bottom));
  });

  testWidgets('the best-moves link is wired to open Chapters', (tester) async {
    final cubit = build(const SaveDocument());
    await pumpRecords(tester, cubit);

    expect(find.text('Best moves by level'), findsOneWidget);
    // Not a real tap: `onTap` pushes `ChaptersRoute` on the root router and
    // this harness is a bare `MaterialApp` with no `AutoRouter` (the router
    // lane's tests cover the real push). A row that carries a callback and
    // the `route` glyph proves it is wired.
    final link = tester.widget<TactileSurface>(
      find
          .ancestor(
            of: find.text('Best moves by level'),
            matching: find.byType(TactileSurface),
          )
          .first,
    );
    expect(link.onPressed, isNotNull);
    expect(find.byIcon(IconUses.bestMoves), findsOneWidget);
  });
}

final level = levelFrom(tutorialLevelJson);
