import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/gameplay/overlays/out_of_moves_sheet.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../support/screen_harness.dart';

void main() {
  setUpAll(loadBundledFonts);

  Widget sheet({
    int freeUndosLeft = 1,
    bool showFreeUndos = true,
    VoidCallback? onUndo,
    VoidCallback? onExtraSlot,
    VoidCallback? onRestart,
    VoidCallback? onDismiss,
    int undoPrice = 20,
    int slotPrice = 150,
    int extraSlotsLeft = 0,
    bool unlimitedBoosters = false,
    bool relaxed = false,
  }) => OutOfMovesSheet(
    freeUndosLeft: freeUndosLeft,
    showFreeUndos: showFreeUndos,
    onUndo: onUndo,
    onExtraSlot: onExtraSlot,
    onRestart: onRestart ?? () {},
    onDismiss: onDismiss ?? () {},
    undoPrice: undoPrice,
    slotPrice: slotPrice,
    extraSlotsLeft: extraSlotsLeft,
    unlimitedBoosters: unlimitedBoosters,
    relaxed: relaxed,
  );

  testWidgets('frame 3.5: title, Undo (free · 1 left), +1 Slot, Restart', (
    tester,
  ) async {
    await pumpScreen(tester, sheet(onUndo: () {}, onExtraSlot: () {}));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('No moves left!'), findsOneWidget);
    expect(find.text('Pick a way to keep sorting.'), findsOneWidget);
    expect(find.text('Free · 1 left'), findsOneWidget);
    expect(find.text('+1 Slot'), findsOneWidget);
    expect(find.text('Start this level fresh, for free'), findsOneWidget);
    expect(find.byType(SheetRow), findsNWidgets(3));
  });

  testWidgets('+1 Slot is hidden once the level has its two (D22)', (
    tester,
  ) async {
    await pumpScreen(tester, sheet(onUndo: () {}));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('+1 Slot'), findsNothing);
    expect(find.byType(SheetRow), findsNWidgets(2));
  });

  testWidgets('no count tag in the dev flavor or with none left', (
    tester,
  ) async {
    await pumpScreen(tester, sheet(showFreeUndos: false, onUndo: () {}));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(SheetRowTag), findsNothing);
    await pumpScreen(tester, sheet(freeUndosLeft: 0));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(SheetRowTag), findsNothing);
  });

  testWidgets('each row and the scrim call back', (tester) async {
    final calls = <String>[];
    await pumpScreen(
      tester,
      sheet(
        onUndo: () => calls.add('undo'),
        onExtraSlot: () => calls.add('slot'),
        onRestart: () => calls.add('restart'),
        onDismiss: () => calls.add('dismiss'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Take back your last move'));
    await tester.tap(find.text('Add a stand for this level'));
    await tester.tap(find.text('Start this level fresh, for free'));
    await tester.tapAt(const Offset(195, 80));
    await tester.pump(const Duration(milliseconds: 200));
    expect(calls, ['undo', 'slot', 'restart', 'dismiss']);
  });

  group('coin prices (m3-design §7.3, §10.8)', () {
    testWidgets('the Undo row shows its price once the free ones are used', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        sheet(freeUndosLeft: 0, onUndo: () {}, undoPrice: 20),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Free · 1 left'), findsNothing);
      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('+1 Slot shows its price once none are held', (tester) async {
      await pumpScreen(
        tester,
        sheet(onUndo: () {}, onExtraSlot: () {}, slotPrice: 150),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('150'), findsOneWidget);
    });

    testWidgets('+1 Slot keeps its chevron while some are still held', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        sheet(
          onUndo: () {},
          onExtraSlot: () {},
          slotPrice: 150,
          extraSlotsLeft: 1,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('150'), findsNothing);
    });

    testWidgets(
      'relaxed mode: "Free, as often as you like", no count and no price (E6; '
      'm7-design §10, §15.6)',
      (tester) async {
        await pumpScreen(
          tester,
          sheet(
            onUndo: () {},
            onExtraSlot: () {},
            freeUndosLeft: 0,
            undoPrice: 20,
            relaxed: true,
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Free, as often as you like'), findsOneWidget);
        expect(find.text('Free · 1 left'), findsNothing);
        expect(find.text('20'), findsNothing);
      },
    );

    testWidgets('relaxed (frame 10.9b): a green ring round the row, the '
        'all_inclusive glyph and "Free", never a price or a chevron', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        sheet(onUndo: () {}, freeUndosLeft: 0, undoPrice: 20, relaxed: true),
      );
      await tester.pump(const Duration(milliseconds: 300));
      final undoRow = tester.widget<SheetRow>(find.byType(SheetRow).first);
      expect(undoRow.highlighted, isTrue);
      expect(find.byIcon(IconUses.undoUnlimited), findsOneWidget);
      expect(find.text('Free'), findsOneWidget);
      expect(find.byType(CoinIcon), findsNothing);
    });

    testWidgets('the undos spent (frame 12.8): "Your 2 free undos are '
        'used", the price chip, no ring', (tester) async {
      await pumpScreen(
        tester,
        sheet(
          onUndo: () {},
          freeUndosLeft: 0,
          undoPrice: 20,
          slotPrice: 150,
          onExtraSlot: () {},
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Your 2 free undos are used'), findsOneWidget);
      expect(find.text('Take back your last move'), findsNothing);
      expect(find.text('20'), findsOneWidget);
      expect(
        tester.widget<SheetRow>(find.byType(SheetRow).first).highlighted,
        isFalse,
      );
    });

    testWidgets('the spent line follows the free-undo count it is given', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        OutOfMovesSheet(
          freeUndosLeft: 0,
          freeUndosTotal: 1,
          showFreeUndos: true,
          onUndo: () {},
          onExtraSlot: null,
          onRestart: () {},
          onDismiss: () {},
          undoPrice: 20,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Your 1 free undo is used'), findsOneWidget);
    });

    testWidgets('the dev flavor never shows a coin price', (tester) async {
      await pumpScreen(
        tester,
        sheet(
          freeUndosLeft: 0,
          onUndo: () {},
          onExtraSlot: () {},
          unlimitedBoosters: true,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('20'), findsNothing);
      expect(find.text('150'), findsNothing);
      // Restart's chevron and the unlimited +1 Slot row's are the same
      // const widget.
      expect(find.byWidget(SheetRow.chevron), findsNWidgets(2));
    });
  });

  for (final size in screenSizes) {
    for (final scale in textScales) {
      testWidgets('fits ${size.width.toInt()} wide at $scale× text', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          sheet(onUndo: () {}, onExtraSlot: () {}),
          size: size,
          textScale: scale,
        );
        await tester.pump(const Duration(milliseconds: 300));
        expectNoLayoutErrors(tester);
        final sheetRect = tester.getRect(find.byType(NestySheet));
        expect(sheetRect.bottom, size.height);
        expect(sheetRect.width, size.width);
      });
    }
  }
}
