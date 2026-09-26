import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_render/nesty_render.dart' show BoardLayoutConstants;

/// What the booster bar shows for a [GameplayState] (spec §8, frames 2.2,
/// 3.1–3.4): which boosters work now and their badges.
///
/// Badges follow NestyBoard: a count while the player holds some; none in
/// the dev flavor, where boosters never run out. At 0 the design shows ▶
/// (M6) or a coin price (M3); until then the button is disabled with no
/// badge.
@immutable
final class BoosterBarModel {
  const BoosterBarModel({
    this.undoEnabled = false,
    this.undoBadge,
    this.hintEnabled = false,
    this.hintBadge,
    this.slotEnabled = false,
    this.slotBadge,
    this.restartEnabled = false,
    this.undoGlow = false,
    this.locked = false,
  });

  factory BoosterBarModel.of(GameplayState state) {
    // Won: input is locked for the winning batch and the win overlay, but
    // the bar keeps the look it had (frame 2.5 draws it at full strength
    // while the set flies) and only swallows presses ([locked]), instead
    // of flashing disabled before the scrim dims it (review FIDELITY-2).
    final won = state.status == GameplayStatus.won;
    final input = state.acceptsInput || (won && !state.paused);
    final unlimited = state.unlimitedBoosters;
    BoosterBadge? count(int n) =>
        unlimited || n <= 0 ? null : BoosterBadge.count(n);
    return BoosterBarModel(
      undoEnabled: input && state.canUndo,
      // TODO(M3): the 20-coin tag once the free undos are used (frame 3.3).
      undoBadge: count(state.freeUndosLeft),
      // Frames 3.1 and 3.4 keep Hint live while a hint shows and while the
      // level is soft stuck; a press then gives no move and charges nothing
      // (the bloc ignores it, D22).
      hintEnabled:
          (state.status == GameplayStatus.playing || won) &&
          !state.paused &&
          state.canHint,
      // TODO(M3): the coin price at 0 (frame 3.2).
      // TODO(M6): the ▶ badge at 0 while an ad is ready (frame 2.2).
      hintBadge: count(state.hintsLeft),
      slotEnabled: input && state.canAddSlot,
      slotBadge: count(state.extraSlotsLeft),
      restartEnabled: input,
      // Only an Undo that works is suggested: with nothing to undo (spec
      // §2.4 clears the history on a completion) the banner offers Restart
      // and nothing glows (review FIDELITY-6).
      undoGlow:
          state.softStuck &&
          state.status == GameplayStatus.playing &&
          state.canUndo,
      locked: won,
    );
  }

  final bool undoEnabled;
  final BoosterBadge? undoBadge;
  final bool hintEnabled;
  final BoosterBadge? hintBadge;
  final bool slotEnabled;
  final BoosterBadge? slotBadge;
  final bool restartEnabled;

  /// Frame 3.4: the soft-stuck suggestion, `ui_booster_glow` behind Undo.
  final bool undoGlow;

  /// The buttons look as the flags say but take no touch (the won level).
  final bool locked;

  @override
  bool operator ==(Object other) =>
      other is BoosterBarModel &&
      other.undoEnabled == undoEnabled &&
      other.undoBadge == undoBadge &&
      other.hintEnabled == hintEnabled &&
      other.hintBadge == hintBadge &&
      other.slotEnabled == slotEnabled &&
      other.slotBadge == slotBadge &&
      other.restartEnabled == restartEnabled &&
      other.undoGlow == undoGlow &&
      other.locked == locked;

  @override
  int get hashCode => Object.hash(
    undoEnabled,
    undoBadge,
    hintEnabled,
    hintBadge,
    slotEnabled,
    slotBadge,
    restartEnabled,
    undoGlow,
    locked,
  );
}

/// The wood bar under the board (frame 2.2; design/README.md "Booster
/// bar"): Undo, Hint, +Slot and Restart, from `H − safeBottom − 76` to the
/// bottom edge. Buttons are `min(80, (W − 56) / 4)` wide with 8 px gaps,
/// centred, 12 below the bar's top.
class BoosterBar extends StatelessWidget {
  const BoosterBar({
    required this.model,
    required this.onUndo,
    required this.onHint,
    required this.onExtraSlot,
    required this.onRestart,
    this.library,
    super.key,
  });

  final BoosterBarModel model;
  final VoidCallback onUndo;
  final VoidCallback onHint;
  final VoidCallback onExtraSlot;
  final VoidCallback onRestart;

  /// The FX library (DI by default), for the Undo glow.
  final FxLibrary? library;

  /// The +Slot glyph and label (NestyBoard `BST`).
  static const Color slotColor = Color(0xFF2F7A3E);

  /// The bar's height above the safe-area bottom.
  static const double height = BoardLayoutConstants.barTopInset;

  /// A button's width on a [screenWidth] screen.
  static double buttonWidth(double screenWidth) => math
      .min(BoosterBarTokens.buttonSize.width, (screenWidth - 56) / 4)
      .clamp(0.0, BoosterBarTokens.buttonSize.width);

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final width = buttonWidth(MediaQuery.sizeOf(context).width);
    return WoodBar(
      height: height + bottom,
      padding: EdgeInsets.only(top: BoosterBarTokens.topInset, bottom: bottom),
      child: Align(
        alignment: Alignment.topCenter,
        child: IgnorePointer(
          ignoring: model.locked,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BoosterButton(
                icon: NestyIcons.undo,
                label: l10n.boosterUndo,
                width: width,
                badge: model.undoBadge,
                onPressed: model.undoEnabled ? onUndo : null,
                glow: model.undoGlow ? BoosterGlow(library: library) : null,
              ),
              const SizedBox(width: BoosterBarTokens.gap),
              BoosterButton(
                icon: NestyIcons.lightbulb,
                label: l10n.boosterHint,
                width: width,
                badge: model.hintBadge,
                onPressed: model.hintEnabled ? onHint : null,
              ),
              const SizedBox(width: BoosterBarTokens.gap),
              BoosterButton(
                icon: NestyIcons.addBox,
                label: l10n.boosterExtraSlot,
                width: width,
                color: slotColor,
                badge: model.slotBadge,
                onPressed: model.slotEnabled ? onExtraSlot : null,
              ),
              const SizedBox(width: BoosterBarTokens.gap),
              BoosterButton(
                icon: NestyIcons.restartAlt,
                label: l10n.restart,
                width: width,
                onPressed: model.restartEnabled ? onRestart : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Frame 3.4's glowing Undo: `ui_booster_glow` looping behind the button
/// (an informational loop: 1× even under reduced motion, D48). Without the
/// file, a static gold halo (rule 3).
class BoosterGlow extends StatelessWidget {
  const BoosterGlow({this.library, super.key});

  final FxLibrary? library;

  @override
  Widget build(BuildContext context) => LottieFxView(
    id: FxId.uiBoosterGlow,
    library: library,
    fallback: const CustomPaint(painter: _StaticGlowPainter()),
  );
}

/// NestyBoard `nb-glow` at rest: a 3 px `#FFE08A` ring and a soft gold
/// bloom around the 80×58 button, centred in the 130×110 glow box.
final class _StaticGlowPainter extends CustomPainter {
  const _StaticGlowPainter();

  static final Paint _bloom = Paint()
    ..color = const Color(0x99FFCD50)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
  static final Paint _ring = Paint()..color = const Color(0xFFFFE08A);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final button = Rect.fromCenter(center: center, width: 80, height: 58);
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(button.inflate(8), const Radius.circular(24)),
        _bloom,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(button.inflate(3), const Radius.circular(21)),
        _ring,
      );
  }

  @override
  bool shouldRepaint(_StaticGlowPainter oldDelegate) => false;
}
