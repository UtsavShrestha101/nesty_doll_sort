import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

/// A sheet whose rows scroll must clip them: the dev level picker's 200
/// tiles, scrolled, painted over its title and Home (owner's review,
/// 2026-09-28). Layout stays in bounds either way, so only the pixels show
/// the bug; this test reads them.
void main() {
  const rowColor = Color(0xFFFF0000);
  final boundaryKey = GlobalKey();

  Future<void> pumpSheet(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.bottomCenter,
          child: RepaintBoundary(
            key: boundaryKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 420),
              child: NestySheet(
                title: 'Jump to a level',
                children: [
                  for (var i = 0; i < 40; i++)
                    const SizedBox(
                      height: 48,
                      child: ColoredBox(color: rowColor),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The colours at [points] (global), from one capture of the sheet.
  Future<List<Color>> pixelsAt(WidgetTester tester, List<Offset> points) async {
    final boundary =
        boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    final captured = await tester.runAsync(() async {
      final image = await boundary.toImage();
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final width = image.width;
      image.dispose();
      return (data!, width);
    });
    final (ByteData data, int width) = captured!;
    return [
      for (final point in points)
        () {
          final local = boundary.globalToLocal(point);
          final offset = (local.dy.round() * width + local.dx.round()) * 4;
          return Color.fromARGB(
            data.getUint8(offset + 3),
            data.getUint8(offset),
            data.getUint8(offset + 1),
            data.getUint8(offset + 2),
          );
        }(),
    ];
  }

  bool isRow(Color c) =>
      (c.r * 255).round() > 200 &&
      (c.g * 255).round() < 60 &&
      (c.b * 255).round() < 60;

  testWidgets('the scroll area clips', (tester) async {
    await pumpSheet(tester);
    final scroll = tester.widget<SingleChildScrollView>(
      find.descendant(
        of: find.byType(NestySheet),
        matching: find.byType(SingleChildScrollView),
      ),
    );
    expect(scroll.clipBehavior, isNot(Clip.none));
  });

  testWidgets('rows scrolled up never paint over the title', (tester) async {
    await pumpSheet(tester);
    final scrollArea = find.descendant(
      of: find.byType(NestySheet),
      matching: find.byType(SingleChildScrollView),
    );
    final top = tester.getTopLeft(scrollArea).dy;
    final titleTop = tester.getTopLeft(find.text('Jump to a level')).dy;
    // Every pixel down the middle from the title to the scroll area: rows
    // are 48 px with 12 px gaps, so a single probe can land in a gap.
    final band = [for (var y = titleTop; y < top; y += 2) Offset(195, y)];
    Future<int> rowPixelsInBand() async =>
        (await pixelsAt(tester, band)).where(isRow).length;

    expect(await rowPixelsInBand(), 0, reason: 'unscrolled');

    await tester.drag(scrollArea, const Offset(0, -300));
    await tester.pump();
    expect(await rowPixelsInBand(), 0, reason: 'scrolled');
    // The rows are still drawn inside the scroll area.
    final inside = [for (var y = top; y < top + 60; y += 2) Offset(195, y)];
    expect((await pixelsAt(tester, inside)).where(isRow), isNotEmpty);
  });
}
