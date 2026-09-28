import 'package:intl/intl.dart';
import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/music/jingle_cues.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/daily/cubit/daily_cubit.dart';
import 'package:nesty_game/features/daily/widgets/chest_row.dart';
import 'package:nesty_game/features/daily/widgets/daily_chest_modal.dart';
import 'package:nesty_game/features/daily/widgets/day_strip.dart';
import 'package:nesty_game/features/daily/widgets/puzzle_card.dart';
import 'package:nesty_game/features/daily/widgets/streak_card.dart';
import 'package:nesty_game/features/fx/fx_library.dart';

/// The daily puzzle (spec §7.5, §10.2 #11, frames 5.1–5.6;
/// docs/plans/m3-design.md §10.5), opened from Home's Daily tile.
@RoutePage()
class DailyPage extends StatelessWidget implements AutoRouteWrapper {
  const DailyPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider.value(value: get<JingleCues>()),
      // The puzzle card's preview dolls (frame 5.1).
      RepositoryProvider.value(value: get<SkinService>()),
      RepositoryProvider.value(value: get<DatabaseService>()),
      RepositoryProvider.value(value: get<FxLibrary>()),
    ],
    child: BlocProvider(create: (_) => get<DailyCubit>()..load(), child: this),
  );

  @override
  Widget build(BuildContext context) => const DailyView();
}

/// The Daily screen's body over a `DailyCubit` ancestor (docs/plans/
/// m3-design.md §10.5, §8.4): every §8.4 state, the "Streak saved!" banner
/// (5.2) and the day-7 chest modal (5.6). Public so a test can pump it over
/// a real [DailyCubit] built from fakes (`BlocProvider.value`), the same
/// pattern as `GameplayView`.
class DailyView extends StatefulWidget {
  const DailyView({super.key});

  @override
  State<DailyView> createState() => _DailyViewState();
}

class _DailyViewState extends State<DailyView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<DailyCubit, AsyncValue<DailyState>>(
          listenWhen: (previous, current) =>
              current.data?.status.freezeNotice != null &&
              previous.data?.status.freezeNotice !=
                  current.data?.status.freezeNotice,
          listener: _onFreezeNotice,
          builder: (context, value) => switch (value) {
            AsyncValueData<DailyState>(:final data) => _body(context, data),
            AsyncValueLoading<DailyState>(:final data) when data != null =>
              _body(context, data),
            AsyncValueError<DailyState>(:final exception) => RetryView(
              exception: exception,
              onRetry: () => context.read<DailyCubit>().load(),
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }

  void _onFreezeNotice(BuildContext context, AsyncValue<DailyState> value) {
    final notice = value.data?.status.freezeNotice;
    if (notice == null) return;
    final l10n = context.localizations;
    final weekday = DateFormat.EEEE(
      Localizations.localeOf(context).toString(),
    ).format(notice.startOfDay);
    NestyToast.show(
      context,
      tone: NestyBannerTone.info,
      icon: NestyIcons.acUnit,
      title: l10n.dailySavedTitle,
      message: l10n.dailySavedBody(weekday),
    );
    context.read<DailyCubit>().acknowledgeFreezeNotice();
  }

  Widget _body(BuildContext context, DailyState state) {
    final l10n = context.localizations;
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ScreenHeader(
                title: l10n.levelDaily,
                onBack: () => context.router.maybePop(),
                coins: state.coins,
              ),
            ),
            Expanded(
              child: state.status.unlocked
                  ? _unlocked(context, state)
                  : _locked(context),
            ),
          ],
        ),
        if (state.status.chestPending)
          DailyChestModal(
            coins: state.chestCoins,
            onCollect: () {
              final collected = context.read<DailyCubit>().collectChest();
              if (collected) context.read<JingleCues>().reward();
            },
          ),
      ],
    );
  }

  Widget _unlocked(BuildContext context, DailyState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StreakCard(status: state.status),
          const SizedBox(height: 16),
          DayStrip(status: state.status),
          const SizedBox(height: 16),
          ChestRow(status: state.status, chestCoins: state.chestCoins),
          const SizedBox(height: 16),
          PuzzleCard(
            state: state,
            onPlay: () => _playDaily(context),
            onPlayCampaign: () => _playCampaign(context, state),
          ),
        ],
      ),
    );
  }

  Widget _locked(BuildContext context) {
    final l10n = context.localizations;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(NestyIcons.lock, size: 40, color: AppColors.chevron),
            const SizedBox(height: 12),
            // TODO(design): no frame shows the Daily screen itself before
            // Level 2 (m3-design §8.3, Q67); Home's tile is dimmed instead.
            Text(
              l10n.homeDailyLocked,
              textAlign: TextAlign.center,
              style: AppTextStyleTokens.cardTitle.copyWith(
                color: AppColors.textBrown,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _playDaily(BuildContext context) async {
    // The cubit's today, not `state.status.today`: that one can be
    // yesterday's for up to a minute after midnight.
    final request = context.read<DailyCubit>().dailyPlayRequest();
    await context.router.push(GameplayRoute(request: request));
    if (context.mounted) context.read<DailyCubit>().refresh();
  }

  Future<void> _playCampaign(BuildContext context, DailyState state) async {
    await context.router.push(GameplayRoute(request: state.homeRequest));
    if (context.mounted) context.read<DailyCubit>().refresh();
  }
}
