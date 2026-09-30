import 'dart:ui' show CheckedState;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show SemanticsAction;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/race/cubit/rival_select_cubit.dart';
import 'package:nesty_game/features/race/pages/rival_select_page.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

import '../../../core/ui/support/ui_harness.dart';

/// Rival select (frames 9.2, 9.2b; m7-design P4.4) over a real
/// [RivalSelectCubit] built from fakes: every rival card says Computer
/// (spec-prop §1.1 rule 5), the reward is shown before the race (rule 2),
/// and a locked card is inert.
void main() {
  setUpAll(loadBundledFonts);

  RivalSelectCubit build(FakeSaveService save) =>
      RivalSelectCubit(save, FakeRemoteConfigService());

  FakeSaveService saveWith(List<RivalProgress> rivals) => FakeSaveService(
    initial: SaveDocument(
      currentLevel: 40,
      highestLevel: 40,
      race: RaceProgress(rivals: rivals),
    ),
  );

  const fresh = [
    RivalProgress(unlocked: true),
    RivalProgress(),
    RivalProgress(),
  ];
  const buttonNew = [
    RivalProgress(unlocked: true, wins: 1, raceNo: 1),
    RivalProgress(unlocked: true),
    RivalProgress(),
  ];

  Future<void> pumpSelect(
    WidgetTester tester,
    RivalSelectCubit cubit, {
    double width = 390,
    double textScale = 1,
    bool reduceMotion = false,
  }) async {
    tester.view
      ..physicalSize = Size(width, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
            disableAnimations: reduceMotion,
          ),
          child: child!,
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<RivalSelectCubit>.value(
          value: cubit,
          child: const RivalSelectPage(),
        ),
      ),
    );
    await cubit.load();
    await tester.pump();
  }

  testWidgets('frame 9.2: header, subtitle, three cards each with the '
      'Computer tag, the hint and one Start', (tester) async {
    await pumpSelect(tester, build(saveWith(fresh)));

    expect(find.text('vs Computer'), findsOneWidget);
    expect(find.text('Race a computer on the same puzzle'), findsOneWidget);
    expect(find.text('Pebble'), findsOneWidget);
    expect(find.text('Button'), findsOneWidget);
    expect(find.text('Comet'), findsOneWidget);
    expect(find.byType(ComputerTag), findsNWidgets(3), reason: 'one per card');
    expect(find.text('Computer'), findsNWidgets(3));
    expect(
      find.text('Takes its time and enjoys every doll along the way.'),
      findsOneWidget,
    );
    expect(find.text('Relaxed · Slow'), findsOneWidget);
    expect(find.text('Win 20 coins'), findsOneWidget);
    expect(
      find.text('Same puzzle, two boards. Complete every family first.'),
      findsOneWidget,
    );
    expect(
      find.text('Start'),
      findsOneWidget,
      reason: 'one Start, no per-card',
    );
    expect(find.byIcon(NestyIcons.playArrow), findsOneWidget);
  });

  testWidgets('locked cards say who to beat, take no reward chip and show '
      'the locked portrait', (tester) async {
    await pumpSelect(tester, build(saveWith(fresh)));
    expect(find.text('Beat Pebble to unlock'), findsOneWidget);
    expect(find.text('Beat Button to unlock'), findsOneWidget);
    expect(find.byIcon(NestyIcons.lock), findsNWidgets(2));
    expect(find.text('Win 30 coins'), findsNothing);
    expect(find.text('Win 40 coins'), findsNothing);
    final arts = tester
        .widgetList<UiArtImage>(find.byType(UiArtImage))
        .map((a) => a.art)
        .toList();
    expect(arts, [UiArt.rival1, UiArt.rivalLocked, UiArt.rivalLocked]);
    for (final art in tester.widgetList<UiArtImage>(find.byType(UiArtImage))) {
      expect(art.size, const Size.square(96));
    }
  });

  testWidgets('a tap selects an unlocked rival: the ring and the check disc '
      'follow, and Start races that rival', (tester) async {
    final cubit = build(
      saveWith(const [
        RivalProgress(unlocked: true, wins: 1, raceNo: 1),
        RivalProgress(unlocked: true, raceNo: 1),
        RivalProgress(),
      ]),
    );
    await pumpSelect(tester, cubit);
    // Button (2) is the newest raced unlocked rival: preselected.
    expect(cubit.state.data!.selected, 2);
    double opacityOf(int index) => tester
        .widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity))
        .elementAt(index)
        .opacity;
    expect(opacityOf(0), 0);
    expect(opacityOf(1), 1);

    await tester.tap(find.text('Pebble'));
    await tester.pump();
    expect(cubit.state.data!.selected, 1);
    expect(opacityOf(0), 1);
    expect(opacityOf(1), 0);
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('a locked card is inert: no selection change and no haptic', (
    tester,
  ) async {
    final cubit = build(saveWith(fresh));
    final feedback = RecordingFeedback();
    await tester.pumpWidget(
      TactileFeedbackScope(
        feedback: feedback,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<RivalSelectCubit>.value(
            value: cubit,
            child: const RivalSelectPage(),
          ),
        ),
      ),
    );
    await cubit.load();
    await tester.pump();
    await tester.tap(find.text('Comet'));
    await tester.tap(find.text('Button'));
    await tester.pump();
    expect(cubit.state.data!.selected, 1);
    expect(feedback.activations, 0);
  });

  testWidgets('9.2b: a beaten rival wears a check, the new one a "New" chip '
      'and is preselected', (tester) async {
    final cubit = build(saveWith(buttonNew));
    await pumpSelect(tester, cubit);
    expect(cubit.state.data!.selected, 2);
    expect(find.text('New'), findsOneWidget);
    // The beaten check on Pebble's portrait (18 dp, always shown), and the
    // selected disc only on Button's card (opacity 1 there, 0 elsewhere).
    expect(
      find.byWidgetPredicate(
        (w) => w is Icon && w.icon == NestyIcons.check && w.size == 18,
      ),
      findsOneWidget,
    );
    final opacities = tester
        .widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity))
        .map((o) => o.opacity)
        .toList();
    expect(opacities, [0, 1, 0]);
    // The reward chip stays on a beaten rival: a rematch pays.
    expect(find.text('Win 20 coins'), findsOneWidget);
    expect(find.text('Win 30 coins'), findsOneWidget);
  });

  testWidgets('"New" clears once the rival is raced', (tester) async {
    final save = saveWith(buttonNew);
    final cubit = build(save);
    await pumpSelect(tester, cubit);
    expect(find.text('New'), findsOneWidget);
    expect(cubit.begin(2), isNotNull);
    await tester.pump();
    await tester.pump();
    expect(find.text('New'), findsNothing);
  });

  testWidgets('a win against a rival unlocks the next one live', (
    tester,
  ) async {
    final save = saveWith(fresh);
    await pumpSelect(tester, build(save));
    expect(find.text('Beat Pebble to unlock'), findsOneWidget);

    save.recordRaceWin(
      const RaceWinRecord(rival: 1, raceNo: 1, rewardCoins: 20),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Beat Pebble to unlock'), findsNothing);
    expect(
      find.text('Checks each move twice before it makes it.'),
      findsOneWidget,
    );
    expect(find.text('New'), findsOneWidget);
  });

  testWidgets('each card is a radio of one group; the locked one is '
      'disabled; Start names the selected rival', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpSelect(tester, build(saveWith(buttonNew)));

    final pebble = tester.getSemantics(
      find.bySemanticsLabel(RegExp('^Pebble, Computer')),
    );
    final pebbleData = pebble.getSemanticsData();
    expect(pebbleData.label, contains('Relaxed · Slow'));
    expect(pebbleData.label, contains('Win 20 coins'));
    expect(pebbleData.label, contains('Beaten'));
    expect(pebbleData.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
    expect(pebbleData.hasAction(SemanticsAction.tap), isTrue);

    final button = tester
        .getSemantics(find.bySemanticsLabel(RegExp('^Button, Computer')))
        .getSemanticsData();
    expect(button.label, contains('New'));
    expect(button.flagsCollection.isChecked, CheckedState.isTrue);

    final comet = tester
        .getSemantics(find.bySemanticsLabel(RegExp('^Comet, Computer')))
        .getSemanticsData();
    expect(comet.label, contains('Beat Button to unlock'));
    expect(comet.hasAction(SemanticsAction.tap), isFalse);

    final start = tester.getSemantics(
      find.bySemanticsLabel('Start race against Button'),
    );
    expect(start.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    handle.dispose();
  });

  testWidgets('the selected portrait pops to 1.04; reduced motion has no '
      'pop', (tester) async {
    await pumpSelect(tester, build(saveWith(fresh)));
    double scale() =>
        tester.widget<AnimatedScale>(find.byType(AnimatedScale).first).scale;
    expect(scale(), 1.04);
    await pumpSelect(tester, build(saveWith(fresh)), reduceMotion: true);
    expect(scale(), 1);
  });

  testWidgets('under 360 dp the tag drops to its glyph; the card takes '
      'three lines of personality at 1.3x text without overflow', (
    tester,
  ) async {
    await pumpSelect(
      tester,
      build(saveWith(buttonNew)),
      width: 320,
      textScale: 1.3,
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Computer'), findsNothing);
    expect(find.byIcon(IconUses.computerTag), findsNWidgets(3));
    expect(
      tester.getSize(find.byType(UiArtImage).first),
      const Size.square(RivalSelectTokens.portrait),
    );
  });
}
