import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/repository/bundled_catalog_repository.dart';
import 'package:nesty_game/core/repository/fake_catalog_repository.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/repository/fake_level_resolver.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/museum/cubit/museum_cubit.dart';
import 'package:nesty_game/features/museum/pages/museum_page.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/support/screen_harness.dart';
import '../helpers/level_fixtures.dart';

/// M7 overflow suite (m7-design §18 "overflow"): the Museum (frames
/// 6.1-6.3) and its 6.2/6.3 modals at the five acceptance sizes and both
/// text scales. Behaviour is covered by `test/features/museum/
/// museum_page_test.dart`, whose comment explains why no test here closes
/// the cubit (the real figurine PNG decode).
void main() {
  setUpAll(loadBundledFonts);

  final catalog = FakeCatalogRepository();

  MuseumCubit build() {
    final level = levelFrom(tutorialLevelJson);
    final entries = [
      for (var order = 1; order <= 36; order++) entryFor(level, order: order),
    ];
    final levels = FakeLevelRepository(entries: entries);
    final save = FakeSaveService(
      initial: const SaveDocument(
        coins: 1234567,
        currentLevel: 36,
        museum: ['ch01'],
      ),
    );
    final resolver = FakeLevelResolver(levels, save, FakeRemoteConfigService());
    return MuseumCubit(save, catalog, resolver);
  }

  Future<void> precacheFigurines(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    final context = tester.element(find.byType(SizedBox));
    await tester.runAsync(() async {
      for (var n = 1; n <= BundledCatalogRepository.figurineIds.length; n++) {
        final id = BundledCatalogRepository.figurineIds[n - 1];
        await precacheImage(
          AssetImage(BundledCatalogRepository.figurineArt(n, id)),
          context,
        );
        await precacheImage(
          AssetImage(BundledCatalogRepository.figurineArt(n, id, locked: true)),
          context,
        );
      }
    });
  }

  Future<void> pumpMuseum(
    WidgetTester tester,
    MuseumCubit cubit, {
    Size size = const Size(390, 844),
    double textScale = 1,
  }) async {
    await precacheFigurines(tester);
    await pumpScreen(
      tester,
      BlocProvider<MuseumCubit>.value(value: cubit, child: const MuseumPage()),
      size: size,
      textScale: textScale,
      // The collected niches bob forever: `pumpAndSettle` would wait on it.
      reduceMotion: true,
    );
    await cubit.load();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  for (final size in overflowScreenSizes) {
    for (final textScale in textScales) {
      testWidgets('no overflow at ${size.width.toInt()}x${size.height.toInt()} '
          '${textScale}x, the cabinet and the 6.2/6.3 modals', (tester) async {
        final cubit = build();
        await pumpMuseum(tester, cubit, size: size, textScale: textScale);
        await expectAccessibleLayout(tester);

        await tapAndSettle(tester, find.text(testL10n.figurineName('classic')));
        await expectAccessibleLayout(tester);
        await tapAndSettle(tester, find.byIcon(NestyIcons.close));

        await tapAndSettle(tester, find.text(testL10n.museumNextChip(5)));
        await expectAccessibleLayout(tester);
      });
    }
  }

  // 6.1b (nothing collected) and 6.1c (every family home) at every size.
  for (final size in overflowScreenSizes) {
    for (final textScale in textScales) {
      for (final (name, document) in [
        ('nothing collected (6.1b)', const SaveDocument(currentLevel: 2)),
        (
          'every family home (6.1c)',
          SaveDocument(
            currentLevel: 200,
            museum: [
              for (var n = 1; n <= 10; n++) 'ch${n.toString().padLeft(2, '0')}',
            ],
          ),
        ),
      ]) {
        testWidgets('$name fits ${size.width.toInt()}x${size.height.toInt()} '
            '${textScale}x', (tester) async {
          final level = levelFrom(tutorialLevelJson);
          final levels = FakeLevelRepository(
            entries: [
              for (var order = 1; order <= 36; order++)
                entryFor(level, order: order),
            ],
          );
          final save = FakeSaveService(initial: document);
          final cubit = MuseumCubit(
            save,
            catalog,
            FakeLevelResolver(levels, save, FakeRemoteConfigService()),
          );
          await pumpMuseum(tester, cubit, size: size, textScale: textScale);
          await expectAccessibleLayout(tester);
        });
      }
    }
  }
}
