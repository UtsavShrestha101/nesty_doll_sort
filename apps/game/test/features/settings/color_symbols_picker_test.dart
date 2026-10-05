import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/models/symbols_mode.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/settings/widgets/color_symbols_picker.dart';
import 'package:nesty_game/features/shop/widgets/skin_doll_row.dart';
import 'package:nesty_render/nesty_render.dart' show DollSymbols;

import '../../core/ui/support/ui_harness.dart';
import '../support/controlled_skin_service.dart';
import '../support/screen_harness.dart';

/// Frame 8.1's "Color symbols" (NestyMenus `isSettings`; FIDELITY-8): the
/// visibility icon on the row, then two cards, each a Leaf doll preview in
/// the skin's art (Large with its cream disc and ink ring), the selected
/// one `#FFF1E4` with a 3 px primary inset ring and a primary-edge label.
void main() {
  setUpAll(loadBundledFonts);

  Future<List<SymbolsMode>> pumpPicker(
    WidgetTester tester,
    SkinService skins, {
    SymbolsMode mode = SymbolsMode.subtle,
    double textScale = 1,
    Size size = const Size(390, 844),
  }) async {
    final changes = <SymbolsMode>[];
    await pumpScreen(
      tester,
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<SkinService>.value(value: skins),
          RepositoryProvider<FxLibrary>.value(value: FakeFxLibrary()),
        ],
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SettingsSection(
              padding: ColorSymbolsPicker.sectionPadding,
              children: [
                ColorSymbolsPicker(mode: mode, onChanged: changes.add),
              ],
            ),
          ),
        ),
      ),
      textScale: textScale,
      size: size,
    );
    return changes;
  }

  Finder card(String label) =>
      find.ancestor(of: find.text(label), matching: find.byType(NestySurface));

  SurfaceStyle styleOf(WidgetTester tester, String label) =>
      tester.widget<NestySurface>(card(label).first).style;

  testWidgets('the row: the visibility icon and "Color symbols"', (
    tester,
  ) async {
    await pumpPicker(tester, ControlledSkinService());
    expect(find.byIcon(NestyIcons.visibility), findsOneWidget);
    expect(find.text('Color symbols'), findsOneWidget);
  });

  testWidgets('each card previews a Leaf doll in its own symbols, prepared '
      'in the skin’s art', (tester) async {
    final skins = ControlledSkinService();
    await pumpPicker(tester, skins);
    expect(skins.showcaseRequests, hasLength(2));
    for (final request in skins.showcaseRequests) {
      expect(request.colors, [DollColor.green]);
    }
    expect(skins.showcaseRequests.map((r) => r.symbols), [
      DollSymbols.subtle,
      DollSymbols.large,
    ]);
    final subtle = skins.completeShowcase(0);
    final large = skins.completeShowcase(1);
    await tester.pump();

    final rows = tester
        .widgetList<SkinDollRow>(find.byType(SkinDollRow))
        .toList();
    expect(rows, hasLength(2));
    expect(rows[0].skin, same(subtle));
    expect(rows[0].symbols, DollSymbols.subtle);
    expect(rows[1].skin, same(large));
    expect(rows[1].symbols, DollSymbols.large);
    expect(rows.every((r) => r.colors.single == DollColor.green), isTrue);
    // F.3: the preview doll is 56 dp tall (2:3).
    final size = tester.getSize(find.byType(SkinDollRow).first);
    expect(size.height, 56);
    expect(size.width, closeTo(56 * 2 / 3, 0.01));
  });

  testWidgets('a skin that can’t be prepared previews the placeholder', (
    tester,
  ) async {
    final skins = ControlledSkinService();
    await pumpPicker(tester, skins);
    skins
      ..failShowcase(0)
      ..failShowcase(1);
    await tester.pump();
    final rows = tester.widgetList<SkinDollRow>(find.byType(SkinDollRow));
    expect(rows, hasLength(2));
    expect(rows.every((r) => r.skin == null), isTrue);
  });

  testWidgets('the selected card is #FFF1E4 with a 3 px orange ring; the '
      'other #FFFDF7 with a 2 px tan one (tokens settings.colorSymbolCards)', (
    tester,
  ) async {
    await pumpPicker(tester, ControlledSkinService());
    final selected = styleOf(tester, 'Subtle');
    expect(selected.color, const Color(0xFFFFF1E4));
    expect(selected.shadows, const [
      NestyShadow(color: Color(0xFFF2893B), inset: true, spread: 3),
    ]);
    final other = styleOf(tester, 'Large');
    expect(other.color, const Color(0xFFFFFDF7));
    expect(other.shadows, const [
      NestyShadow(color: Color(0xFFE2C9A3), inset: true, spread: 2),
    ]);
    expect(
      tester.widget<Text>(find.text('Subtle')).style?.color,
      AppColorTokens.primaryEdge,
    );
    expect(
      tester.widget<Text>(find.text('Large')).style?.color,
      AppColorTokens.textPrimary,
    );
  });

  testWidgets('tapping the other card asks for its mode; the selected one '
      'is a no-op; the selection is announced', (tester) async {
    final handle = tester.ensureSemantics();
    final changes = await pumpPicker(tester, ControlledSkinService());
    expect(
      tester.getSemantics(find.bySemanticsLabel('Subtle')),
      isSemantics(
        label: 'Subtle',
        isButton: true,
        isSelected: true,
        isInMutuallyExclusiveGroup: true,
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Large')),
      isSemantics(label: 'Large', isButton: true, isSelected: false),
    );

    await tester.tap(find.text('Subtle'));
    expect(changes, isEmpty);
    await tester.tap(find.text('Large'));
    expect(changes, [SymbolsMode.large]);
    handle.dispose();
  });

  testWidgets('Large selected: its card wears the ring', (tester) async {
    await pumpPicker(tester, ControlledSkinService(), mode: SymbolsMode.large);
    expect(
      styleOf(tester, 'Large').color,
      AppColorTokens.symbolsCardSelectedFace,
    );
    expect(styleOf(tester, 'Subtle').color, AppColorTokens.surfaceWhite);
  });

  testWidgets('the cards are real tap targets (≥ 48 dp)', (tester) async {
    await pumpPicker(tester, ControlledSkinService());
    for (final label in ['Subtle', 'Large']) {
      final size = tester.getSize(card(label).first);
      expect(size.height, greaterThanOrEqualTo(48));
      expect(size.width, greaterThanOrEqualTo(48));
    }
  });

  for (final size in screenSizes) {
    testWidgets('fits ${size.width.toInt()} wide at 1.3× text', (tester) async {
      await pumpPicker(
        tester,
        ControlledSkinService(),
        textScale: 1.3,
        size: size,
      );
      expectNoLayoutErrors(tester);
    });
  }
}
