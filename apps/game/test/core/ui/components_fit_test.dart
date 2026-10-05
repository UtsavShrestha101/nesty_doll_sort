import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart' show Tier;
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

import 'support/ui_harness.dart';

/// Spec §16 (menus fit at 1.3× text) and M7 "no layout overflows": every
/// component, laid out as the frames use it, on 360 and 390 dp phones with
/// the real bundled fonts. An overflow is a FlutterError, which fails here.
void main() {
  setUpAll(loadBundledFonts);

  for (final width in [360.0, 390.0]) {
    for (final textScale in [1.0, 1.3]) {
      testWidgets('components fit ${width.toInt()} dp at ${textScale}x text', (
        tester,
      ) async {
        await pumpUi(
          tester,
          const _Gallery(),
          width: width,
          height: 3200,
          textScale: textScale,
          feedback: RecordingFeedback(),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);

        // Spot checks that the copy is really on screen.
        expect(find.text('No moves left!'), findsOneWidget);
        expect(find.text('Hmm, this looks stuck'), findsOneWidget);
        expect(find.text('Free · 1 left'), findsOneWidget);
        expect(find.text('1,240'), findsNWidgets(2));
        for (final label in ['Undo', 'Hint', '+Slot', 'Restart']) {
          expect(find.text(label), findsWidgets, reason: label);
        }
        _expectInside(tester, width);
      });
    }
  }
}

/// No component is wider than the screen.
void _expectInside(WidgetTester tester, double width) {
  for (final type in [
    TactileButton,
    LevelPill,
    CoinPill,
    BoosterButton,
    NestyBanner,
    ModalCard,
    NestySheet,
    PlayButton,
    Wordmark,
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
    final width = MediaQuery.sizeOf(context).width;
    // The booster bar's rule: min(80, (W − 56) / 4).
    final boosterWidth = math.min(80.0, (width - 56) / 4);
    Widget padded(Widget child) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: child,
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 40, bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HUD row (frame 2.2): pause · level pill · coins.
          padded(
            Row(
              children: [
                IconTactileButton(
                  icon: NestyIcons.pause,
                  semanticLabel: l10n.pause,
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Center(child: LevelPill(level: 56, tier: Tier.hard)),
                ),
                const SizedBox(width: 8),
                const CoinPill(coins: 1240),
              ],
            ),
          ),
          padded(
            const Wrap(
              spacing: 8,
              runSpacing: 16,
              children: [
                LevelPill(level: 14, tier: Tier.easy),
                LevelPill(level: 60, tier: Tier.superhard),
                LevelPill.daily(dateLabel: 'Sep 26'),
                LevelPill.bonus(level: 1),
              ],
            ),
          ),
          padded(CoinPill(coins: 1240, onAdd: () {})),
          // Booster bar (frame 2.2), on its wood.
          WoodBar(
            height: 110,
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BoosterButton(
                  kind: BoosterButtonKind.undo,
                  icon: NestyIcons.undo,
                  label: l10n.boosterUndo,
                  width: boosterWidth,
                  badge: const BoosterBadge.coin(20),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                BoosterButton(
                  kind: BoosterButtonKind.hint,
                  icon: NestyIcons.lightbulb,
                  label: l10n.boosterHint,
                  width: boosterWidth,
                  badge: const BoosterBadge.count(2),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                BoosterButton(
                  kind: BoosterButtonKind.slot,
                  icon: NestyIcons.addBox,
                  label: l10n.boosterExtraSlot,
                  width: boosterWidth,
                  color: AppColorTokens.successEdge,
                  badge: const BoosterBadge.ad(),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                BoosterButton(
                  kind: BoosterButtonKind.restart,
                  icon: NestyIcons.restartAlt,
                  label: l10n.restart,
                  width: boosterWidth,
                  onPressed: null,
                ),
              ],
            ),
          ),
          // Banners (frames 3.4, 3.7).
          padded(
            NestyBanner(
              tone: NestyBannerTone.warning,
              icon: NestyIcons.sentimentNeutral,
              title: l10n.softStuckTitle,
              message: l10n.softStuckBody,
              action: TactileButton(
                label: l10n.softStuckAction,
                icon: NestyIcons.undo,
                size: TactileButtonSize.compact,
                expand: false,
                onPressed: () {},
              ),
            ),
          ),
          padded(
            NestyBanner(
              tone: NestyBannerTone.danger,
              icon: NestyIcons.wifiOff,
              title: l10n.offlineTitle,
              message: l10n.offlineAds,
            ),
          ),
          padded(
            NestyBanner(
              tone: NestyBannerTone.info,
              icon: NestyIcons.acUnit,
              title: l10n.offlineTitle,
              message: l10n.connectToWatchAd,
            ),
          ),
          padded(
            NestyBanner(
              tone: NestyBannerTone.success,
              icon: NestyIcons.check,
              title: l10n.winRewardAdded,
            ),
          ),
          // Buttons, every variant and size.
          for (final variant in TactileButtonVariant.values)
            padded(
              TactileButton(
                label: l10n.winContinue,
                icon: NestyIcons.star,
                variant: variant,
                onPressed: () {},
              ),
            ),
          for (final size in TactileButtonSize.values)
            padded(
              TactileButton(
                label: l10n.allLevelsPlayBonus(1),
                size: size,
                onPressed: () {},
              ),
            ),
          padded(TactileButton(label: l10n.resume, onPressed: null)),
          padded(
            Row(
              children: [
                Expanded(child: CoinPriceButton(price: 60, onPressed: () {})),
                const SizedBox(width: 10),
                Expanded(
                  child: RewardedAdButton(
                    label: l10n.watchAd,
                    size: TactileButtonSize.medium,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          padded(const CoinPriceButton(price: 150, onPressed: null)),
          padded(
            RewardedAdButton(label: l10n.winTripleCoins, onPressed: () {}),
          ),
          padded(
            RewardedAdButton(
              label: l10n.winTripleCoins,
              claimed: true,
              onPressed: null,
            ),
          ),
          // Pause card (frame 3.9).
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ModalCard(
              title: l10n.pauseTitle,
              onClose: () {},
              child: Column(
                children: [
                  Text(l10n.levelWithTier(56, l10n.tierName('hard'))),
                  for (final label in [
                    l10n.settingSound,
                    l10n.settingMusic,
                    l10n.settingHaptics,
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      child: Row(
                        children: [
                          Expanded(child: Text(label, style: context.rowText)),
                          NestyToggle(
                            value: label == l10n.settingSound,
                            semanticLabel: label,
                            onChanged: (_) {},
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  TactileButton(
                    label: l10n.resume,
                    size: TactileButtonSize.medium,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          // Out-of-moves sheet (frame 3.5), edge to edge.
          const SizedBox(height: 30),
          NestySheet(
            title: l10n.oomTitle,
            subtitle: l10n.oomSubtitle,
            children: [
              SheetRow(
                icon: NestyIcons.undo,
                title: l10n.boosterUndo,
                subtitle: l10n.oomUndoSubtitle,
                trailing: SheetRowTag(l10n.oomUndoFree(1)),
              ),
              SheetRow(
                icon: NestyIcons.addBox,
                title: l10n.oomSlotTitle,
                subtitle: l10n.oomSlotSubtitle,
                tone: SheetRowTone.success,
                highlighted: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RewardedAdButton.compact(onPressed: () {}),
                    const SizedBox(width: 6),
                    CoinPriceChip(price: 150, onPressed: () {}),
                  ],
                ),
              ),
              SheetRow(
                icon: NestyIcons.restartAlt,
                title: l10n.restart,
                subtitle: l10n.oomRestartSubtitle,
                trailing: SheetRow.chevron,
                onTap: () {},
              ),
            ],
          ),
          // Home (frame 2.1) and splash (1.1).
          const SizedBox(height: 30),
          const Center(child: Wordmark()),
          const Center(child: Wordmark(size: WordmarkSize.small)),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: PlayButton(level: 56, tier: Tier.hard, onPressed: () {}),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: PlayButton(level: 1, tier: Tier.easy, onPressed: () {}),
          ),
          const SizedBox(height: 20),
          const PlankStrip(),
          const PlankStrip(height: 30),
          padded(Text(l10n.splashCaption, style: context.buttonSmallText)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 56),
            child: NestyProgressBar(
              value: 0.4,
              striped: true,
              tone: NestyProgressTone.orange,
            ),
          ),
          padded(const NestyProgressBar(value: 0.8, height: 16)),
          padded(
            LottieTextOverlay(
              label: l10n.winTitle,
              style: LottieLabelStyles.winRibbon,
            ),
          ),
          padded(
            LottieTextOverlay(
              label: l10n.chapterRibbon(2, l10n.chapterName('ch02')),
              style: LottieLabelStyles.chapterRibbon,
            ),
          ),
          padded(
            RetryView(
              exception: const AppException(AppExceptionKind.storage),
              onRetry: () {},
            ),
          ),
        ],
      ),
    );
  }
}
