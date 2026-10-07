import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/services/analytics/analytics_service.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/game/timeline/feedback_sink.dart';
import 'package:nesty_game/features/login_gift/cubit/login_gift_cubit.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_anchors.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_button.dart';

import '../../support/screen_harness.dart';

class MockAnalytics extends Mock implements AnalyticsService {}

/// FakeClock starts on 2026-09-26.
final giftToday = LocalDate.fromDateTime(FakeClock.defaultNow);

/// A gift over fakes: the real [LoginGiftCubit] on a [FakeSaveService], and
/// a host that stands in for Home's header (a coin pill that shows
/// `min(balance, cap)` as Home does, and the [GiftButton]).
class GiftRig {
  GiftRig({
    int highestLevel = 5,
    int coins = 100,
    LoginGiftProgress progress = const LoginGiftProgress(),
    String? trackJson,
    this.feedback,
  }) : clock = FakeClock() {
    final analytics = MockAnalytics();
    when(
      () => analytics.logEvent(any(), parameters: any(named: 'parameters')),
    ).thenAnswer((_) async {});
    save = FakeSaveService(
      initial: SaveDocument(
        highestLevel: highestLevel,
        coins: coins,
        loginGift: progress,
      ),
    );
    final config = FakeRemoteConfigService();
    if (trackJson != null) {
      config.setOverride(RemoteConfigKeys.loginGiftTrack, trackJson);
    }
    cubit = LoginGiftCubit(save, clock, config, analytics);
  }

  final FakeClock clock;

  /// Sound and haptics the gift plays, when a test listens.
  final FeedbackSink? feedback;
  late final FakeSaveService save;
  late final LoginGiftCubit cubit;
  final pillKey = GlobalKey();

  /// The pill's text, for reading the balance the player would see.
  static const pillTextKey = Key('rig-pill-text');

  Rect? pillRect() {
    final box = pillKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Widget host({bool withPill = true}) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider<FxLibrary>.value(value: FakeBlankFx.library),
      if (feedback case final sink?)
        RepositoryProvider<FeedbackSink>.value(value: sink),
    ],
    child: BlocProvider<LoginGiftCubit>.value(
      value: cubit,
      child: Builder(
        builder: (context) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 70, 16, 0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Row(
              children: [
                if (withPill)
                  KeyedSubtree(
                    key: pillKey,
                    child:
                        BlocBuilder<LoginGiftCubit, AsyncValue<LoginGiftState>>(
                          bloc: cubit,
                          builder: (context, value) {
                            final cap = cubit.state.data?.coinsCap;
                            final shown = cap == null
                                ? save.coins
                                : math.min(save.coins, cap);
                            return SizedBox(
                              width: 90,
                              height: 48,
                              child: Text('$shown', key: pillTextKey),
                            );
                          },
                        ),
                  ),
                const Spacer(),
                GiftButton(
                  anchors: withPill ? GiftAnchors(pill: pillRect) : null,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> pump(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    double textScale = 1,
    bool reduceMotion = false,
    bool withPill = true,
    EdgeInsets? padding,
  }) async {
    await pumpScreen(
      tester,
      Scaffold(body: host(withPill: withPill)),
      size: size,
      textScale: textScale,
      reduceMotion: reduceMotion,
      padding: padding,
    );
    await tester.runAsync(cubit.load);
    await tester.pump();
  }

  /// The balance on the pill.
  int shown(WidgetTester tester) =>
      int.parse(tester.widget<Text>(find.byKey(pillTextKey)).data!);

  Future<void> dispose(WidgetTester tester) async {
    await tester.runAsync(cubit.close);
  }
}

/// A [FakeFxLibrary] shared by the rig (no composition: the SVG art stands
/// in for the chest).
abstract final class FakeBlankFx {
  static final library = FakeFxLibrary();
}

/// Opens the gift sheet through the button.
Future<void> openGiftSheet(WidgetTester tester) async {
  await tester.tap(find.byType(GiftButton));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// A [FeedbackSink] that records every cue.
class RecordingGiftCues implements FeedbackSink {
  final List<FxCue> cues = [];

  @override
  void play(FxCue cue) => cues.add(cue);

  List<Object?> get sounds => [
    for (final cue in cues)
      if (cue.sound != null) cue.sound,
  ];

  List<Object?> get haptics => [
    for (final cue in cues)
      if (cue.haptic != null) cue.haptic,
  ];
}
