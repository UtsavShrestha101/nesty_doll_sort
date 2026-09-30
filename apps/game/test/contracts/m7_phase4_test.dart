import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/extensions/catalog_l10n_extension.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/bundled_catalog_repository.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/audio/jingle_player.dart';
import 'package:nesty_game/core/services/audio/sfx_mix.dart';
import 'package:nesty_game/core/services/music/music_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/system_settings/channel_system_settings_service.dart';
import 'package:nesty_game/core/services/system_settings/fake_system_settings_service.dart';
import 'package:nesty_game/core/services/system_settings/system_settings_service.dart';
import 'package:nesty_game/core/ui/art/ui_art_image_source.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/daily/widgets/chest_icon.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_drawable_params.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_player.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/bloc/tap_policy.dart';
import 'package:nesty_game/features/gameplay/overlays/next_level_failed_card.dart';
import 'package:nesty_game/features/gameplay/overlays/pause_dialog.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_board.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_entrance.dart';
import 'package:nesty_render/nesty_render.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/gameplay/bloc/support/bloc_fixtures.dart';
import '../features/support/screen_harness.dart';
import '../helpers/level_fixtures.dart';
import '../helpers/test_dependencies.dart';

/// The shapes the M7 phase-4 contracts stage (C4b) froze for Claude
/// Design's m7-3 delivery (docs/plans/m7-design.md P4.1; phase 4
/// architecture §6.2–§6.6): each lane owns its part's behaviour tests;
/// these pin that the frozen surface exists and is wired.
void main() {
  ui.Image blank(int width, int height) {
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawRect(
      ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      ui.Paint()..color = const ui.Color(0xFFFFFFFF),
    );
    final picture = recorder.endRecording();
    final image = picture.toImageSync(width, height);
    picture.dispose();
    return image;
  }

  group('§6.2 FX plumbing', () {
    test('the tall case slots are board pieces; the UI art slots name '
        'their UiArt', () {
      expect(FxImageSlot.glassCaseTall0.piece, BoardSprite.glassCaseTall0);
      expect(FxImageSlot.glassCaseTall2.piece, BoardSprite.glassCaseTall2);
      expect(FxImageSlot.starFilled.art, UiArt.starFilled);
      expect(FxImageSlot.starEmpty.art, UiArt.starEmpty);
      expect(FxImageSlot.starGlow.art, UiArt.starGlow);
      expect(FxImageSlot.chestClosed.art, UiArt.chestClosed);
      expect(FxImageSlot.chestOpen.art, UiArt.chestOpen);
      expect(BoardSprite.glassCaseTall(1), BoardSprite.glassCaseTall1);
      expect(BoardSprite.glassCaseTall0.designSize, const ui.Size(93, 152));
    });

    test('FxDrawableParams.caseScale bumps the revision and resets', () {
      final params = FxDrawableParams();
      final before = params.revision;
      params.caseScale = 1.2;
      expect(params.caseScale, 1.2);
      expect(params.revision, greaterThan(before));
      params.reset();
      expect(params.caseScale, isNull);
    });

    test('the intro loops rest still under reduced motion', () {
      for (final id in [
        FxId.uiIntroTowers,
        FxId.uiIntroGlass,
        FxId.uiIntroIce,
      ]) {
        expect(FxMotionPolicy.classOf(id), FxMotionClass.ambient);
        expect(FxMotionPolicy.isStill(id, reduced: true), isTrue);
      }
    });

    test('SlotShape carries the sealed size, in its equality', () {
      const a = SlotShape('r0c0', SlotShapeKind.locked, lockedSize: 6);
      expect(a.lockedSize, 6);
      expect(a, const SlotShape('r0c0', SlotShapeKind.locked, lockedSize: 6));
      expect(a, isNot(const SlotShape('r0c0', SlotShapeKind.locked)));
      expect(const SlotShape('x0', SlotShapeKind.extra).lockedSize, isNull);
    });

    test('the board exposes familyCounterYield, false until lane B', () {
      final GameplayBoard board = FakeGameplayBoard(
        GameplayBoardCallbacks(
          onIntent: (_) {},
          onLayout: (_) {},
          onFamilyLanded: (_, _, _) {},
          onWon: () {},
          onOutOfMoves: () {},
        ),
        fx: FakeFxLibrary(),
        feedback: RecordingCues(),
      );
      expect(board.familyCounterYield.value, isFalse);
    });
  });

  group('§6.3 audio', () {
    test('the m7-3 sounds, jingles and the race duck', () {
      String file(SoundEffect effect) =>
          SfxMix.fileFor(effect, randomIndex: (_) => 0);
      expect(file(SoundEffect.star1), 'star_1');
      expect(file(SoundEffect.star3), 'star_3');
      expect(file(SoundEffect.chestWiggle), 'chest_wiggle');
      expect(file(SoundEffect.chestOpen), 'chest_open');
      expect(file(SoundEffect.rivalComplete), 'rival_complete');
      expect(SfxMix.jingleFileOf(Jingle.versusWin), 'jingle_versus_win');
      expect(SfxMix.jingleFileOf(Jingle.versusLose), 'jingle_versus_lose');
      expect(DuckReason.raceResult.factor, 0.3);
      expect(DuckReason.raceResult.factor, SoundTokens.musicDuckRaceResult);
    });
  });

  group('§6.4 shared UI', () {
    test('every UiArt file is synced, with its viewBox', () {
      final synced = Directory(
        'assets/ui',
      ).listSync(recursive: true).whereType<File>().map((f) => f.path).toSet();
      expect(UiArt.values.map((a) => a.assetPath).toSet(), synced);
      for (final art in UiArt.values) {
        final svg = File(art.assetPath).readAsStringSync();
        final w = art.viewBox.width.toInt();
        final h = art.viewBox.height.toInt();
        expect(svg, contains('viewBox="0 0 $w $h"'), reason: art.name);
      }
    });

    test('UiArt.badge and UiArt.rival cover every badge and rival', () {
      final arts = {
        for (final badge in BadgeId.values) ...[
          UiArt.badge(badge, earned: true),
          UiArt.badge(badge, earned: false),
        ],
      };
      expect(arts, hasLength(BadgeId.values.length * 2));
      expect(
        UiArt.badge(BadgeId.firstFamily, earned: true).fileName,
        'first_family',
      );
      expect(
        UiArt.badge(BadgeId.firstFamily, earned: false).fileName,
        'first_family_locked',
      );
      expect(
        [for (var n = 1; n <= 3; n++) UiArt.rival(n)],
        [UiArt.rival1, UiArt.rival2, UiArt.rival3],
      );
      expect(UiArt.rival(null), UiArt.rivalLocked);
    });

    test('UiArtImageSource serves the library rasters for the UI-art slots '
        'only, scaled per box unit', () async {
      final library = FakeUiArtLibrary();
      library.images[UiArt.starFilled] = blank(88, 88);
      final source = UiArtImageSource(library);
      await source.prepare(devicePixelRatio: 2);
      final request = FxImageRequest();
      final raster = source.rasterFor(FxImageSlot.starFilled, request);
      expect(raster, isNotNull);
      expect(raster!.scale, 2); // 88 px over the 44-unit box.
      expect(source.rasterFor(FxImageSlot.starEmpty, request), isNull);
      expect(source.rasterFor(FxImageSlot.glowRing, request), isNull);
      expect(library.prepared, containsAll(<UiArt>[UiArt.starFilled]));
    });

    testWidgets('UiArtImage is an empty box of its size until its raster '
        'lands, labelled or excluded', (tester) async {
      final library = FakeUiArtLibrary();
      await pumpUi(
        tester,
        UiArtScope(
          library: library,
          child: const Center(
            child: UiArtImage(
              UiArt.rival1,
              size: Size(40, 40),
              semanticLabel: 'Pebble',
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(UiArtImage)), const Size(40, 40));
      expect(find.byType(RawImage), findsNothing);
      expect(find.bySemanticsLabel('Pebble'), findsOneWidget);
      library.images[UiArt.rival1] = blank(40, 40);
      library.notify();
      await tester.pump();
      expect(find.byType(RawImage), findsOneWidget);
    });

    test('IconUses: every use is its tokens glyph; Share by platform', () {
      final pairs = <String, IconData>{
        IconTokens.chapters: IconUses.chapters,
        IconTokens.records: IconUses.records,
        IconTokens.share: IconUses.share,
        IconTokens.shareIOS: IconUses.shareIos,
        IconTokens.reminder: IconUses.reminder,
        IconTokens.reminderOff: IconUses.reminderOff,
        IconTokens.reminderTime: IconUses.reminderTime,
        IconTokens.relaxedMode: IconUses.relaxedMode,
        IconTokens.reduceMotion: IconUses.reduceMotion,
        IconTokens.bestMoves: IconUses.bestMoves,
        IconTokens.chapterFinale: IconUses.chapterFinale,
        IconTokens.computerTag: IconUses.computerTag,
        IconTokens.undoUnlimited: IconUses.undoUnlimited,
        IconTokens.chest: IconUses.chest,
        IconTokens.replay: IconUses.replay,
        IconTokens.leaveRace: IconUses.leaveRace,
        IconTokens.retry: IconUses.retry,
        IconTokens.openSettings: IconUses.openSettings,
        IconTokens.levelsWon: IconUses.levelsWon,
        IconTokens.familiesHome: IconUses.familiesHome,
        IconTokens.dollsNested: IconUses.dollsNested,
        IconTokens.dailiesSolved: IconUses.dailiesSolved,
        IconTokens.longestStreak: IconUses.longestStreak,
      };
      expect(pairs, hasLength(IconTokens.glyphs.length));
      for (final MapEntry(key: glyph, value: icon) in pairs.entries) {
        expect(NestyIcons.byName[glyph], icon, reason: glyph);
      }
      expect(IconUses.storageError, NestyIcons.sdCardAlert);
      expect(IconUses.contentError, NestyIcons.inventory2);
      expect(IconUses.shareFor(TargetPlatform.iOS), IconUses.shareIos);
      expect(IconUses.shareFor(TargetPlatform.android), IconUses.share);
    });

    testWidgets('the toast queue shows one at a time, 2.5 s each, 300 ms '
        'apart, and NestyToast.show queues on the nearest host', (
      tester,
    ) async {
      late BuildContext inner;
      await pumpUi(
        tester,
        ToastHost(
          child: Builder(
            builder: (context) {
              inner = context;
              return const SizedBox.expand();
            },
          ),
        ),
      );
      final queue = ToastHost.maybeOf(inner)!;
      queue.enqueue(const ToastSpec(tone: ToastTone.badge, title: 'First'));
      NestyToast.show(
        inner,
        tone: NestyBannerTone.success,
        icon: NestyIcons.check,
        title: 'Second',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsNothing);
      // 2.5 s on screen, the fade out, the 300 ms gap, then the next.
      await tester.pump(
        const Duration(milliseconds: ToastTokens.autoDismissMs),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: ToastTokens.gapMs));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('First'), findsNothing);
      expect(find.text('Second'), findsOneWidget);
      queue.clear();
      await tester.pump();
      expect(find.text('Second'), findsNothing);
    });

    test('TactileButtonVariant.versus and .danger take tokens v3', () {
      expect(TactileButtonVariant.versus.face, AppGradientTokens.versus);
      expect(TactileButtonVariant.versus.edgeColor, AppColorTokens.versusEdge);
      expect((TactileButtonVariant.danger.face as LinearGradient).colors, [
        AppColorTokens.dangerTop,
        AppColorTokens.danger,
      ]);
      expect(TactileButtonVariant.danger.edgeColor, AppColorTokens.dangerEdge);
    });

    testWidgets('ChestIcon draws the chest art at its aspect', (tester) async {
      await pumpUi(
        tester,
        const Center(child: Row(children: [ChestIcon(), ChestIcon.open()])),
      );
      final arts = tester
          .widgetList<UiArtImage>(find.byType(UiArtImage))
          .map((i) => i.art);
      expect(arts, [UiArt.chestClosed, UiArt.chestOpen]);
      expect(ChestIcon.heightFor(180), 150);
    });

    test('ChapterTheme ch07–ch10 with the palette; the catalog prices them '
        '(Q156) and sells Forest Bear', () {
      expect(ChapterTheme.values, hasLength(10));
      expect(ChapterTheme.ch07.palette, ChapterThemeTokens.ch07.palette);
      expect(ChapterTheme.ch10.fallbackColor, ChapterTheme.ch10.palette.band);
      expect(BundledCatalogRepository.themeIds, [
        for (final theme in ChapterTheme.values) theme.id,
      ]);
      for (final chapter in BundledCatalogRepository.bundledChapters) {
        expect(chapter.themeId, ChapterTheme.forChapter(chapter.number).id);
      }
      final prices = {
        for (final theme in BundledCatalogRepository.bundledThemes)
          theme.id: theme.priceCoins,
      };
      for (final id in ['ch07', 'ch08', 'ch09', 'ch10']) {
        expect(prices[id], 2000, reason: id);
      }
      final bear = BundledCatalogRepository.bundledSkins.singleWhere(
        (s) => s.id == 'forest-bear',
      );
      expect(bear.sold, isTrue);
      expect(bear.priceCoins, 2500);
    });

    test('CatalogL10n maps a hyphenated skin id to its select key', () {
      expect(CatalogL10n.selectKeyOf('forest-bear'), 'forest_bear');
      expect(CatalogL10n.selectKeyOf('ocean'), 'ocean');
    });
  });

  group('§6.5 bloc, save, route', () {
    test('a tap on an unpickable slot nudges it, by core\'s slot view', () {
      final board = GameState.initial(icedLevel);
      expect(
        TapPolicy.tap(board, selected: null, tapped: emptyTop),
        const NudgeSlot(emptyTop, SlotNudgeKind.emptyStand),
      );
      expect(
        TapPolicy.tap(board, selected: null, tapped: 'r0c2'),
        const NudgeSlot('r0c2', SlotNudgeKind.iced),
      );
    });

    test('the bloc emits SlotNudgeEffect for a nudge, and dropTargets are '
        "core's legal targets while a nest is lifted", () async {
      final bloc = buildBloc();
      addTearDown(bloc.close);
      bloc.add(const GameplayStarted(PlayRequest.campaign(1)));
      await bloc.stream.firstWhere((s) => s.data != null);
      bloc.add(const SlotTapped(emptyTop));
      final nudged = await bloc.stream.firstWhere(
        (s) => s.data?.effect is SlotNudgeEffect,
      );
      expect(
        nudged.data!.effect,
        const SlotNudgeEffect(emptyTop, SlotNudgeKind.emptyStand),
      );
      expect(nudged.data!.selectedSlotId, isNull);

      bloc.add(const SlotTapped(red1));
      final lifted = await bloc.stream.firstWhere(
        (s) => s.data?.selectedSlotId == red1,
      );
      expect(
        lifted.data!.dropTargets,
        Rules.legalTargets(lifted.data!.board, red1).toSet(),
      );
      expect(lifted.data!.dropTargets, contains(red2));
      bloc.add(const SlotTapped(red1));
      final put = await bloc.stream.firstWhere(
        (s) => s.data?.selectedSlotId == null,
      );
      expect(put.data!.dropTargets, isEmpty);
    });

    test('a capped win keeps the tip back; markStarTipShown is one '
        'idempotent write', () {
      final save = FakeSaveService();
      LevelWinOutcome win({required bool capped, int stars = 2}) =>
          save.recordLevelWin(
            LevelWinRecord(
              request: const PlayRequest.campaign(1),
              rewardCoins: 0,
              moves: 9,
              starsKey: 'L0001',
              stars: stars,
              starsCapped: capped,
            ),
          );
      expect(win(capped: true).showStarTip, isFalse);
      expect(win(capped: false).showStarTip, isTrue);
      // recordLevelWin no longer writes it: the card does, once shown.
      expect(save.document.starTipShown, isFalse);
      save.markStarTipShown();
      expect(save.document.starTipShown, isTrue);
      final doc = save.document;
      save.markStarTipShown();
      expect(save.document, same(doc));
      expect(win(capped: false).showStarTip, isFalse);
    });

    test('GameplayRouteArgs.entrance defaults to push; the route runs 400 '
        'ms', () {
      const args = GameplayRouteArgs(request: PlayRequest.campaign(1));
      expect(args.entrance, GameplayEntrance.push);
      expect(GameplayTransitions.duration, const Duration(milliseconds: 400));
      expect(
        GameplayTransitions.pushInterval.transform(0.75),
        closeTo(1, 1e-9),
      );
    });
  });

  group('§6.6 view and cross-lane hooks', () {
    setUpAll(loadBundledFonts);

    testWidgets("a race's Pause says the rival is paused too and offers "
        'Leave race', (tester) async {
      var left = 0;
      await pumpUi(
        tester,
        PauseDialog(
          race: const RacePauseInfo(rival: 1),
          settings: const PauseSettings(
            sound: true,
            music: true,
            haptics: true,
          ),
          onSoundChanged: (_) {},
          onMusicChanged: (_) {},
          onHapticsChanged: (_) {},
          onResume: () {},
          onRestart: () {},
          onLeaveRace: () => left++,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Pebble is paused too.'), findsOneWidget);
      // Leave race asks once (9.7b, D192): the first tap opens the confirm
      // and leaves nothing yet; its own Leave race leaves.
      await tester.tap(find.text('Leave race'));
      await tester.pumpAndSettle();
      expect(left, 0);
      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('raceLeaveConfirm')),
          matching: find.text('Leave race'),
        ),
      );
      expect(left, 1);
    });

    testWidgets('NextLevelFailedCard shows its words and both actions', (
      tester,
    ) async {
      var retried = 0;
      var left = 0;
      await pumpUi(
        tester,
        NextLevelFailedCard(
          title: 'The shelves need a moment',
          body: 'This level didn’t set up.',
          retryLabel: 'Try again',
          secondaryLabel: 'Back to Home',
          onRetry: () => retried++,
          onSecondary: () => left++,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('The shelves need a moment'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      await tester.tap(find.text('Back to Home'));
      expect((retried, left), (1, 1));
    });

    test('SystemSettingsService: the channel answers, a missing handler is '
        'false, the fake counts', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      const channel = MethodChannel(ChannelSystemSettingsService.channelName);
      final service = ChannelSystemSettingsService();
      expect(await service.openNotificationSettings(), isFalse);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            expect(
              call.method,
              ChannelSystemSettingsService.openNotificationSettingsMethod,
            );
            return true;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      expect(await service.openNotificationSettings(), isTrue);
      final fake = FakeSystemSettingsService()..next = false;
      expect(await fake.openNotificationSettings(), isFalse);
      expect(fake.openCalls, 1);
    });

    test(
      'UiArtLibrary and SystemSettingsService resolve in the fake env',
      () async {
        await configureTestDependencies();
        addTearDown(resetDependencies);
        expect(get<UiArtLibrary>(), isA<FakeUiArtLibrary>());
        expect(get<SystemSettingsService>(), isA<FakeSystemSettingsService>());
      },
    );
  });

  test('the level fixtures stay parseable (support import in use)', () {
    expect(levelFrom(defaultLevelJson).id, 'T0001');
  });
}
