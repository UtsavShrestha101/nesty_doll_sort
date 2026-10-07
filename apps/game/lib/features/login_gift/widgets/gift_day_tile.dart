import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:intl/intl.dart';

import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/services/login_gift/login_gift_reward.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
import 'package:nesty_game/features/login_gift/cubit/login_gift_cubit.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_metrics.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_reward_label.dart';
import 'package:nesty_render/nesty_render.dart' show MotionTokens;

/// One day of the daily gift's track (frames 13.3–13.8; `gift.tile`): "Day
/// N" and what the day pays, in full before any claim (spec-prop 1.1 rule
/// 2), in one of three looks:
///
/// - done: sunk (`#FCEBD0`, an inner shadow), the gift at half strength and
///   a green check on its corner (never a lock or a cross);
/// - today: cream with a 3 dp orange ring (the Claim colour), lifted 2 dp;
/// - later: a plain white tile, never greyed and never locked.
///
/// Days 1–6 show their gift's art and amount (`ui/sprites/coin_flight.svg`,
/// `hint_flight.svg`; a slot day, which only a tuned track has, shows
/// `slot_flight.svg`). [wide] is Day 7's tile (`gift.sheet.day7`): the
/// closed chest and both rewards as chips, in the same looks.
///
/// When the state changes (the claim), the tile sinks to its new look over
/// `gift.claim.tile` (160 ms) and the check pops with `motion.tagPop`;
/// under reduce motion the two looks cross-fade over 200 ms
/// (`gift.reducedMotion.claim`). One screen-reader node reads "Day N, gift.
/// State".
class GiftDayTile extends StatefulWidget {
  const GiftDayTile({
    required this.day,
    required this.reward,
    required this.tileState,
    this.metrics,
    this.wide = false,
    this.uiArt,
    super.key,
  });

  final int day;
  final LoginGiftReward reward;
  final GiftTileState tileState;

  /// The screen's sizes (the sheet passes its own); null reads them.
  final GiftSheetMetrics? metrics;
  final bool wide;
  final UiArtLibrary? uiArt;

  /// The done check, for tests.
  @visibleForTesting
  static const Key checkKey = Key('gift-tile-check');

  /// The tile's face (the look it rests in), for tests.
  @visibleForTesting
  static const Key faceKey = Key('gift-tile-face');

  /// Each look's surface (`gift.tile.done`, `.today`, `.later`).
  static SurfaceStyle styleOf(GiftTileState state) => switch (state) {
    GiftTileState.done => const SurfaceStyle(
      color: GiftTileTokens.doneFace,
      shadows: GiftTileTokens.doneShadow,
    ),
    GiftTileState.today => const SurfaceStyle(
      color: GiftTileTokens.todayFace,
      shadows: GiftTileTokens.todayShadow,
    ),
    GiftTileState.later => const SurfaceStyle(
      color: GiftTileTokens.laterFace,
      shadows: GiftTileTokens.laterShadow,
    ),
  };

  static Color labelOf(GiftTileState state) => switch (state) {
    GiftTileState.done => GiftTileTokens.doneLabel,
    GiftTileState.today => GiftTileTokens.todayLabel,
    GiftTileState.later => GiftTileTokens.laterLabel,
  };

  static double contentOpacityOf(GiftTileState state) => switch (state) {
    GiftTileState.done => GiftTileTokens.doneContentOpacity,
    GiftTileState.today ||
    GiftTileState.later => GiftTileTokens.laterContentOpacity,
  };

  static double liftOf(GiftTileState state) =>
      state == GiftTileState.today ? GiftTileTokens.todayLift : 0;

  @override
  State<GiftDayTile> createState() => _GiftDayTileState();
}

class _GiftDayTileState extends State<GiftDayTile>
    with TickerProviderStateMixin {
  late GiftTileState _from = widget.tileState;
  late final AnimationController _change = AnimationController(
    vsync: this,
    value: 1,
  );
  late final AnimationController _checkPop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: MotionTokens.tagPopMs),
    value: 1,
  );

  @override
  void didUpdateWidget(GiftDayTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tileState == widget.tileState) return;
    _from = oldWidget.tileState;
    final reduce = context.reduceMotion;
    _change.duration = Duration(
      milliseconds: reduce
          ? GiftReducedMotionTokens.claimCrossFadeMs
          : GiftClaimTokens.tileSinkMs,
    );
    unawaited(_change.forward(from: 0));
    if (widget.tileState == GiftTileState.done && !reduce) {
      unawaited(_checkPop.forward(from: 0));
    }
  }

  @override
  void dispose() {
    _change.dispose();
    _checkPop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final stateLabel = switch (widget.tileState) {
      GiftTileState.done => l10n.giftTileDone,
      GiftTileState.today => l10n.giftTileToday,
      GiftTileState.later => l10n.giftTileLater,
    };
    final metrics = widget.metrics ?? GiftSheetMetrics.of(context);
    return Semantics(
      container: true,
      label: l10n.giftTileSemantics(
        widget.day,
        giftRewardSemantics(l10n, widget.reward),
        stateLabel,
      ),
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: Listenable.merge([_change, _checkPop]),
          builder: (context, _) => _tile(context, metrics),
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, GiftSheetMetrics metrics) {
    final to = widget.tileState;
    final t = Curves.easeOut.transform(_change.value);
    final from = t >= 1 ? to : _from;
    final radius = BorderRadius.circular(
      widget.wide ? GiftSheetTokens.day7Radius : GiftTileTokens.radius,
    );
    Widget face(GiftTileState state, {Key? key}) => NestySurface(
      key: key,
      style: GiftDayTile.styleOf(state),
      radius: radius,
    );
    final label = Color.lerp(
      GiftDayTile.labelOf(from),
      GiftDayTile.labelOf(to),
      t,
    )!;
    final content = lerpDouble(
      GiftDayTile.contentOpacityOf(from),
      GiftDayTile.contentOpacityOf(to),
      t,
    )!;
    final lift = lerpDouble(
      GiftDayTile.liftOf(from),
      GiftDayTile.liftOf(to),
      t,
    )!;
    final checkOpacity = switch ((from, to)) {
      (GiftTileState.done, GiftTileState.done) => 1.0,
      (_, GiftTileState.done) => t,
      (GiftTileState.done, _) => 1 - t,
      _ => 0.0,
    };
    final body = widget.wide
        ? _wide(context, metrics, label, content)
        : _narrow(context, metrics, label, content);
    return Transform.translate(
      offset: Offset(0, lift),
      child: ConstrainedBox(
        constraints: widget.wide
            ? BoxConstraints(minHeight: metrics.day7Height)
            : BoxConstraints.tightFor(height: metrics.tileHeight),
        // Day 7's content is centred in its height, as the frame's flex
        // row is (`align-items: center`).
        child: Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            if (from != to)
              Positioned.fill(
                child: Opacity(opacity: 1 - t, child: face(from)),
              ),
            Positioned.fill(
              child: from == to
                  ? face(to, key: GiftDayTile.faceKey)
                  : Opacity(
                      opacity: t,
                      child: face(to, key: GiftDayTile.faceKey),
                    ),
            ),
            body,
            if (checkOpacity > 0)
              PositionedDirectional(
                top: widget.wide ? 9 : GiftTileTokens.doneCheckTop,
                end: widget.wide ? 10 : GiftTileTokens.doneCheckRight,
                child: Opacity(
                  opacity: checkOpacity,
                  child: Transform.scale(
                    scale: _checkPop.isAnimating || _checkPop.value < 1
                        ? MotionTokens.tagPopFrom +
                              (1 - MotionTokens.tagPopFrom) *
                                  MotionTokens.tagPopCurve.transform(
                                    _checkPop.value,
                                  )
                        : 1,
                    child: const _Check(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// "Day N" (`type.gift.dayLabel`): one line, clear of the check's corner.
  Widget _label(BuildContext context, Color color, {required double endGap}) =>
      Padding(
        padding: EdgeInsetsDirectional.only(end: endGap),
        child: FitText(
          context.localizations.giftDay(widget.day),
          alignment: AlignmentDirectional.centerStart,
          textAlign: TextAlign.start,
          style: GiftTypeTokens.dayLabel.copyWith(color: color),
        ),
      );

  /// Days 1–6 (`gift.tile`): the label, then the art and the amount centred
  /// in the rest ([_TileRewards]).
  Widget _narrow(
    BuildContext context,
    GiftSheetMetrics metrics,
    Color label,
    double content,
  ) {
    const pad = GiftTileTokens.padding;
    // The check sits 8 from the end and is 22 wide: the label keeps clear.
    final checkGap =
        GiftTileTokens.doneCheckRight +
        GiftTileTokens.doneCheckSize -
        GiftTileTokens.padding.right +
        4;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        pad.left,
        pad.top,
        pad.right,
        pad.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label(context, label, endGap: checkGap),
          Expanded(
            child: Opacity(
              opacity: content,
              child: _TileRewards(
                rewards: [for (final kind in _kinds) (kind, _countOf(kind))],
                art: metrics.art,
                amountSize: metrics.amountSize,
                uiArt: widget.uiArt,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_Kind> get _kinds => [
    if (widget.reward.coins > 0) _Kind.coin,
    if (widget.reward.hints > 0) _Kind.hint,
    if (widget.reward.slots > 0) _Kind.slot,
  ];

  int _countOf(_Kind kind) => switch (kind) {
    _Kind.coin => widget.reward.coins,
    _Kind.hint => widget.reward.hints,
    _Kind.slot => widget.reward.slots,
  };

  /// Day 7 (`gift.sheet.day7`): the chest, then "Day 7" over the rewards as
  /// chips, which wrap to two rows when they don't fit side by side; the
  /// slot chip falls back to "+1" when it alone is too wide (copy.md "Short
  /// forms").
  Widget _wide(
    BuildContext context,
    GiftSheetMetrics metrics,
    Color label,
    double content,
  ) {
    const pad = GiftSheetTokens.day7Padding;
    final chest = metrics.day7Chest;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        pad.left,
        pad.top,
        pad.right,
        pad.bottom,
      ),
      child: Row(
        children: [
          Opacity(
            opacity: content,
            child: UiArtImage(
              UiArt.chestClosed,
              size: chest,
              library: widget.uiArt,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The check (10 from the end, 22 wide) sits over the
                // padding's corner, so only part of it reaches the label.
                _label(context, label, endGap: 22),
                const SizedBox(height: 7),
                Opacity(opacity: content, child: _chips(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chips(BuildContext context) {
    final l10n = context.localizations;
    final reward = widget.reward;
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        return Wrap(
          spacing: GiftSheetTokens.day7ChipsGap,
          runSpacing: GiftSheetTokens.day7ChipsGap,
          children: [
            if (reward.coins > 0)
              GiftChip(
                kind: GiftChipKind.coin,
                label: l10n.chestContentsCoins(reward.coins),
                maxWidth: maxWidth,
                uiArt: widget.uiArt,
              ),
            if (reward.hints > 0)
              GiftChip(
                kind: GiftChipKind.hint,
                label: l10n.chestContentsHint(reward.hints),
                maxWidth: maxWidth,
                uiArt: widget.uiArt,
              ),
            if (reward.slots > 0)
              GiftChip(
                kind: GiftChipKind.slot,
                label: l10n.chestContentsSlot(reward.slots),
                short: l10n.chestContentsSlotShort(reward.slots),
                maxWidth: maxWidth,
                uiArt: widget.uiArt,
              ),
          ],
        );
      },
    );
  }
}

enum _Kind { coin, hint, slot }

/// A tile's gift: its art and its amount (`type.gift.amount`, tabular),
/// side by side as the frames draw them. The amount is never scaled down
/// (`textFit.giftSheet`: "tile amounts never scale"); when a tuned track's
/// number doesn't fit the tile, the tile's own rule takes over, in order:
///
/// 1. the art steps above the amount (the art shrinks, the text doesn't);
/// 2. the amount takes the locale's compact form (intl: "100K", "10万",
///    "100 mil"); the tile's screen-reader label keeps the exact amount;
/// 3. the art shrinks beside the amount, down to 16 dp.
///
/// Two rewards on one day (only a tuned track has them) stack a line each,
/// their art no taller than its share. A last `FittedBox` is only a guard
/// for a number no tile could hold even compact (a 6-digit amount in a
/// locale whose compact form keeps every digit, at 1.3× text on 360 dp).
class _TileRewards extends StatelessWidget {
  const _TileRewards({
    required this.rewards,
    required this.art,
    required this.amountSize,
    this.uiArt,
  });

  final List<(_Kind, int)> rewards;
  final double art;
  final double amountSize;
  final UiArtLibrary? uiArt;

  /// The smallest the art shrinks to, and the gap under it when stacked.
  static const double _minArt = 16;
  static const double _stackGap = 2;

  @override
  Widget build(BuildContext context) {
    final style = context.scriptStyle(
      GiftTypeTokens.amount.copyWith(
        fontSize: amountSize,
        color: AppColorTokens.textPrimary,
      ),
    );
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    final merged = DefaultTextStyle.of(context).style.merge(style);
    Size measure(String text) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: merged),
        textDirection: direction,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      final size = painter.size;
      painter.dispose();
      return size;
    }

    final compact = _compactFormat(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        const gap = GiftTileTokens.artGap;
        Widget line(_Kind kind, String text, double artSize) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _art(kind, artSize),
            const SizedBox(width: gap),
            Text(text, maxLines: 1, softWrap: false, style: style),
          ],
        );
        final Widget laid;
        if (rewards.length == 1) {
          final (kind, count) = rewards.single;
          var text = '$count';
          var size = measure(text);
          if (art + gap + size.width <= width) {
            // The frames' tile.
            laid = line(kind, text, art);
          } else {
            if (size.width > width) {
              final short = compact(count);
              final shortSize = measure(short);
              if (shortSize.width < size.width) {
                text = short;
                size = shortSize;
              }
            }
            final stackedArt = height - size.height - _stackGap;
            // Stacked whenever the height allows: beside the art, a number
            // too wide for the tile would only get wider.
            final besideFits = _minArt + gap + size.width <= width;
            if (stackedArt >= _minArt && (size.width <= width || !besideFits)) {
              laid = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _art(kind, stackedArt < art ? stackedArt : art),
                  const SizedBox(height: _stackGap),
                  Text(text, maxLines: 1, softWrap: false, style: style),
                ],
              );
            } else {
              final besideArt = (width - gap - size.width).clamp(_minArt, art);
              laid = line(kind, text, besideArt);
            }
          }
        } else {
          // A line each, the art no taller than its share of the height.
          final share =
              (height - _stackGap * (rewards.length - 1)) / rewards.length;
          final lineArt = share.clamp(_minArt, art);
          laid = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (i, (kind, count)) in rewards.indexed) ...[
                if (i > 0) const SizedBox(height: _stackGap),
                () {
                  var text = '$count';
                  if (lineArt + gap + measure(text).width > width) {
                    final short = compact(count);
                    if (measure(short).width < measure(text).width) {
                      text = short;
                    }
                  }
                  return line(kind, text, lineArt);
                }(),
              ],
            ],
          );
        }
        return Center(
          child: FittedBox(fit: BoxFit.scaleDown, child: laid),
        );
      },
    );
  }

  Widget _art(_Kind kind, double size) => UiArtImage.square(
    switch (kind) {
      _Kind.coin => UiArt.coinFlight,
      _Kind.hint => UiArt.hintFlight,
      _Kind.slot => UiArt.slotFlight,
    },
    extent: size,
    library: uiArt,
  );

  /// The locale's compact number (intl `NumberFormat.compact`), or the
  /// plain number where intl has no data for it.
  static String Function(int) _compactFormat(BuildContext context) {
    final tag = Intl.canonicalizedLocale(
      Localizations.maybeLocaleOf(context)?.toString() ?? 'en',
    );
    final locale = NumberFormat.localeExists(tag)
        ? tag
        : (NumberFormat.localeExists(tag.split('_').first)
              ? tag.split('_').first
              : null);
    if (locale == null) return (count) => '$count';
    final format = NumberFormat.compact(locale: locale);
    return format.format;
  }
}

/// Which reward a [GiftChip] holds.
enum GiftChipKind { coin, hint, slot }

/// One of Day 7's chips on its tile (`gift.sheet.day7.chips`): 32 tall,
/// radius 16, a 24 dp disc, then the reward (`type.gift.chip`) on `#FFFDF7`
/// with a 1.5 dp `#EAD3B0` ring. [short] (the slot chip's "+1") takes over
/// when the full label doesn't fit [maxWidth] at textFit.chestChips' 0.85.
class GiftChip extends StatelessWidget {
  const GiftChip({
    required this.kind,
    required this.label,
    required this.maxWidth,
    this.short,
    this.uiArt,
    super.key,
  });

  final GiftChipKind kind;
  final String label;
  final String? short;
  final double maxWidth;
  final UiArtLibrary? uiArt;

  static const _style = SurfaceStyle(
    color: GiftSheetTokens.day7ChipsFace,
    shadows: GiftSheetTokens.day7ChipsRing,
  );

  /// The chip's padding: 4 before the disc, 12 after the text.
  static const double _start = 4;
  static const double _end = 12;

  @override
  Widget build(BuildContext context) {
    const icon = GiftSheetTokens.day7ChipsIcon;
    const gap = GiftSheetTokens.day7ChipsGap;
    final style = context.scriptStyle(GiftTypeTokens.chip);
    final room = maxWidth - _start - icon - gap - _end;
    final shown = FitText.pick(
      full: label,
      short: short,
      style: DefaultTextStyle.of(context).style.merge(style),
      maxWidth: room,
      scaler: MediaQuery.textScalerOf(context),
      direction: Directionality.of(context),
      minScale: TextFitTokens.chestChipsMinScale,
    );
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth.isFinite ? maxWidth : 1e6),
      child: NestySurface(
        style: _style,
        radius: BorderRadius.circular(GiftSheetTokens.day7ChipsRadius),
        height: GiftSheetTokens.day7ChipsHeight,
        padding: const EdgeInsetsDirectional.fromSTEB(_start, 0, _end, 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            switch (kind) {
              GiftChipKind.coin => UiArtImage.square(
                UiArt.coinFlight,
                extent: icon,
                library: uiArt,
              ),
              GiftChipKind.hint => UiArtImage.square(
                UiArt.hintFlight,
                extent: icon,
                library: uiArt,
              ),
              GiftChipKind.slot => UiArtImage.square(
                UiArt.chipSlot,
                extent: icon,
                library: uiArt,
              ),
            },
            const SizedBox(width: gap),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(shown, maxLines: 1, softWrap: false, style: style),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The done check (`gift.tile.done.check`): a 22 dp green disc with its
/// bottom shade and a white `check`.
class _Check extends StatelessWidget {
  const _Check();

  static const _style = SurfaceStyle(
    color: GiftTileTokens.doneCheckFace,
    shadows: GiftTileTokens.doneCheckEdge,
  );

  @override
  Widget build(BuildContext context) => const NestySurface(
    key: GiftDayTile.checkKey,
    style: _style,
    radius: BorderRadius.all(Radius.circular(GiftTileTokens.doneCheckSize / 2)),
    width: GiftTileTokens.doneCheckSize,
    height: GiftTileTokens.doneCheckSize,
    alignment: Alignment.center,
    // The icon font is cut at weight 600 (AppFontTokens.iconWeight); the
    // frame's wght 700 check draws at 600 (A1's note).
    child: Icon(
      IconUses.giftDayDone,
      size: GiftTileTokens.doneCheckGlyphSize,
      color: GiftTileTokens.doneCheckGlyphColor,
    ),
  );
}
