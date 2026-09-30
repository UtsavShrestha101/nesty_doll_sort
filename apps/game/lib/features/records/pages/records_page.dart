import 'dart:async';

import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/records/badge.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/records/cubit/records_cubit.dart';
import 'package:nesty_game/features/records/widgets/badge_grid.dart';
import 'package:nesty_game/features/records/widgets/races_won_card.dart';
import 'package:nesty_game/features/records/widgets/record_stat_cell.dart';

/// The Records screen (E8; spec-prop §10.2 #19; docs/plans/m7-design.md
/// §12, §15.2), pushed on the root router from Home.
@RoutePage()
class RecordsPage extends StatelessWidget implements AutoRouteWrapper {
  const RecordsPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) =>
      BlocProvider(create: (_) => get<RecordsCubit>()..load(), child: this);

  @override
  Widget build(BuildContext context) => const RecordsView();
}

/// The Records body over a `RecordsCubit` ancestor: the lifetime records
/// card and the twelve-badge grid (m7-design §12, §15.2).
class RecordsView extends StatelessWidget {
  const RecordsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return BlocBuilder<RecordsCubit, AsyncValue<RecordsState>>(
      builder: (context, value) {
        final data = value.data;
        final error = value.exceptionOrNull;
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScreenHeader(
                    title: l10n.recordsTitle,
                    onBack: () => context.router.maybePop(),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: data != null
                        ? WideScreenColumn(child: _RecordsBody(state: data))
                        : error != null
                        ? Center(
                            child: RetryView(
                              exception: error,
                              onRetry: () =>
                                  context.read<RecordsCubit>().load(),
                            ),
                          )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RecordsBody extends StatelessWidget {
  const _RecordsBody({required this.state});

  final RecordsState state;

  static const _linkStyle = SurfaceStyle(
    color: AppColorTokens.surfaceWhite,
    shadows: [NestyShadow(color: AppColorTokens.surfaceEdge, dy: 5)],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final summary = state.summary;
    String count(int value) => NestyNumberText.formatCount(context, value);
    final cells = [
      RecordStatCell(
        icon: IconUses.levelsWon,
        tint: AppColorTokens.successTint,
        glyphColor: AppColorTokens.success,
        value: count(summary.levelsWon),
        label: l10n.recordsLevelsWon,
      ),
      // Every family completed (spec-prop §7.9, `records.families`), a
      // plain count: frame 10.6's "2 of 10 Families home" counts the
      // Museum's figurines instead, and read "2 of 10" after two wins with
      // the Museum still empty (the device run, 2026-09-30; Q159).
      // TODO(design): the cell's copy and glyph for "families completed".
      RecordStatCell(
        icon: IconUses.familiesHome,
        tint: AppColorTokens.woodLight.withValues(alpha: 0.5),
        glyphColor: AppColorTokens.primaryEdge,
        value: count(summary.families),
        label: l10n.recordsFamilies,
      ),
      RecordStatCell(
        icon: IconUses.dollsNested,
        tint: AppColorTokens.canvasCreamLow,
        glyphColor: AppColorTokens.walnut,
        value: count(summary.dolls),
        label: l10n.recordsDolls,
      ),
      RecordStatCell(
        icon: IconUses.dailiesSolved,
        tint: AppColorTokens.dailyTop.withValues(alpha: 0.35),
        glyphColor: AppColorTokens.coinText,
        value: count(summary.dailies),
        label: l10n.recordsDailies,
      ),
      RecordStatCell(
        icon: IconUses.longestStreak,
        tint: AppColorTokens.streakTop.withValues(alpha: 0.3),
        glyphColor: AppColorTokens.streak,
        value: l10n.dailyStreakDays(summary.longestRun),
        label: l10n.recordsLongestStreak,
      ),
      RecordStatCell(
        icon: NestyIcons.star,
        art: UiArt.starFilled,
        tint: AppColorTokens.warningTint.withValues(alpha: 0.5),
        value: l10n.recordsStarsValue(summary.stars, summary.starsPossible),
        label: l10n.recordsStars,
      ),
    ];
    // Two columns down to 320 dp (menus spec 5), one below that.
    final oneColumn = MediaQuery.sizeOf(context).width < 320;
    final perRow = oneColumn ? 1 : RecordsTokens.statsGridColumns;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        for (var i = 0; i < cells.length; i += perRow) ...[
          if (i > 0) const SizedBox(height: RecordsTokens.statsGridGap),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var j = i; j < i + perRow && j < cells.length; j++) ...[
                  if (j > i) const SizedBox(width: RecordsTokens.statsGridGap),
                  Expanded(child: cells[j]),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        RacesWonCard(wins: summary.raceWins, unlocked: state.rivalsUnlocked),
        const SizedBox(height: 12),
        // TODO(design): the "Best moves by level" destination is in no frame
        // (menus spec §11 gap 6): it keeps the stand-in target, Chapters,
        // whose won cells show "Best N". BACKLOG "M7 phase 4 design gaps".
        TactileSurface(
          style: _linkStyle,
          radius: BorderRadius.circular(20),
          onPressed: () =>
              unawaited(context.router.root.push(const ChaptersRoute())),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          semanticLabel: l10n.recordsBestMovesLink,
          excludeChildSemantics: true,
          alignment: AlignmentDirectional.centerStart,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Row(
              children: [
                const NestySurface(
                  style: SurfaceStyle(
                    color: AppColorTokens.woodLight,
                    shadows: [],
                  ),
                  radius: BorderRadius.all(Radius.circular(12)),
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: Icon(
                    IconUses.bestMoves,
                    size: 24,
                    color: AppColorTokens.primaryEdge,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.recordsBestMovesLink,
                    style: AppTextStyleTokens.cardTitle.copyWith(
                      fontSize: 19,
                      color: AppColorTokens.textPrimary,
                    ),
                    maxLines: 2,
                  ),
                ),
                const Icon(
                  NestyIcons.chevronRight,
                  size: 26,
                  color: AppColorTokens.textMuted,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    l10n.recordsBadgesHeader,
                    style: AppTextStyleTokens.cardTitle.copyWith(
                      fontSize: 22,
                      color: AppColorTokens.textPrimary,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              Text(
                l10n.recordsBadgesCount(
                  summary.badges.length,
                  BadgeId.values.length,
                ),
                style: AppTextStyleTokens.caption.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColorTokens.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        BadgeGrid(earned: summary.badges),
      ],
    );
  }
}
