import 'dart:async';

import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/services/music/jingle_cues.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/game/timeline/feedback_sink.dart';
import 'package:nesty_game/features/login_gift/cubit/login_gift_cubit.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_anchors.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_chest_modal.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_sheet.dart';

/// Home's daily gift button (frames 13.1, 13.1b, 13.2; `gift.button`), in
/// the top row left of the gear: a 46 dp face (48 dp target), radius 17,
/// the cream face and its edge, `ui/gift/gift_glyph.svg` at 28. While
/// today's gift can be claimed a 12 dp gold dot with a cream ring sits on
/// its corner, still (no pulse, no number, never red). Hidden until the
/// gift unlocks with the Daily (after level 2). It is the only thing that
/// opens the gift (D92: no popup, no reminder of its own). Needs a
/// [LoginGiftCubit] above it; without one (a test that doesn't care about
/// the gift) it draws nothing.
class GiftButton extends StatelessWidget {
  const GiftButton({
    this.anchors,
    this.jingleCues,
    this.feedback,
    this.library,
    this.uiArt,
    super.key,
  });

  /// Home's coin pill, where the claim's coins, tally and ring go.
  final GiftAnchors? anchors;
  final JingleCues? jingleCues;
  final FeedbackSink? feedback;
  final FxLibrary? library;
  final UiArtLibrary? uiArt;

  /// The dot, for tests.
  @visibleForTesting
  static const Key dotKey = Key('gift-dot');

  /// The button's face, for tests.
  @visibleForTesting
  static const Key faceKey = Key('gift-face');

  static const _style = SurfaceStyle(
    gradient: GiftButtonTokens.face,
    shadows: GiftButtonTokens.shadow,
  );

  @override
  Widget build(BuildContext context) {
    final cubit = maybeLoginGiftCubit(context);
    if (cubit == null) return const SizedBox.shrink();
    return BlocBuilder<LoginGiftCubit, AsyncValue<LoginGiftState>>(
      bloc: cubit,
      buildWhen: (a, b) => a.data?.phase != b.data?.phase,
      builder: (context, value) {
        final phase = value.data?.phase;
        if (phase == null || phase == LoginGiftPhase.locked) {
          return const SizedBox.shrink();
        }
        final ready = phase == LoginGiftPhase.ready;
        final l10n = context.localizations;
        // The face is centred in its 48 dp target, so the dot's offsets
        // (from the face's corner) shift by the target's margin.
        const margin = (GiftButtonTokens.touch - GiftButtonTokens.size) / 2;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            TactileSurface(
              key: faceKey,
              style: _style,
              radius: const BorderRadius.all(
                Radius.circular(GiftButtonTokens.radius),
              ),
              width: GiftButtonTokens.size,
              height: GiftButtonTokens.size,
              minTouchSize: const Size.square(GiftButtonTokens.touch),
              semanticLabel: ready
                  ? l10n.giftButtonReadySemantics
                  : l10n.giftButtonSemantics,
              excludeChildSemantics: true,
              onPressed: () => unawaited(_open(context, cubit)),
              child: Center(
                child: UiArtImage.square(
                  UiArt.giftGlyph,
                  extent: GiftButtonTokens.glyphSize,
                  library: uiArt,
                ),
              ),
            ),
            if (ready)
              const PositionedDirectional(
                top: margin + GiftButtonTokens.readyDotOffsetTop,
                end: margin + GiftButtonTokens.readyDotOffsetRight,
                child: ExcludeSemantics(child: _Dot()),
              ),
          ],
        );
      },
    );
  }

  Future<void> _open(BuildContext context, LoginGiftCubit cubit) async {
    final grant = await GiftSheet.show(
      context,
      anchors: anchors,
      feedback: feedback ?? maybeRead<FeedbackSink>(context),
      uiArt: uiArt,
    );
    // Day 7's claim holds the pill until the chest's Collect: if the chest
    // can't open, let go of it here, so the pill never stays below the
    // balance (the gift is paid already).
    if (grant == null || !context.mounted) {
      cubit.releaseCoins();
      return;
    }
    await GiftChestModal.show(
      context,
      cubit: cubit,
      grant: grant,
      anchors: anchors,
      jingleCues: jingleCues ?? maybeRead<JingleCues>(context),
      feedback: feedback ?? maybeRead<FeedbackSink>(context),
      library: library ?? maybeRead<FxLibrary>(context),
      uiArt: uiArt,
    );
  }
}

/// The ready dot (`gift.button.readyDot`): 12 dp, a gold radial face, a
/// 2.5 dp cream ring outside it and a soft drop, as the frame's CSS draws
/// it (the ring is a `box-shadow`, so the dot reads 17 dp across). Still.
class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) => SizedBox(
    key: GiftButton.dotKey,
    width: GiftButtonTokens.readyDotSize,
    height: GiftButtonTokens.readyDotSize,
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: GiftButtonTokens.readyDotFace,
        // Flutter paints shadows in list order (CSS the reverse): the drop
        // first, the cream ring over it.
        boxShadow: [
          for (final s in GiftButtonTokens.readyDotShadow) s.toBoxShadow(),
          BoxShadow(
            color: GiftButtonTokens.readyDotRing.color,
            spreadRadius: GiftButtonTokens.readyDotRing.width,
          ),
        ],
      ),
    ),
  );
}

/// The [T] a provider above [context] holds, or null when there is none.
T? maybeRead<T>(BuildContext context) {
  try {
    return context.read<T>();
  } on Object {
    return null;
  }
}

/// The [LoginGiftCubit] above [context], or null when there is none (Home
/// in a test that doesn't provide one).
LoginGiftCubit? maybeLoginGiftCubit(BuildContext context) =>
    maybeRead<LoginGiftCubit>(context);
