import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/audio/fake_audio_service.dart';
import 'package:nesty_game/core/services/audio/jingle_player.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/core/services/music/fake_music_service.dart';
import 'package:nesty_game/core/services/music/jingle_cues.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/features/fx/chest/chest_reward_sequence.dart';
import 'package:nesty_game/features/gameplay/overlays/milestone_chest_modal.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../support/screen_harness.dart';

/// The five overflow sizes (m7-design §18/§20: "every new overlay is
/// tested at the five overflow sizes at 1.0 and 1.3 text"), with each
/// size's own plausible safe area (the shared `safeAreaOf` only knows the
/// original three; `screen_harness.dart` isn't this lane's to extend).
const _fiveSizes = [
  Size(360, 640),
  Size(390, 844),
  Size(430, 932),
  Size(375, 667),
  Size(768, 1024),
];

EdgeInsets _safeAreaFor(Size size) => switch (size) {
  Size(width: 375, height: 667) => const EdgeInsets.only(top: 20),
  Size(width: 768, height: 1024) => const EdgeInsets.only(top: 24, bottom: 20),
  _ => safeAreaOf(size),
};

/// Past arrival (~600 ms): idle, Open live. Never `pumpAndSettle` once the
/// chest is open: its rays turn forever.
Future<void> _toIdle(WidgetTester tester) => tester.pump(
  const Duration(milliseconds: ChestRewardSequence.arrivalMs + 50),
);

void main() {
  setUpAll(loadBundledFonts);

  const campaignChest = ChestGrant(
    source: ChestSource.campaign,
    number: 30,
    coins: 100,
    hints: 1,
  );

  Widget modal({
    ChestGrant chest = campaignChest,
    VoidCallback? onCollect,
    RecordingCues? feedback,
    JingleCues? jingleCues,
  }) => MilestoneChestModal(
    chest: chest,
    onCollect: onCollect ?? () {},
    feedback: feedback,
    jingleCues: jingleCues,
  );

  testWidgets('closed: the ribbon, the level line, both chips and Open', (
    tester,
  ) async {
    await pumpScreen(tester, modal());
    await _toIdle(tester);
    // copy.md G.9 (phase 4): the body names the level and says the
    // contents are shown, so there is no separate caption.
    expect(find.text('Milestone chest'), findsOneWidget);
    expect(
      find.text('A chest for reaching level 30. Here’s what’s inside.'),
      findsOneWidget,
    );
    expect(find.text('+100 coins'), findsOneWidget);
    expect(find.text('+1 hint'), findsOneWidget);
    expect(find.bySemanticsLabel('100 coins and 1 hint'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Collect'), findsNothing);
    expect(
      tester.getSize(find.byKey(ChestRewardSequence.chestKey)),
      const Size(200, 200),
    );
  });

  testWidgets('a bonus chest names the bonus number', (tester) async {
    await pumpScreen(
      tester,
      modal(
        chest: const ChestGrant(
          source: ChestSource.bonus,
          number: 20,
          coins: 100,
          hints: 1,
        ),
      ),
    );
    await _toIdle(tester);
    expect(
      find.text('A chest for bonus level 20. Here’s what’s inside.'),
      findsOneWidget,
    );
  });

  testWidgets('Open plays the chest sounds and the reward jingle once, and '
      'Collect calls back', (tester) async {
    final feedback = RecordingCues();
    final music = FakeMusicService();
    final jingles = FakeAudioService();
    final jingleCues = JingleCues(music, jingles);
    addTearDown(jingleCues.dispose);
    var collected = 0;
    await pumpScreen(
      tester,
      modal(
        feedback: feedback,
        jingleCues: jingleCues,
        onCollect: () => collected++,
      ),
    );
    await _toIdle(tester);

    await tester.tap(find.text('Open'));
    await tester.pump(const Duration(milliseconds: 1400));

    expect(
      feedback.played.where((c) => c.sound == SoundEffect.chestWiggle),
      hasLength(1),
    );
    expect(
      feedback.played.where((c) => c.sound == SoundEffect.chestOpen),
      hasLength(1),
    );
    expect(
      feedback.played.where((c) => c.haptic == HapticPattern.nest),
      hasLength(1),
    );
    expect(jingles.jingles, [Jingle.reward]);
    expect(find.text('Open'), findsNothing);
    expect(find.text('Collect'), findsOneWidget);
    // The contents stay visible once opened (rule 2: shown in advance).
    expect(find.text('+100 coins'), findsOneWidget);
    expect(find.text('+1 hint'), findsOneWidget);

    await tester.tap(find.text('Collect'));
    // No flight target is wired at this widget level (that's
    // `gameplay_view.dart`'s job): the count releases in place.
    await tester.pump(const Duration(seconds: 1));
    expect(collected, 1);
    // Lets `JingleCues.reward()`'s unduck timer fire before the test ends
    // (its own dispose only cancels what is still pending, AUDIO.md).
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('Open does nothing a second time (no double haptic or '
      'jingle)', (tester) async {
    final feedback = RecordingCues();
    final music = FakeMusicService();
    final jingles = FakeAudioService();
    final jingleCues = JingleCues(music, jingles);
    addTearDown(jingleCues.dispose);
    await pumpScreen(tester, modal(feedback: feedback, jingleCues: jingleCues));
    await _toIdle(tester);
    await tester.tap(find.text('Open'));
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.tap(find.text('Collect'));
    await tester.pump(const Duration(seconds: 1));
    expect(
      feedback.played.where((c) => c.haptic == HapticPattern.nest),
      hasLength(1),
    );
    expect(jingles.jingles, [Jingle.reward]);
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('a second tap while it opens skips straight to Collect', (
    tester,
  ) async {
    var collected = 0;
    await pumpScreen(tester, modal(onCollect: () => collected++));
    await _toIdle(tester);
    await tester.tap(find.text('Open'));
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tap(find.text('Open'));
    await tester.pump();
    expect(find.text('Collect'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  for (final size in _fiveSizes) {
    for (final scale in textScales) {
      testWidgets('closed fits ${size.width.toInt()}×${size.height.toInt()} at '
          '$scale× text', (tester) async {
        await pumpScreen(
          tester,
          modal(),
          size: size,
          textScale: scale,
          padding: _safeAreaFor(size),
        );
        await _toIdle(tester);
        expectNoLayoutErrors(tester);
      });

      testWidgets('open fits ${size.width.toInt()}×${size.height.toInt()} at '
          '$scale× text', (tester) async {
        await pumpScreen(
          tester,
          modal(),
          size: size,
          textScale: scale,
          padding: _safeAreaFor(size),
        );
        await _toIdle(tester);
        await tester.tap(find.text('Open'));
        await tester.pump(const Duration(milliseconds: 1400));
        expectNoLayoutErrors(tester);
        await expectAccessibleLayout(tester);
      });
    }
  }
}
