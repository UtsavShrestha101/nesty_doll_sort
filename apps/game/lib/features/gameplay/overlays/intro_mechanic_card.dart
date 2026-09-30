import 'package:flutter/material.dart';
import 'package:nesty_core/nesty_core.dart' show DollColor;
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/models/intro_mechanic.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';
import 'package:nesty_game/features/gameplay/game/components/board_stand_ins.dart';
import 'package:nesty_game/features/gameplay/overlays/modal_placement.dart';
import 'package:nesty_game/features/gameplay/overlays/overlay_entrance.dart';
import 'package:nesty_game/features/gameplay/widgets/lottie_doll.dart';
import 'package:nesty_render/nesty_render.dart';

/// One [IntroMechanic]'s card (frames 4.1 Towers, 4.2 Glass Cases, 4.3 Ice;
/// docs/plans/m3-design.md §10.4): the shared `IntroCard` (NEW chip, title,
/// text, "Got it") with this mechanic's illustration in its 302×230 slot,
/// at NestyOverlay `isIntro`'s place (24 from each side, top 170 on a 59
/// safe area).
///
/// The illustration is NestyOverlay's `INTRO` picture, piece by piece
/// ([IntroIllustration]; review FIDELITY-6): the level's own dolls (its
/// [skin], in [levelColors]; the placeholder doll only without one, rule 3)
/// and the real board pieces from the same skin's `BoardSprites` (tower
/// bases and the buried silhouettes, the intact and shattered glass case,
/// the ice frames), with the board's flat stand-ins while a piece is
/// unavailable. The dolls play the widget-hosted `doll_idle` loop.
///
/// With the level's skin the picture is the design's own loop (m7-3, frames
/// 4.1–4.3): `ui_intro_towers`, `ui_intro_glass` or `ui_intro_ice` in the
/// 302×230 slot, looping, its dolls and board pieces filled from the skin
/// (LOTTIE.md "Mechanic intro card"). Under reduced motion it rests on frame
/// 0. Without the file (or the skin) the still picture above stands in
/// (rule 3).
class IntroMechanicCard extends StatelessWidget {
  const IntroMechanicCard({
    required this.mechanic,
    required this.onGotIt,
    this.skin,
    this.levelColors = const [],
    this.symbols = DollSymbols.subtle,
    this.library,
    super.key,
  });

  final IntroMechanic mechanic;
  final VoidCallback onGotIt;

  /// The level's art (the page's current `LevelSkin`), or null before it
  /// has landed.
  final LevelSkin? skin;

  /// The colours [skin] holds dolls for (the level's families): a colour a
  /// skin lacks draws nothing, so the picture's dolls take these.
  final List<DollColor> levelColors;
  final DollSymbols symbols;
  final FxLibrary? library;

  /// NestyOverlay `isIntro`: `left:24px; right:24px; top:170px` on a 59
  /// safe area.
  static const double side = 24;
  static const double cardTop = 170 - 59;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final (title, text) = switch (mechanic) {
      IntroMechanic.towers => (l10n.introTowersTitle, l10n.introTowersText),
      IntroMechanic.glass => (l10n.introGlassTitle, l10n.introGlassText),
      IntroMechanic.ice => (l10n.introIceTitle, l10n.introIceText),
    };
    return OverlayEntrance(
      kind: OverlayEntranceKind.modal,
      builder: (context, progress, content) => Stack(
        fit: StackFit.expand,
        children: [
          Scrim(opacity: progress),
          ModalPlacement(cardTop: cardTop, side: side, child: content),
        ],
      ),
      child: IntroCard(
        badgeLabel: l10n.introNew,
        title: title,
        text: text,
        onGotIt: onGotIt,
        illustration: _MechanicIllustration(
          mechanic: mechanic,
          skin: skin,
          levelColors: levelColors,
          symbols: symbols,
          library: library,
        ),
      ),
    );
  }
}

/// One piece of an intro card's picture, in the 302×230 slot's own px
/// (NestyOverlay `INTRO`), drawn in list order.
@immutable
sealed class IntroPiece {
  const IntroPiece();
}

/// A board piece filling [rect] (NestyOverlay `img(src, x, y, w, h)`,
/// `center/100% 100%`).
final class IntroSpritePiece extends IntroPiece {
  const IntroSpritePiece(this.sprite, this.rect);

  final BoardSprite sprite;
  final Rect rect;

  @override
  bool operator ==(Object other) =>
      other is IntroSpritePiece && other.sprite == sprite && other.rect == rect;

  @override
  int get hashCode => Object.hash(sprite, rect);

  @override
  String toString() => 'IntroSpritePiece($sprite, $rect)';
}

/// A doll [height] tall (its whole 768-unit artboard) standing with its
/// base on ([centerX], [baseY]) (NestyOverlay `doll(c, cx, base, h)`).
final class IntroDollPiece extends IntroPiece {
  const IntroDollPiece(
    this.color, {
    required this.centerX,
    required this.baseY,
    required this.height,
  });

  /// The frame's colour; a level skin without it swaps in one of its own
  /// ([IntroIllustration.castFor]).
  final DollColor color;
  final double centerX;
  final double baseY;
  final double height;

  @override
  bool operator ==(Object other) =>
      other is IntroDollPiece &&
      other.color == color &&
      other.centerX == centerX &&
      other.baseY == baseY &&
      other.height == height;

  @override
  int get hashCode => Object.hash(color, centerX, baseY, height);

  @override
  String toString() => 'IntroDollPiece($color, $centerX, $baseY, $height)';
}

/// The before → after arrow (NestyOverlay: `arrow_forward` 34 px
/// `#C4631E` at [left], top 96).
final class IntroArrowPiece extends IntroPiece {
  const IntroArrowPiece(this.left);

  final double left;

  static const double top = 96;
  static const double size = 34;

  @override
  bool operator ==(Object other) =>
      other is IntroArrowPiece && other.left == left;

  @override
  int get hashCode => left.hashCode;

  @override
  String toString() => 'IntroArrowPiece($left)';
}

/// What a chip says (NestyOverlay `chips`).
enum IntroChipKind {
  /// The walnut "+N" tag of the nests still buried in a tower (`#7B4824`).
  buried,

  /// The unlock colour's star on the glass case (grape `#8E4EC6`).
  unlock,

  /// The cracks left on the ice (`#3E8EDE`).
  ice,
}

/// A 24 px pill chip with its top-left at [topLeft] (NestyOverlay `chips`:
/// `min-width 24; height 24; padding 0 5; radius 12; a 2 px white ring`,
/// Fredoka 700 13 white).
final class IntroChipPiece extends IntroPiece {
  const IntroChipPiece.buried(int this.count, this.topLeft)
    : kind = IntroChipKind.buried;
  const IntroChipPiece.unlock(this.topLeft)
    : kind = IntroChipKind.unlock,
      count = null;
  const IntroChipPiece.ice(int this.count, this.topLeft)
    : kind = IntroChipKind.ice;

  final IntroChipKind kind;
  final int? count;
  final Offset topLeft;

  @override
  bool operator ==(Object other) =>
      other is IntroChipPiece &&
      other.kind == kind &&
      other.count == count &&
      other.topLeft == topLeft;

  @override
  int get hashCode => Object.hash(kind, count, topLeft);

  @override
  String toString() => 'IntroChipPiece($kind, $count, $topLeft)';
}

/// NestyOverlay's `INTRO` pictures (frames 4.1–4.3), in the 302×230 slot's
/// px; `sky` is [DollColor.blue] and `leaf` [DollColor.green].
abstract final class IntroIllustration {
  /// [mechanic]'s pieces, back to front.
  static List<IntroPiece> piecesOf(IntroMechanic mechanic) =>
      switch (mechanic) {
        IntroMechanic.towers => _towers,
        IntroMechanic.glass => _glass,
        IntroMechanic.ice => _ice,
      };

  static const List<IntroPiece> _towers = [
    IntroSpritePiece(BoardSprite.towerBase, Rect.fromLTWH(26, 172, 90, 39)),
    IntroSpritePiece(
      BoardSprite.dollSilhouette,
      Rect.fromLTWH(31, 64, 80, 120),
    ),
    IntroSpritePiece(
      BoardSprite.dollSilhouette,
      Rect.fromLTWH(37, 80, 68, 102),
    ),
    IntroDollPiece(DollColor.blue, centerX: 71, baseY: 185, height: 84),
    IntroSpritePiece(BoardSprite.towerBase, Rect.fromLTWH(196, 172, 90, 39)),
    IntroSpritePiece(
      BoardSprite.dollSilhouette,
      Rect.fromLTWH(201, 64, 80, 120),
    ),
    IntroDollPiece(DollColor.green, centerX: 241, baseY: 185, height: 102),
    IntroArrowPiece(133),
    IntroChipPiece.buried(2, Offset(90, 160)),
    IntroChipPiece.buried(1, Offset(260, 160)),
  ];

  static const List<IntroPiece> _glass = [
    IntroDollPiece(DollColor.green, centerX: 72, baseY: 158, height: 86),
    IntroSpritePiece(BoardSprite.glassCase0, Rect.fromLTWH(26, 36, 92, 153)),
    IntroDollPiece(DollColor.green, centerX: 244, baseY: 172, height: 86),
    IntroSpritePiece(BoardSprite.glassCase2, Rect.fromLTWH(198, 36, 92, 153)),
    IntroArrowPiece(133),
    IntroChipPiece.unlock(Offset(128, 40)),
  ];

  static const List<IntroPiece> _ice = [
    IntroSpritePiece(BoardSprite.slotStand, Rect.fromLTWH(20, 170, 70, 26)),
    IntroDollPiece(DollColor.blue, centerX: 55, baseY: 179, height: 76),
    IntroSpritePiece(BoardSprite.ice0, Rect.fromLTWH(17, 60, 76, 127)),
    IntroSpritePiece(BoardSprite.slotStand, Rect.fromLTWH(124, 170, 70, 26)),
    IntroDollPiece(DollColor.blue, centerX: 159, baseY: 179, height: 76),
    IntroSpritePiece(BoardSprite.ice2, Rect.fromLTWH(121, 60, 76, 127)),
    IntroSpritePiece(BoardSprite.slotStand, Rect.fromLTWH(228, 170, 70, 26)),
    IntroDollPiece(DollColor.blue, centerX: 263, baseY: 179, height: 76),
    IntroSpritePiece(BoardSprite.iceShatter, Rect.fromLTWH(225, 60, 76, 127)),
    IntroChipPiece.ice(2, Offset(76, 56)),
    IntroChipPiece.ice(1, Offset(180, 56)),
  ];

  /// The colour each of the frame's [wanted] colours draws in, from the
  /// colours a level skin holds ([available]): the frame's own where the
  /// level has it, else one of the level's not used yet (else any). With
  /// nothing [available] (no skin: the placeholder draws every colour),
  /// the frame's own.
  static Map<DollColor, DollColor> castFor(
    Iterable<DollColor> wanted,
    List<DollColor> available,
  ) {
    final frame = wanted.toSet();
    if (available.isEmpty) return {for (final color in frame) color: color};
    final cast = <DollColor, DollColor>{
      for (final color in frame)
        if (available.contains(color)) color: color,
    };
    final used = cast.values.toSet();
    var next = 0;
    for (final color in frame) {
      if (cast.containsKey(color)) continue;
      final spare = available.where((c) => !used.contains(c)).firstOrNull;
      final pick = spare ?? available[next++ % available.length];
      cast[color] = pick;
      used.add(pick);
    }
    return cast;
  }
}

/// The picture at the frame's 302×230 size, scaled down (from the plank)
/// on a card narrower than the reference.
class _MechanicIllustration extends StatefulWidget {
  const _MechanicIllustration({
    required this.mechanic,
    required this.skin,
    required this.levelColors,
    required this.symbols,
    required this.library,
  });

  final IntroMechanic mechanic;
  final LevelSkin? skin;
  final List<DollColor> levelColors;
  final DollSymbols symbols;
  final FxLibrary? library;

  @override
  State<_MechanicIllustration> createState() => _MechanicIllustrationState();
}

class _MechanicIllustrationState extends State<_MechanicIllustration> {
  late LottieFxController _controller = _newController();
  bool _started = false;

  /// The loop's file for [mechanic] (`loop` marker, 240–300 frames).
  static FxId idOf(IntroMechanic mechanic) => switch (mechanic) {
    IntroMechanic.towers => FxId.uiIntroTowers,
    IntroMechanic.glass => FxId.uiIntroGlass,
    IntroMechanic.ice => FxId.uiIntroIce,
  };

  /// The colours the loop's roles draw: the frame's own where the level's
  /// skin has them, else spares from the level (`IntroIllustration.castFor`).
  LottieFxController _newController() {
    final controller = LottieFxController(idOf(widget.mechanic));
    final available = widget.skin == null
        ? const <DollColor>[]
        : widget.levelColors;
    final request = controller.images.request;
    switch (widget.mechanic) {
      case IntroMechanic.towers:
        final cast = IntroIllustration.castFor(const [
          DollColor.blue,
          DollColor.green,
        ], available);
        request
          ..mover = cast[DollColor.blue]
          ..revealed = cast[DollColor.green];
      case IntroMechanic.glass:
        final cast = IntroIllustration.castFor(const [
          DollColor.green,
          DollColor.blue,
        ], available);
        request
          ..family = cast[DollColor.green]
          ..freed = cast[DollColor.blue]
          // The padlock carries the family's colour symbol.
          ..unlockColor = cast[DollColor.green];
      case IntroMechanic.ice:
        final cast = IntroIllustration.castFor(const [
          DollColor.blue,
          DollColor.green,
          DollColor.red,
        ], available);
        request
          ..family = cast[DollColor.blue]
          ..family2 = cast[DollColor.green]
          ..freed = cast[DollColor.red];
    }
    return controller;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // Reduced motion rests on frame 0 (ambient loop, FxMotionPolicy).
    _controller.playWhole();
  }

  @override
  void didUpdateWidget(_MechanicIllustration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mechanic != widget.mechanic ||
        !identical(oldWidget.skin, widget.skin) ||
        oldWidget.levelColors != widget.levelColors) {
      final old = _controller;
      _controller = _newController()..playWhole();
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = _StillIllustration(
      mechanic: widget.mechanic,
      skin: widget.skin,
      levelColors: widget.levelColors,
      symbols: widget.symbols,
      library: widget.library,
    );
    final skin = widget.skin;
    return ExcludeSemantics(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.bottomCenter,
        child: SizedBox.fromSize(
          size: IntroCard.illustrationSize,
          child: skin == null
              ? still
              : LottieFxView(
                  id: idOf(widget.mechanic),
                  controller: _controller,
                  library: widget.library,
                  images: skin.images,
                  fallback: still,
                ),
        ),
      ),
    );
  }
}

/// The still picture (NestyOverlay `INTRO`) at the frame's 302×230 size:
/// the stand-in while the loop or the skin isn't there (rule 3).
class _StillIllustration extends StatelessWidget {
  const _StillIllustration({
    required this.mechanic,
    required this.skin,
    required this.levelColors,
    required this.symbols,
    required this.library,
  });

  final IntroMechanic mechanic;
  final LevelSkin? skin;
  final List<DollColor> levelColors;
  final DollSymbols symbols;
  final FxLibrary? library;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final skin = this.skin;
    final pieces = IntroIllustration.piecesOf(mechanic);
    final cast = IntroIllustration.castFor([
      for (final piece in pieces)
        if (piece case IntroDollPiece(:final color)) color,
    ], skin == null ? const [] : levelColors);
    return SizedBox.fromSize(
      size: IntroCard.illustrationSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final piece in pieces)
            switch (piece) {
              IntroSpritePiece(:final sprite, :final rect) =>
                Positioned.fromRect(
                  rect: rect,
                  child: CustomPaint(
                    painter: _SpritePainter(sprite, skin?.sprites),
                  ),
                ),
              IntroDollPiece(
                :final color,
                :final centerX,
                :final baseY,
                :final height,
              ) =>
                LottieDoll.positioned(
                  centerX: centerX,
                  baseY: baseY,
                  doll: LottieDoll(
                    id: FxId.dollIdle,
                    color: cast[color] ?? color,
                    height: height,
                    images: skin?.images,
                    renderer: skin?.restRenderer,
                    symbols: symbols,
                    library: library,
                  ),
                ),
              IntroArrowPiece(:final left) => Positioned(
                left: left,
                top: IntroArrowPiece.top,
                child: const Icon(
                  NestyIcons.arrowForward,
                  size: IntroArrowPiece.size,
                  color: AppColorTokens.primaryEdge,
                ),
              ),
              IntroChipPiece(:final kind, :final count, :final topLeft) =>
                Positioned(
                  left: topLeft.dx,
                  top: topLeft.dy,
                  child: _Chip(
                    color: switch (kind) {
                      IntroChipKind.buried => AppColorTokens.walnut,
                      IntroChipKind.unlock => DollPalette.of(
                        DollColor.purple,
                      ).base,
                      IntroChipKind.ice => AppColorTokens.ice,
                    },
                    child: switch (kind) {
                      IntroChipKind.buried => _chipText(
                        l10n.introTowersBuriedTag(count ?? 0),
                      ),
                      IntroChipKind.ice => _chipText(
                        l10n.introIceCount(count ?? 0),
                      ),
                      IntroChipKind.unlock => const Icon(
                        NestyIcons.star,
                        size: 14,
                        color: Colors.white,
                      ),
                    },
                  ),
                ),
            },
        ],
      ),
    );
  }

  static Widget _chipText(String text) => Text(
    text,
    textScaler: TextScaler.noScaling,
    style: AppTextStyleTokens.tierChip.copyWith(
      fontSize: 13,
      height: 1,
      color: Colors.white,
    ),
  );
}

/// A board piece from the level skin's [sprites] at the size it is drawn
/// (rasterized on first use, then repainted when it lands), or the
/// board's flat stand-in without it (rule 3).
final class _SpritePainter extends CustomPainter {
  _SpritePainter(this.sprite, this.sprites) : super(repaint: sprites);

  final BoardSprite sprite;
  final BoardSprites? sprites;

  static final Paint _glass = Paint()..color = BoardStandIns.glass;
  static final Paint _ice = Paint()..color = BoardStandIns.ice;
  static final Paint _stand = Paint()..color = BoardStandIns.stand;

  @override
  void paint(Canvas canvas, Size size) {
    final box = Offset.zero & size;
    final image = sprites?.image(sprite, size.width / sprite.designSize.width);
    if (image != null) {
      image.draw(canvas, box);
      return;
    }
    final standIn = switch (sprite) {
      BoardSprite.glassCase0 ||
      BoardSprite.glassCase1 ||
      BoardSprite.glassCase2 ||
      BoardSprite.glassCaseTall0 ||
      BoardSprite.glassCaseTall1 ||
      BoardSprite.glassCaseTall2 => _glass,
      BoardSprite.ice0 ||
      BoardSprite.ice1 ||
      BoardSprite.ice2 ||
      BoardSprite.ice3 ||
      BoardSprite.iceShatter => _ice,
      BoardSprite.slotStand ||
      BoardSprite.towerBase ||
      BoardSprite.extraSlot => _stand,
      // A buried nest's blank and the rest have no stand-in.
      BoardSprite.dollSilhouette ||
      BoardSprite.shelfPlank ||
      BoardSprite.glowRing ||
      BoardSprite.hintArrow => null,
    };
    if (standIn == null) return;
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, Radius.circular(size.shortestSide * 0.12)),
      standIn,
    );
  }

  @override
  bool shouldRepaint(_SpritePainter oldDelegate) =>
      oldDelegate.sprite != sprite || !identical(oldDelegate.sprites, sprites);
}

/// NestyOverlay `chips`: a 24 px pill, 5 px side padding, radius 12, a
/// 2 px white ring outside it.
class _Chip extends StatelessWidget {
  const _Chip({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
    height: 24,
    padding: const EdgeInsets.symmetric(horizontal: 5),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      boxShadow: const [BoxShadow(color: Colors.white, spreadRadius: 2)],
    ),
    child: child,
  );
}
