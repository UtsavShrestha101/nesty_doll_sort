import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

import '../../features/support/screen_harness.dart';
import 'support/ui_harness.dart';

/// The m7-3 Settings rows (frames 10.2e and 10.2f; ui-spec-menus §7):
/// [SettingsSegmentedRow], [SettingsPillButton], and the icon-tile rows.
void main() {
  setUpAll(loadBundledFonts);

  Widget segmented({
    required String selected,
    required ValueChanged<String> onChanged,
  }) => SettingsSection(
    tiled: true,
    children: [
      SettingsSegmentedRow<String>(
        icon: NestyIcons.bolt,
        label: 'Reduce motion',
        tile: SettingsTile.motion,
        selected: selected,
        onChanged: onChanged,
        segments: const [
          SettingsSegment(value: 'off', label: 'Off'),
          SettingsSegment(value: 'on', label: 'On'),
          SettingsSegment(value: 'system', label: 'System'),
        ],
      ),
    ],
  );

  group('SettingsSegmentedRow', () {
    testWidgets('a tap on another segment reports its value; the chosen one '
        'reports nothing', (tester) async {
      final chosen = <String>[];
      await pumpScreen(
        tester,
        Material(
          child: segmented(selected: 'system', onChanged: chosen.add),
        ),
      );
      await tester.tap(find.text('System'));
      await tester.tap(find.text('On'));
      await tester.tap(find.text('Off'));
      expect(chosen, ['on', 'off']);
    });

    testWidgets('every segment is at least 48 dp to touch, and the group '
        'is one named radio group with its value', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(
        tester,
        Material(
          child: segmented(selected: 'on', onChanged: (_) {}),
        ),
        textScale: 1.3,
      );
      for (final label in ['Off', 'On', 'System']) {
        final rect = tester.getRect(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(GestureDetector),
          ),
        );
        expect(rect.height, greaterThanOrEqualTo(48), reason: label);
      }
      final group = tester.getSemantics(find.bySemanticsLabel('Reduce motion'));
      expect(group.getSemanticsData().value, 'On');
      handle.dispose();
    });

    double thumbX(WidgetTester tester) => tester
        .getTopLeft(
          find
              .descendant(
                of: find.byType(SettingsSegmentedRow<String>),
                matching: find.byType(NestySurface),
              )
              .last,
        )
        .dx;

    Future<void> pumpStateful(WidgetTester tester, {required bool reduced}) {
      var selected = 'off';
      return pumpScreen(
        tester,
        Material(
          child: StatefulBuilder(
            builder: (context, setState) => segmented(
              selected: selected,
              onChanged: (v) => setState(() => selected = v),
            ),
          ),
        ),
        reduceMotion: reduced,
      );
    }

    testWidgets('the thumb glides over 180 ms to the chosen segment', (
      tester,
    ) async {
      await pumpStateful(tester, reduced: false);
      final start = thumbX(tester);
      await tester.tap(find.text('System'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      final mid = thumbX(tester);
      await tester.pump(const Duration(milliseconds: 400));
      final end = thumbX(tester);
      expect(mid, greaterThan(start));
      expect(mid, lessThan(end));
    });

    testWidgets('under reduced motion the thumb snaps', (tester) async {
      await pumpStateful(tester, reduced: true);
      final start = thumbX(tester);
      await tester.tap(find.text('System'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      final soon = thumbX(tester);
      await tester.pump(const Duration(milliseconds: 400));
      expect(soon, greaterThan(start));
      expect(soon, thumbX(tester));
    });
  });

  group('SettingsPillButton', () {
    testWidgets('a 44 dp pill with a 48 dp touch area, labelled', (
      tester,
    ) async {
      var taps = 0;
      await pumpScreen(
        tester,
        Material(
          child: Center(
            child: SettingsPillButton(
              icon: NestyIcons.openInNew,
              label: 'Open phone settings',
              onPressed: () => taps++,
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Open phone settings'), findsOneWidget);
      final rect = tester.getRect(find.byType(SettingsPillButton));
      expect(rect.height, greaterThanOrEqualTo(48));
      await tester.tap(find.text('Open phone settings'));
      expect(taps, 1);
    });
  });

  group('SettingsToggleRow with a footer', () {
    testWidgets('the footer sits under the text, on its column', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        Material(
          child: SettingsSection(
            tiled: true,
            children: [
              SettingsToggleRow(
                icon: NestyIcons.notificationsOff,
                label: 'Daily reminder',
                tile: SettingsTile.reminderOff,
                value: false,
                onChanged: (_) {},
                subtitle: 'Off in your phone’s settings',
                footer: SettingsPillButton(
                  icon: NestyIcons.openInNew,
                  label: 'Open phone settings',
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      );
      final title = tester.getTopLeft(find.text('Daily reminder'));
      final pill = tester.getTopLeft(find.byType(SettingsPillButton));
      expect(pill.dx, title.dx);
      expect(pill.dy, greaterThan(title.dy));
    });
  });

  group('phase 5 type and divider (F-SET, NestyHub:153-157)', () {
    testWidgets('title Fredoka 600 17/1.15, sub Nunito 700 12/1.3, value '
        'Nunito 700 15, and a 1.5 dp settingsDivider between rows', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        Material(
          child: SettingsSection(
            tiled: true,
            children: [
              SettingsToggleRow(
                icon: NestyIcons.bolt,
                label: 'Relaxed mode',
                subtitle: 'Unlimited free undo',
                tile: SettingsTile.motion,
                value: false,
                onChanged: (_) {},
              ),
              SettingsRow(
                icon: NestyIcons.bolt,
                label: 'Language',
                value: 'English',
                tile: SettingsTile.motion,
                onTap: () {},
              ),
            ],
          ),
        ),
      );
      TextStyle styleOf(String text) =>
          tester.widget<Text>(find.text(text)).style!;
      final title = styleOf('Relaxed mode');
      expect(title.fontSize, 17);
      expect(title.fontWeight, FontWeight.w600);
      expect(title.height, 1.15);
      expect(title.fontFamily, contains('Fredoka'));
      final sub = styleOf('Unlimited free undo');
      expect(sub.fontSize, 12);
      expect(sub.height, 1.3);
      expect(sub.fontWeight, FontWeight.w700);
      final value = styleOf('English');
      expect(value.fontSize, 15);
      expect(value.fontWeight, FontWeight.w700);
      final divider = tester.widgetList<ColoredBox>(
        find.byWidgetPredicate(
          (w) => w is ColoredBox && w.color == AppColorTokens.divider,
        ),
      );
      expect(divider, hasLength(1));
      final box = find.ancestor(
        of: find.byWidgetPredicate(
          (w) => w is ColoredBox && w.color == AppColorTokens.divider,
        ),
        matching: find.byType(SizedBox),
      );
      expect(tester.getSize(box.first).height, 1.5);
    });
  });
}
