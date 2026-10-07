import 'dart:async';

import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
import 'package:nesty_game/core/ui/widgets/booster/bump_scale.dart';
import 'package:nesty_render/nesty_render.dart' show MotionTokens;

/// What a gift's hint or extra slot adds to (frames 13.5b, 13.5c, 13.6d).
enum GiftTallyKind { hint, slot }

/// One count in the tally: the gift's [added] and the player's new [total].
@immutable
class GiftTallyEntry {
  const GiftTallyEntry({
    required this.kind,
    required this.added,
    required this.total,
  });

  final GiftTallyKind kind;
  final int added;

  /// The player's total once the gift has landed (`gift.tally.count`).
  final int total;

  /// The count before it lands.
  int get before => total - added < 0 ? 0 : total - added;
}

/// Home's gift tally (`gift.tally`, frames 13.5b, 13.5c, 13.6d; m7-5): Home
/// has no Hint or +Slot button, so a gift's hint or extra slot flies into a
/// small pill that slides down from behind the coin pill as the sprite takes
/// off, steps its count up to the player's new total as it lands (the disc
/// bumps 1.3× with the hint ring, and a "+N" tag sits on it), holds 1.2 s
/// and slides back up. The booster itself waits in the booster bar.
///
/// It is drawn in the app's overlay, above the sheet's scrim and the
/// chest's dim (`gift.tally.layer`), and outlives whatever showed it: once
/// every entry has landed it holds, slides out and removes itself. Reduce
/// motion: no slide; it fades in over 150 ms with the new count, holds and
/// fades out (`gift.reducedMotion.claim`).
///
/// It only ever appears from a claim (the sheet's Claim, Day 7's Collect),
/// never on its own (D92).
abstract final class GiftTally {
  /// The tally's box, for tests.
  @visibleForTesting
  static const Key boxKey = Key('gift-tally');

  /// The "+N" tag, for tests.
  @visibleForTesting
  static const Key tagKey = Key('gift-tally-tag');

  /// The tag sits on the tally's top end corner: it overlaps the tally by
  /// this much and reaches above it, so it never covers the chapter card's
  /// "CHAPTER n" line beside the tally (the m7-5 check saw 13.5c's tag,
  /// drawn beside the tally, clip it).
  static const double tagOverlap = 12;

  /// How far in from the tally's end edge the tag starts.
  static const double tagInset = 16;

  /// Shows the tally under [pill] (Home's coin pill face, on screen) for
  /// [entries], each at its count before landing; null when there is no
  /// overlay. Call [GiftTallyHandle.land] as each sprite lands.
  static GiftTallyHandle? show(
    BuildContext context, {
    required Rect pill,
    required List<GiftTallyEntry> entries,
    bool? reduceMotion,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null || entries.isEmpty) return null;
    final reduce = reduceMotion ?? context.reduceMotion;
    final direction = Directionality.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    final style = _countStyle(context);
    final geometry = GiftTallyGeometry.of(
      pill: pill,
      entries: entries,
      direction: direction,
      countWidth: (total) => _measure('$total', style, scaler, direction),
    );
    final controller = _GiftTallyController(entries);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      // Above every page's Material: the body style a page's Material would
      // give it, so no text falls back to the debug underline (as the toast
      // queue does).
      builder: (context) => DefaultTextStyle(
        style: context.scriptStyle(
          AppTextStyles.bodySmall,
          role: ScriptTextRole.body,
        ),
        child: _GiftTallyLayer(
          controller: controller,
          geometry: geometry,
          entries: entries,
          reduceMotion: reduce,
          onDone: () {
            if (entry.mounted) entry.remove();
          },
        ),
      ),
    );
    overlay.insert(entry);
    return GiftTallyHandle._(entry, controller, geometry);
  }

  /// `type.gift.tally`: Fredoka 700 17/1, tabular, in the text brown.
  static TextStyle _countStyle(BuildContext context) => context.scriptStyle(
    GiftTypeTokens.tally.copyWith(color: AppColorTokens.textPrimary),
  );

  static double _measure(
    String text,
    TextStyle style,
    TextScaler scaler,
    TextDirection direction,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: direction,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final width = painter.width.ceilToDouble();
    painter.dispose();
    return width;
  }
}

/// Where the tally and its discs sit (`gift.tally`): its start edge on the
/// pill's (left 16), its top the pill's top + 54 (120 on 844, 82 on 16:9),
/// 36 tall, padding 5 at the start and 13 at the end, a 26 dp disc and the
/// count per entry, 7 apart. Each count keeps the width of its total, so
/// nothing moves as it steps up.
@immutable
class GiftTallyGeometry {
  const GiftTallyGeometry._(this.pill, this.box, this.discs, this.counts);

  factory GiftTallyGeometry.of({
    required Rect pill,
    required List<GiftTallyEntry> entries,
    required TextDirection direction,
    required double Function(int total) countWidth,
  }) {
    const pad = GiftTallyTokens.padding;
    const gap = GiftTallyTokens.gap;
    const disc = GiftTallyTokens.disc;
    const height = GiftTallyTokens.height;
    final counts = [for (final e in entries) countWidth(e.total)];
    var width = pad.left + pad.right;
    for (var i = 0; i < entries.length; i++) {
      width += disc + gap + counts[i] + (i > 0 ? gap : 0);
    }
    final top = pill.top + GiftTallyTokens.topBelowCoinPill;
    final rtl = direction == TextDirection.rtl;
    final box = rtl
        ? Rect.fromLTWH(pill.right - width, top, width, height)
        : Rect.fromLTWH(pill.left, top, width, height);
    final discs = <GiftTallyKind, Rect>{};
    var x = pad.left;
    for (var i = 0; i < entries.length; i++) {
      if (i > 0) x += gap;
      final start = rtl ? box.right - x - disc : box.left + x;
      discs[entries[i].kind] = Rect.fromLTWH(
        start,
        top + (height - disc) / 2,
        disc,
        disc,
      );
      x += disc + gap + counts[i];
    }
    return GiftTallyGeometry._(pill, box, discs, counts);
  }

  /// Home's coin pill face, which the tally slides out from behind.
  final Rect pill;

  /// The tally on screen, at rest.
  final Rect box;

  /// Each entry's disc on screen, at rest: where its sprite lands.
  final Map<GiftTallyKind, Rect> discs;

  /// Each entry's count width.
  final List<double> counts;
}

/// A tally on screen.
final class GiftTallyHandle {
  GiftTallyHandle._(this._entry, this._controller, this.geometry);

  final OverlayEntry _entry;
  final _GiftTallyController _controller;
  final GiftTallyGeometry geometry;

  /// Where [kind]'s sprite lands, or null when the tally has no such entry.
  Rect? discOf(GiftTallyKind kind) => geometry.discs[kind];

  /// [kind]'s sprite landed: its count steps up, its disc bumps and rings,
  /// and its tag shows. Once every entry has landed the tally holds and
  /// leaves by itself.
  void land(GiftTallyKind kind) => _controller.land(kind);

  /// Lands whatever hasn't landed (a flight torn down early: the gift is
  /// paid, so the new total shows).
  void landAll() {
    for (final kind in GiftTallyKind.values) {
      _controller.land(kind);
    }
  }

  /// Removes it now.
  void dispose() {
    if (_entry.mounted) _entry.remove();
  }
}

class _GiftTallyController extends ChangeNotifier {
  _GiftTallyController(this.entries);

  final List<GiftTallyEntry> entries;
  final Set<GiftTallyKind> landed = {};

  bool get allLanded => entries.every((e) => landed.contains(e.kind));

  void land(GiftTallyKind kind) {
    if (!entries.any((e) => e.kind == kind) || !landed.add(kind)) return;
    notifyListeners();
  }
}

class _GiftTallyLayer extends StatefulWidget {
  const _GiftTallyLayer({
    required this.controller,
    required this.geometry,
    required this.entries,
    required this.reduceMotion,
    required this.onDone,
  });

  final _GiftTallyController controller;
  final GiftTallyGeometry geometry;
  final List<GiftTallyEntry> entries;
  final bool reduceMotion;
  final VoidCallback onDone;

  @override
  State<_GiftTallyLayer> createState() => _GiftTallyLayerState();
}

class _GiftTallyLayerState extends State<_GiftTallyLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _show = AnimationController(
    vsync: this,
    duration: Duration(
      milliseconds: widget.reduceMotion
          ? GiftReducedMotionTokens.claimTallyFadeInMs
          : GiftTallyTokens.inMs,
    ),
    reverseDuration: Duration(
      milliseconds: widget.reduceMotion
          ? GiftReducedMotionTokens.claimTallyFadeInMs
          : GiftTallyTokens.outMs,
    ),
  );
  late final Animation<double> _slide = CurvedAnimation(
    parent: _show,
    curve: GiftTallyTokens.inCurve,
    reverseCurve: GiftTallyTokens.outCurve.flipped,
  );
  Timer? _hold;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onLand);
    unawaited(_show.forward());
    _onLand();
  }

  void _onLand() {
    if (!mounted) return;
    setState(() {});
    if (_hold != null || !widget.controller.allLanded) return;
    // Every count is up: hold, then leave (`gift.tally.holdMs`).
    _hold = Timer(const Duration(milliseconds: GiftTallyTokens.holdMs), () {
      if (!mounted) return;
      setState(() => _leaving = true);
      _show.reverse().whenComplete(widget.onDone);
    });
  }

  @override
  void dispose() {
    _hold?.cancel();
    widget.controller.removeListener(_onLand);
    _show.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final geometry = widget.geometry;
    final box = geometry.box;
    final tally = _TallyBody(
      entries: widget.entries,
      landed: widget.controller.landed,
      counts: geometry.counts,
      ringOn: !_leaving,
    );
    // The tag hangs off the tally's top end corner.
    final tagged = Stack(
      clipBehavior: Clip.none,
      children: [
        tally,
        if (widget.controller.landed.isNotEmpty)
          PositionedDirectional(
            start: box.width - GiftTally.tagInset,
            bottom: GiftTallyTokens.height - GiftTally.tagOverlap,
            child: _TallyTag(
              label: _tagLabel(context),
              reduceMotion: widget.reduceMotion,
            ),
          ),
      ],
    );
    final Widget placed;
    if (widget.reduceMotion) {
      placed = Positioned(
        left: box.left,
        top: box.top,
        child: FadeTransition(opacity: _show, child: tagged),
      );
    } else {
      // Out from behind the coin pill: the tally starts at the pill's top
      // and is clipped above the pill's bottom while it moves.
      final travel = box.top - geometry.pill.top;
      placed = AnimatedBuilder(
        animation: _slide,
        child: tagged,
        builder: (context, child) {
          final dy = -travel * (1 - _slide.value);
          final moving = _show.isAnimating || _show.value < 1;
          // One tree whether it moves or rests, so the tag's pop and the
          // disc's bump never restart; at rest the clip lets all through.
          return Positioned.fill(
            child: ClipRect(
              clipper: _BelowClipper(
                moving ? geometry.pill.bottom : double.negativeInfinity,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(left: box.left, top: box.top + dy, child: child!),
                ],
              ),
            ),
          );
        },
      );
    }
    return IgnorePointer(
      child: Stack(children: [placed, _announcement(context)]),
    );
  }

  String _tagLabel(BuildContext context) {
    final l10n = context.localizations;
    final landed = widget.entries.where(
      (e) => widget.controller.landed.contains(e.kind),
    );
    // One entry is the frames' case; a tuned track's day with both shows
    // the last that landed.
    return l10n.hintGainedTag(landed.last.added);
  }

  /// `gift_a11y_added`, read as each count lands ("1 hint added. You have
  /// 3.").
  Widget _announcement(BuildContext context) {
    final l10n = context.localizations;
    final lines = [
      for (final e in widget.entries)
        if (widget.controller.landed.contains(e.kind))
          l10n.giftA11yAdded(switch (e.kind) {
            GiftTallyKind.hint => l10n.giftHints(e.added),
            GiftTallyKind.slot => l10n.giftSlots(e.added),
          }, e.total),
    ];
    return Positioned(
      left: widget.geometry.box.left,
      top: widget.geometry.box.top,
      width: widget.geometry.box.width,
      height: widget.geometry.box.height,
      child: Semantics(
        container: true,
        liveRegion: lines.isNotEmpty,
        label: lines.isEmpty ? null : l10n.joinSentences(lines),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// Clips everything above [top] (the coin pill's bottom).
class _BelowClipper extends CustomClipper<Rect> {
  const _BelowClipper(this.top);

  final double top;

  @override
  Rect getClip(Size size) => Rect.fromLTRB(0, top, size.width, size.height);

  @override
  bool shouldReclip(_BelowClipper oldClipper) => oldClipper.top != top;
}

/// The tally's face: a disc and a count per entry.
class _TallyBody extends StatelessWidget {
  const _TallyBody({
    required this.entries,
    required this.landed,
    required this.counts,
    required this.ringOn,
  });

  final List<GiftTallyEntry> entries;
  final Set<GiftTallyKind> landed;
  final List<double> counts;
  final bool ringOn;

  static const _style = SurfaceStyle(
    gradient: GiftTallyTokens.face,
    shadows: GiftTallyTokens.shadow,
  );

  @override
  Widget build(BuildContext context) {
    const pad = GiftTallyTokens.padding;
    final style = GiftTally._countStyle(context);
    return NestySurface(
      key: GiftTally.boxKey,
      style: _style,
      radius: BorderRadius.circular(GiftTallyTokens.radius),
      height: GiftTallyTokens.height,
      padding: EdgeInsetsDirectional.fromSTEB(pad.left, 0, pad.right, 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0) const SizedBox(width: GiftTallyTokens.gap),
            _TallyDisc(
              kind: entries[i].kind,
              bump: landed.contains(entries[i].kind) ? 1 : 0,
              ring: ringOn && landed.contains(entries[i].kind),
            ),
            const SizedBox(width: GiftTallyTokens.gap),
            SizedBox(
              width: counts[i],
              child: Text(
                '${landed.contains(entries[i].kind) ? entries[i].total : entries[i].before}',
                style: style,
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A tally disc: the chest's hint chip disc, or `chip_slot.svg`
/// (`gift.tally.discs`). It bumps 1.3× over 240 ms as its sprite lands and
/// wears the hint ring (`motion.chest.collect.hintRing`) until the tally
/// leaves.
class _TallyDisc extends StatelessWidget {
  const _TallyDisc({
    required this.kind,
    required this.bump,
    required this.ring,
  });

  final GiftTallyKind kind;
  final int bump;
  final bool ring;

  static const _hintStyle = SurfaceStyle(
    gradient: GiftTallyTokens.discsHintFace,
    shadows: GiftTallyTokens.discsHintEdge,
  );

  @override
  Widget build(BuildContext context) {
    const size = GiftTallyTokens.disc;
    final disc = switch (kind) {
      GiftTallyKind.hint => const NestySurface(
        style: _hintStyle,
        radius: BorderRadius.all(Radius.circular(size / 2)),
        width: size,
        height: size,
        alignment: Alignment.center,
        child: Icon(
          IconUses.rewardHint,
          size: GiftTallyTokens.discsHintGlyphSize,
          color: GiftTallyTokens.discsHintGlyphColor,
        ),
      ),
      GiftTallyKind.slot => UiArtImage.square(UiArt.chipSlot, extent: size),
    };
    return BumpScale(
      trigger: bump,
      scale: GiftClaimTokens.hintLandBump,
      duration: const Duration(milliseconds: GiftClaimTokens.hintLandBumpMs),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          disc,
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: ring ? 1 : 0,
              duration: ring
                  ? const Duration(
                      milliseconds: ChestCollectTokens.pillRingInMs,
                    )
                  : const Duration(
                      milliseconds: ChestCollectTokens.pillRingOutMs,
                    ),
              child: const CustomPaint(painter: RingGlowPainter.hint()),
            ),
          ),
        ],
      ),
    );
  }
}

/// The green "+N" tag (`motion.chest.collect.gainTag`): it pops in with
/// `motion.tagPop`; under reduced motion it just appears.
class _TallyTag extends StatelessWidget {
  const _TallyTag({required this.label, required this.reduceMotion});

  final String label;
  final bool reduceMotion;

  static const _style = SurfaceStyle(
    color: ChestCollectTokens.gainTagFace,
    shadows: ChestCollectTokens.gainTagEdge,
  );

  @override
  Widget build(BuildContext context) {
    final tag = NestySurface(
      key: GiftTally.tagKey,
      style: _style,
      radius: BorderRadius.circular(ChestCollectTokens.gainTagRadius),
      padding: ChestCollectTokens.gainTagPadding,
      child: Text(
        label,
        maxLines: 1,
        softWrap: false,
        style: context.scriptStyle(
          ChestCollectTokens.gainTagFont.copyWith(height: 1),
        ),
      ),
    );
    if (reduceMotion) return tag;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: MotionTokens.tagPopFrom, end: 1),
      duration: const Duration(milliseconds: MotionTokens.tagPopMs),
      curve: MotionTokens.tagPopCurve,
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        alignment: AlignmentDirectional.bottomStart,
        child: child,
      ),
      child: tag,
    );
  }
}
