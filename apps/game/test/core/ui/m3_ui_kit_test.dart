import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

import 'support/ui_harness.dart';

/// docs/plans/m3-design.md §10.9, §14: the ui-kit-arb lane's components fit
/// at 360/390/430 dp and 1.3× text, give tactile feedback and use the
/// design's tokens (not literal geometry that happens to match a frame).
void main() {
  setUpAll(loadBundledFonts);

  group('fit', () {
    for (final width in [360.0, 390.0, 430.0]) {
      for (final textScale in [1.0, 1.3]) {
        testWidgets(
          'M3 components fit ${width.toInt()} dp at ${textScale}x text',
          (tester) async {
            await pumpUi(
              tester,
              const _Gallery(),
              width: width,
              height: 4200,
              textScale: textScale,
              feedback: RecordingFeedback(),
            );
            await tester.pump(const Duration(milliseconds: 300));
            expect(tester.takeException(), isNull);

            expect(find.text('Coins'), findsOneWidget);
            expect(find.text('Shop'), findsWidgets);
            expect(find.text('Daily Puzzle'), findsOneWidget);
            expect(find.text('Got it'), findsOneWidget);
            expect(find.text('Language'), findsOneWidget);
            _expectInside(tester, width);
          },
        );
      }
    }
  });

  group('tactile feedback', () {
    testWidgets('a segmented tab plays feedback and calls onChanged', (
      tester,
    ) async {
      final feedback = RecordingFeedback();
      var selected = 0;
      await pumpUi(
        tester,
        StatefulBuilder(
          builder: (context, setState) => NestySegmentedTabs(
            labels: const ['Coins', 'Skins', 'Themes', 'No Ads'],
            selectedIndex: selected,
            onChanged: (i) => setState(() => selected = i),
          ),
        ),
        feedback: feedback,
      );
      await tester.tap(find.text('Skins'));
      await tester.pumpAndSettle();
      expect(selected, 1);
      expect(feedback.activations, 1);

      // Tapping the already-selected tab is a no-op: no feedback, no call.
      await tester.tap(find.text('Skins'));
      await tester.pumpAndSettle();
      expect(selected, 1);
      expect(feedback.activations, 1);
    });

    testWidgets('a bottom nav item plays feedback and calls onChanged', (
      tester,
    ) async {
      final feedback = RecordingFeedback();
      var selected = 1;
      await pumpUi(
        tester,
        StatefulBuilder(
          builder: (context, setState) => NestyBottomNav(
            items: const [
              NestyBottomNavItem(icon: NestyIcons.storefront, label: 'Shop'),
              NestyBottomNavItem(icon: NestyIcons.home, label: 'Home'),
              NestyBottomNavItem(icon: NestyIcons.museum, label: 'Museum'),
            ],
            selectedIndex: selected,
            onChanged: (i) => setState(() => selected = i),
          ),
        ),
        feedback: feedback,
      );
      await tester.tap(find.text('Shop'));
      await tester.pumpAndSettle();
      expect(selected, 0);
      expect(feedback.activations, 1);

      await tester.tap(find.text('Shop'));
      await tester.pumpAndSettle();
      expect(feedback.activations, 1, reason: 'already selected: a no-op');
    });

    testWidgets('a HomeTile plays feedback and calls onTap', (tester) async {
      final feedback = RecordingFeedback();
      var taps = 0;
      await pumpUi(
        tester,
        HomeTile(
          leading: const Icon(NestyIcons.extension),
          label: 'Daily Puzzle',
          onTap: () => taps++,
        ),
        feedback: feedback,
      );
      await tester.tap(find.byType(HomeTile));
      await tester.pumpAndSettle();
      expect(taps, 1);
      expect(feedback.activations, 1);
    });

    testWidgets('a locked HomeTile ignores taps', (tester) async {
      final feedback = RecordingFeedback();
      var taps = 0;
      await pumpUi(
        tester,
        HomeTile(
          leading: const Icon(NestyIcons.extension),
          label: 'Daily Puzzle',
          onTap: () => taps++,
          locked: true,
        ),
        feedback: feedback,
      );
      await tester.tap(find.byType(HomeTile));
      await tester.pumpAndSettle();
      expect(taps, 0);
      expect(feedback.activations, 0);
    });

    testWidgets('an enabled SettingsRow plays feedback and calls onTap', (
      tester,
    ) async {
      final feedback = RecordingFeedback();
      var taps = 0;
      await pumpUi(
        tester,
        SettingsRow(
          icon: NestyIcons.translate,
          label: 'Language',
          value: 'English',
          onTap: () => taps++,
        ),
        feedback: feedback,
      );
      await tester.tap(find.byType(SettingsRow));
      await tester.pumpAndSettle();
      expect(taps, 1);
      expect(feedback.activations, 1);
    });

    testWidgets('a disabled SettingsRow (onTap null) ignores taps', (
      tester,
    ) async {
      final feedback = RecordingFeedback();
      await pumpUi(
        tester,
        const SettingsRow(
          icon: NestyIcons.restore,
          label: 'Restore Purchases',
          onTap: null,
        ),
        feedback: feedback,
      );
      await tester.tap(find.byType(SettingsRow));
      await tester.pumpAndSettle();
      expect(feedback.activations, 0);
    });

    testWidgets('a SettingsToggleRow flips its value', (tester) async {
      final feedback = RecordingFeedback();
      var value = false;
      await pumpUi(
        tester,
        StatefulBuilder(
          builder: (context, setState) => SettingsToggleRow(
            icon: NestyIcons.volumeUp,
            label: 'Sound',
            value: value,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
        feedback: feedback,
      );
      await tester.tap(find.byType(NestyToggle));
      await tester.pumpAndSettle();
      expect(value, isTrue);
      expect(feedback.activations, 1);
    });

    testWidgets('a NestyToast shown by show() fades in then dismisses', (
      tester,
    ) async {
      await pumpUi(tester, Builder(builder: (context) => const SizedBox()));
      final context = tester.element(find.byType(SizedBox));
      NestyToast.show(
        context,
        tone: NestyBannerTone.success,
        icon: NestyIcons.restore,
        title: 'Purchases restored',
        message: 'Remove Ads is active on this device.',
        duration: const Duration(milliseconds: 50),
      );
      await tester.pump();
      // The post-frame callback fires, then the fade-in animates.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: UiMotionTokens.modalInMs));
      expect(find.text('Purchases restored'), findsOneWidget);
      // Past the 50 ms show duration: the fade-out starts, then completes,
      // and onEnd removes the overlay entry.
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump(const Duration(milliseconds: UiMotionTokens.modalInMs));
      await tester.pump();
      expect(find.text('Purchases restored'), findsNothing);
    });

    // The dismiss timer belongs to the toast: a tree torn down before it
    // fires (a win overlay closing over its badge toasts, a screen popped
    // while "Freeze used" shows) must cancel it. Without that, flutter_test
    // fails this test with "A Timer is still pending even after the widget
    // tree was disposed", and at runtime a dead timer outlives its toast.
    testWidgets('a NestyToast torn down before it dismisses leaves no timer '
        'behind', (tester) async {
      await pumpUi(tester, Builder(builder: (context) => const SizedBox()));
      final context = tester.element(find.byType(SizedBox));
      NestyToast.show(
        context,
        tone: NestyBannerTone.success,
        icon: NestyIcons.star,
        title: 'Badge earned!',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: UiMotionTokens.modalInMs));
      expect(find.text('Badge earned!'), findsOneWidget);

      // Well inside the default 3 s: the whole tree, overlay and toast
      // included, goes away.
      await tester.pumpWidget(const SizedBox());
      expect(find.text('Badge earned!'), findsNothing);
    });

    // The toast is an entry in the navigator's Overlay, outside every
    // page's Material, so its text inherits MaterialApp's fallback style
    // unless the toast sets its own: the device run (device3, M7 phase 3)
    // showed "Badge earned!" and "First Family" with that style's yellow
    // double underline on every win that earns a badge.
    testWidgets('a NestyToast shown by show() over a page draws its text '
        "without MaterialApp's fallback underline", (tester) async {
      await pumpUi(tester, Builder(builder: (context) => const SizedBox()));
      final context = tester.element(find.byType(SizedBox));
      NestyToast.show(
        context,
        tone: NestyBannerTone.success,
        icon: NestyIcons.star,
        title: 'Badge earned!',
        message: 'First Family',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: UiMotionTokens.modalInMs));
      for (final text in ['Badge earned!', 'First Family']) {
        final rich = tester.widget<RichText>(
          find.descendant(of: find.text(text), matching: find.byType(RichText)),
        );
        final style = rich.text.style;
        expect(
          style?.decoration ?? TextDecoration.none,
          TextDecoration.none,
          reason: '"$text" inherits $style',
        );
      }
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('tokens', () {
    test(
      'geometry matches design/tokens.json and the README component table',
      () {
        expect(HomeTile.height, 132);
        expect(HomeTileIcon.size, 58);
        expect(NestySegmentedTabs.height, 46);
        expect(NestyBottomNav.itemWidth, 80);
        expect(BottomNavTokens.activeItemSize, const Size(58, 52));
        expect(BottomNavTokens.itemSize, const Size(48, 48));
        expect(BottomNavTokens.lift, -6);
        expect(ScreenHeader.height, 48);
        expect(BuyPopupBody.iconDiscSize, 112);
        expect(IntroCard.illustrationSize, const Size(302, 230));
        expect(UiMotionTokens.tabLiftMs, 180);
      },
    );

    testWidgets('the buy popup disc paints the given icon disc gradient', (
      tester,
    ) async {
      const gradient = RadialGradient(
        colors: [Color(0xFFFFFBF2), Color(0xFFF6E2C2), Color(0xFFE3C394)],
        stops: [0, 0.6, 1],
      );
      await pumpUi(
        tester,
        Center(
          child: BuyPopupBody(
            icon: NestyIcons.undo,
            iconBackground: gradient,
            iconColor: AppColors.iconBrown,
            haloColor: const Color(0x59E3C394),
            benefitText: 'Your 2 free undos are used. Take back one more move.',
            price: 20,
            balanceLabel: 'You have 830 coins',
            onBuy: () {},
          ),
        ),
        feedback: RecordingFeedback(),
      );
      final surface = tester.widget<NestySurface>(
        find
            .descendant(
              of: find.byType(BuyPopupBody),
              matching: find.byType(NestySurface),
            )
            .first,
      );
      expect(surface.style.gradient, gradient);
      expect(find.text('You have 830 coins'), findsOneWidget);
    });
  });
}

/// No component is wider than the screen.
void _expectInside(WidgetTester tester, double width) {
  for (final type in [
    NestySegmentedTabs,
    NestyBottomNav,
    HomeTile,
    ScreenHeader,
    SettingsSection,
  ]) {
    for (final element in find.byType(type).evaluate()) {
      final box = element.renderObject! as RenderBox;
      final left = box.localToGlobal(Offset.zero).dx;
      expect(left, greaterThanOrEqualTo(-0.5), reason: '$type left');
      expect(
        left + box.size.width,
        lessThanOrEqualTo(width + 0.5),
        reason: '$type right',
      );
    }
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery();

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 20, bottom: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ScreenHeader(title: l10n.shopTitle, coins: 1240),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ScreenHeader(title: l10n.settings, onClose: () {}),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ScreenHeader(
              title: l10n.levelDaily,
              onBack: () {},
              coins: 830,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: NestySegmentedTabs(
              labels: [
                l10n.shopTabCoins,
                l10n.shopTabSkins,
                l10n.shopTabThemes,
                l10n.shopTabNoAds,
              ],
              selectedIndex: 1,
              onChanged: (_) {},
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: HomeTile(
                    leading: const HomeTileIcon(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFFE7A0), Color(0xFFF5C518)],
                      ),
                      edgeColor: AppColorTokens.dailyEdge,
                      highlightOpacity: 0.6,
                      child: Icon(
                        NestyIcons.extension,
                        size: 34,
                        color: Color(0xFF8C5E12),
                      ),
                    ),
                    label: l10n.homeDailyTile,
                    onTap: () {},
                    badge: const StreakBadge(days: 4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: HomeTile(
                    leading: HomeTileIcon(
                      gradient: AppGradientTokens.ad,
                      edgeColor: AppColorTokens.adEdge,
                      child: HomeTileIcon.removeAdsGlyph(),
                    ),
                    label: l10n.homeRemoveAdsTile,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: HomeTile(
                    leading: const Icon(NestyIcons.museum, size: 40),
                    label: l10n.homeMuseumTile,
                    onTap: () {},
                    locked: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          NestyBottomNav(
            items: [
              NestyBottomNavItem(
                icon: NestyIcons.storefront,
                label: l10n.navShop,
              ),
              const NestyBottomNavItem(icon: NestyIcons.home, label: 'Home'),
              NestyBottomNavItem(
                icon: NestyIcons.museum,
                label: l10n.navMuseum,
              ),
            ],
            selectedIndex: 1,
            onChanged: (_) {},
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ModalCard(
              title: l10n.boosterUndo,
              onClose: () {},
              child: BuyPopupBody(
                icon: NestyIcons.undo,
                iconBackground: const RadialGradient(
                  colors: [
                    Color(0xFFFFFBF2),
                    Color(0xFFF6E2C2),
                    Color(0xFFE3C394),
                  ],
                  stops: [0, 0.6, 1],
                ),
                iconColor: AppColors.iconBrown,
                haloColor: const Color(0x59E3C394),
                benefitText: l10n.buyUndoText(2),
                price: 20,
                balanceLabel: l10n.balanceLine(830),
                onBuy: () {},
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ModalCard(
              title: l10n.oomSlotTitle,
              onClose: () {},
              child: BuyPopupBody(
                icon: NestyIcons.addBox,
                iconBackground: const RadialGradient(
                  colors: [
                    Color(0xFFEFFCF2),
                    Color(0xFFBDECC8),
                    Color(0xFF7FD08D),
                  ],
                  stops: [0, 0.6, 1],
                ),
                iconColor: AppColorTokens.successEdge,
                haloColor: const Color(0x4D7FD08D),
                benefitText: l10n.buySlotText,
                price: 150,
                balanceLabel: l10n.balanceLine(40),
                onBuy: null,
                offline: true,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: IntroCard(
              badgeLabel: l10n.introNew,
              title: l10n.introTowersTitle,
              text: l10n.introTowersText,
              onGotIt: () {},
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: NestyToast(
              tone: NestyBannerTone.info,
              icon: NestyIcons.acUnit,
              title: l10n.dailySavedTitle,
              message: l10n.dailySavedBody('Friday'),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: NestyToast(
              tone: NestyBannerTone.success,
              icon: NestyIcons.restore,
              title: 'Purchases restored',
              message: 'Remove Ads is active on this device.',
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SettingsSection(
              children: [
                SettingsToggleRow(
                  icon: NestyIcons.volumeUp,
                  label: l10n.settingSound,
                  value: true,
                  onChanged: (_) {},
                ),
                SettingsToggleRow(
                  icon: NestyIcons.musicNote,
                  label: l10n.settingMusic,
                  value: false,
                  onChanged: (_) {},
                ),
                SettingsToggleRow(
                  icon: NestyIcons.vibration,
                  label: l10n.settingHaptics,
                  value: true,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SettingsSection(
              children: [
                SettingsRow(
                  icon: NestyIcons.translate,
                  label: l10n.settingLanguage,
                  value: 'English',
                  onTap: () {},
                ),
                SettingsRow(
                  icon: NestyIcons.restore,
                  label: l10n.settingRestorePurchases,
                  onTap: null,
                ),
                SettingsRow(
                  icon: NestyIcons.adminPanelSettings,
                  label: l10n.settingPrivacyChoices,
                  onTap: null,
                ),
                SettingsRow(
                  icon: NestyIcons.shield,
                  label: l10n.settingPrivacyPolicy,
                  onTap: () {},
                ),
                SettingsRow(
                  icon: NestyIcons.mail,
                  label: l10n.settingSupport,
                  value: l10n.settingSupportValue,
                  onTap: () {},
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.settingsFooter('1.0.0', '42', '7F3A-21C9'),
              textAlign: TextAlign.center,
              style: context.captionText,
            ),
          ),
        ],
      ),
    );
  }
}
