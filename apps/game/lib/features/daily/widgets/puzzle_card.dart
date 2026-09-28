import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:intl/intl.dart';
import 'package:nesty_core/nesty_core.dart' show DollColor;
import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/daily/cubit/daily_cubit.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/fx_spinner.dart';
import 'package:nesty_game/features/shop/widgets/skin_doll_row.dart';
import 'package:nesty_render/nesty_render.dart' show DollArt, DollSymbols;

/// The Daily puzzle card (frame 5.1: date title, "5 colors · Hard", a
/// preview, Play with a coin chip; frames 5.4/5.5's solved variants,
/// m3-design §8.4).
///
/// The preview reads [SkinService], [DatabaseService] (the symbols mode)
/// and [FxLibrary] from the tree (`DailyPage.wrappedRoute`).
class PuzzleCard extends StatelessWidget {
  const PuzzleCard({
    required this.state,
    required this.onPlay,
    required this.onPlayCampaign,
    super.key,
  });

  final DailyState state;
  final VoidCallback onPlay;
  final VoidCallback onPlayCampaign;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final status = state.status;
    final weekday = DateFormat.EEEE(
      Localizations.localeOf(context).toString(),
    ).format(status.today.startOfDay);
    return NestySurface(
      style: const SurfaceStyle(
        gradient: AppGradientTokens.surface,
        shadows: [
          NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
          NestyShadow(color: AppColorTokens.surfaceEdge, dy: 6),
        ],
      ),
      radius: const BorderRadius.all(Radius.circular(26)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.dailyPuzzleTitle(weekday),
                  style: AppTextStyleTokens.cardTitle.copyWith(fontSize: 20),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _InfoChip(
                text: l10n.dailyPuzzleInfo(
                  status.colors,
                  l10n.tierName(status.tier.id),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _Preview(state: state),
          const SizedBox(height: 14),
          if (status.solvedToday)
            _SolvedFooter(state: state, onPlayCampaign: onPlayCampaign)
          else
            _PlayButton(coins: state.rewardCoins, onPressed: onPlay),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xFFF1E1C6),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      child: Text(
        text,
        style: AppTextStyleTokens.tierChip.copyWith(
          fontSize: 12,
          color: AppColors.textBrown,
        ),
        maxLines: 1,
        softWrap: false,
      ),
    ),
  );
}

/// Frame 5.1's 120 px preview: today's colours on a plank, drawn in the
/// equipped skin's art (`SkinService.prepareShowcase`, rasterized once per
/// set of colours and released when it changes or the card goes away).
/// The spinner shows until both the colours and the art are ready; a skin
/// that can't be prepared draws the placeholder dolls (rule 3).
class _Preview extends StatefulWidget {
  const _Preview({required this.state});

  final DailyState state;

  @override
  State<_Preview> createState() => _PreviewState();
}

class _PreviewState extends State<_Preview> {
  /// The colours [_art] was prepared for; null before the first request.
  List<DollColor>? _preparedFor;
  LevelSkin? _art;
  bool _preparing = false;

  /// Bumped by every new request, so a stale one's art is released on
  /// arrival instead of shown.
  int _request = 0;

  List<DollColor>? get _colors => widget.state.previewColors
      ?.take(_DollRow.maxDolls)
      .toList(growable: false);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prepareIfNeeded();
  }

  @override
  void didUpdateWidget(_Preview oldWidget) {
    super.didUpdateWidget(oldWidget);
    _prepareIfNeeded();
  }

  void _prepareIfNeeded() {
    final colors = _colors;
    if (listEquals(colors, _preparedFor)) return;
    _preparedFor = colors;
    _releaseArt();
    final request = ++_request;
    if (colors == null) {
      _preparing = false;
      return;
    }
    _preparing = true;
    final skins = context.read<SkinService>();
    final symbols = context.read<DatabaseService>().symbolsMode.dollSymbols;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    unawaited(
      skins
          .prepareShowcase(
            colors: colors,
            devicePixelRatio: dpr,
            symbols: symbols,
          )
          .then((art) {
            if (!mounted || request != _request) {
              art?.dispose();
              return;
            }
            setState(() {
              _art = art;
              _preparing = false;
            });
          }),
    );
  }

  void _releaseArt() {
    _art?.dispose();
    _art = null;
  }

  @override
  void dispose() {
    _request++;
    _releaseArt();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final state = widget.state;
    final colors = _colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 120,
        child: DecoratedBox(
          // TODO(M7): the frame draws the chapter background
          // (`backgrounds/ch3-seaside-market.svg`, center 42%/cover) under
          // the plank; `SkinService.background` is the one full-screen
          // raster, so this card keeps the flat fallback for now.
          decoration: const BoxDecoration(color: Color(0xFFF3E6CF)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const PositionedDirectional(
                start: 0,
                end: 0,
                bottom: 6,
                child: PlankStrip(height: 22),
              ),
              if (colors != null && !_preparing)
                _DollRow(
                  colors: colors,
                  skin: _art,
                  symbols: context
                      .read<DatabaseService>()
                      .symbolsMode
                      .dollSymbols,
                )
              else if (!state.previewFailed)
                const Center(child: FxSpinner()),
              if (state.status.solvedToday)
                Positioned.fill(
                  child: ColoredBox(
                    color: const Color(0xB8FFF9EC),
                    child: Center(
                      child: _SolvedChip(
                        label: l10n.dailySolvedChip(state.rewardCoins),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// NestyMenus `dailyDolls`: a bottom-aligned `space-around` row inside
/// 14 px of padding, each doll at the frame's height (cycling past the
/// fifth). Six dolls (a hard daily) shrink together to fit a small phone.
class _DollRow extends StatelessWidget {
  const _DollRow({
    required this.colors,
    required this.skin,
    required this.symbols,
  });

  final List<DollColor> colors;
  final LevelSkin? skin;
  final DollSymbols symbols;

  /// A daily has at most 6 colours (the curve's 31–50 stage).
  static const int maxDolls = 6;

  /// The frame's heights, in order.
  static const List<double> heights = [74, 58, 86, 48, 66];

  static const double _padding = 14;
  static const double _minGap = 4;

  /// The frame's row sits 20 px up; the doll's base is 26/768 of its
  /// height above its box's bottom (`DollArt.base`), about 2 px here.
  static const double _baseFromBottom = 22;

  @override
  Widget build(BuildContext context) => Positioned(
    left: _padding,
    right: _padding,
    top: 0,
    bottom: _baseFromBottom,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final n = colors.length;
        var dollHeights = [for (var i = 0; i < n; i++) heights[i % 5]];
        double widthOf(double h) => h * DollArt.width / DollArt.height;
        var dollsWidth = dollHeights.fold<double>(0, (w, h) => w + widthOf(h));
        final room = constraints.maxWidth - _minGap * (n - 1);
        if (dollsWidth > room && dollsWidth > 0) {
          final scale = math.max(0, room) / dollsWidth;
          dollHeights = [for (final h in dollHeights) h * scale];
          dollsWidth *= scale;
        }
        // Centred with a gap of free/n is exactly CSS `space-around`.
        final gap = math.max(
          _minGap,
          (constraints.maxWidth - dollsWidth) / math.max(1, n),
        );
        return SkinDollRow(
          colors: colors,
          heights: dollHeights,
          skin: skin,
          gap: gap,
          symbols: symbols,
          library: context.read<FxLibrary>(),
        );
      },
    ),
  );
}

class _SolvedChip extends StatelessWidget {
  const _SolvedChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColorTokens.success,
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [
        BoxShadow(color: AppColorTokens.successEdge, offset: Offset(0, 4)),
      ],
    ),
    child: Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(9, 9, 16, 9),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox.square(
            dimension: 28,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                NestyIcons.check,
                size: 20,
                color: AppColorTokens.success,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyleTokens.cardTitle.copyWith(
              fontSize: 18,
              color: const Color(0xFFFFFFFF),
            ),
          ),
        ],
      ),
    ),
  );
}

/// The frame 5.1 Play button: the play triangle and "Play" on the left, a
/// translucent coin chip trailing it. [TactileButton] has no trailing
/// slot, so this composes [TactileSurface] directly.
class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.coins, required this.onPressed});

  final int coins;
  final VoidCallback onPressed;

  static const _white = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return TactileSurface(
      style: TactileButtonVariant.primary.surface(6),
      radius: BorderRadius.circular(22),
      onPressed: onPressed,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      semanticLabel: l10n.dailyPlaySemantics(coins),
      excludeChildSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(NestyIcons.playArrow, size: 22, color: _white),
          const SizedBox(width: 10),
          Text(
            l10n.dailyPlay,
            style: AppTextStyleTokens.button.copyWith(
              fontSize: 22,
              color: _white,
              shadows: const [
                Shadow(color: Color(0x59963C0A), offset: Offset(0, 2)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0x38FFFFFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 9, 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CoinIcon(size: 18),
                  const SizedBox(width: 4),
                  NestyNumberText(
                    coins,
                    style: AppTextStyleTokens.number.copyWith(
                      fontSize: 15,
                      color: _white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SolvedFooter extends StatelessWidget {
  const _SolvedFooter({required this.state, required this.onPlayCampaign});

  final DailyState state;
  final VoidCallback onPlayCampaign;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final until = state.untilNextPuzzle ?? Duration.zero;
    final time = l10n.dailyCountdown(
      until.inHours,
      until.inMinutes.remainder(60),
    );
    return Column(
      children: [
        Text(
          l10n.dailyNextPuzzle(time),
          style: AppTextStyleTokens.cardTitle.copyWith(
            fontSize: 15,
            color: AppColors.textBrown,
          ),
        ),
        const SizedBox(height: 12),
        TactileButton(
          label: l10n.playLevel(state.homeLevelNumber),
          onPressed: onPlayCampaign,
          variant: TactileButtonVariant.secondary,
          icon: NestyIcons.playArrow,
        ),
      ],
    );
  }
}
