import 'dart:async';

import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/repository/catalog_models.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/museum/cubit/museum_cubit.dart';
import 'package:nesty_game/features/museum/widgets/figurine_modal.dart';
import 'package:nesty_game/features/museum/widgets/museum_cabinet.dart';
import 'package:nesty_game/features/museum/widgets/museum_collection_card.dart';

/// The Doll Museum (spec §7.2, §10.2 #10, frames 6.1–6.3;
/// docs/plans/m3-design.md §10.6): the shell's third tab.
@RoutePage()
class MuseumPage extends StatelessWidget implements AutoRouteWrapper {
  const MuseumPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) =>
      BlocProvider(create: (_) => get<MuseumCubit>()..load(), child: this);

  @override
  Widget build(BuildContext context) => const MuseumView();
}

/// The Museum screen's body over a `MuseumCubit` ancestor (docs/plans/
/// m3-design.md §10.6): the collection card, the walnut cabinet and the
/// 6.2/6.3 figurine modal. Public so a test can pump it over a real
/// [MuseumCubit] built from fakes, the same pattern `DailyView` uses.
class MuseumView extends StatefulWidget {
  const MuseumView({super.key});

  @override
  State<MuseumView> createState() => _MuseumViewState();
}

class _MuseumViewState extends State<MuseumView> {
  /// The open modal's chapter id, looked up in the latest [MuseumState]
  /// each build so a save change while the modal is open (a win completing
  /// its chapter) is reflected without closing it.
  String? _openChapterId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MuseumCubit, AsyncValue<MuseumState>>(
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
                  _Header(state: data),
                  const SizedBox(height: 4),
                  if (data != null)
                    Expanded(child: _body(context, data))
                  else if (error != null)
                    Expanded(
                      child: Center(
                        child: RetryView(
                          exception: error,
                          onRetry: () => context.read<MuseumCubit>().load(),
                        ),
                      ),
                    )
                  else
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, MuseumState state) {
    final entry = _entryFor(state, _openChapterId);
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Chapters opens from Home's chapter card only (Q92, frame
              // 2.1): frame 6.1 has no Chapters link here (phase 4 J.2).
              // One line saying what the screen is and how a family is
              // earned (D111, frame 6.1; copy.md G.10 `museum_intro`).
              Text(
                context.localizations.museumIntro(
                  state.entries.isEmpty
                      ? ChapterInfo.levelsPerChapter
                      : state.entries.first.total,
                ),
                style: MuseumTokens.introText.copyWith(
                  color: AppColorTokens.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              MuseumCollectionCard(
                state: state,
                onPlay: () => _playHome(context, state),
              ),
              const SizedBox(height: 14),
              MuseumCabinet(
                entries: state.entries,
                onTapEntry: (entry) =>
                    setState(() => _openChapterId = entry.chapterId),
              ),
            ],
          ),
        ),
        if (entry != null)
          FigurineModal(
            entry: entry,
            homeLevelNumber: state.homeLevelNumber,
            onClose: () => setState(() => _openChapterId = null),
            onPlay: () => _playHome(context, state),
          ),
      ],
    );
  }

  MuseumEntry? _entryFor(MuseumState state, String? chapterId) {
    if (chapterId == null) return null;
    for (final entry in state.entries) {
      if (entry.chapterId == chapterId) return entry;
    }
    return null;
  }

  Future<void> _playHome(BuildContext context, MuseumState state) async {
    setState(() => _openChapterId = null);
    // Pushed on the root router: Gameplay covers the whole shell, not just
    // this tab's own nested stack (`MainShellPage`'s class doc).
    await context.router.root.push(GameplayRoute(request: state.homeRequest));
  }
}

/// The header (frame 6.1): "Museum" Fredoka 700 34 on the left and the count
/// chip on the right, a museum glyph in `primaryEdge` and "3 / 10". The tab
/// has no back button and no coin pill.
class _Header extends StatelessWidget {
  const _Header({required this.state});

  final MuseumState? state;

  static const _chip = SurfaceStyle(
    gradient: AppGradientTokens.surface,
    shadows: [
      NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
      NestyShadow(color: AppColorTokens.surfaceEdge, dy: 5),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final state = this.state;
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  l10n.museumTitle,
                  style: AppTextStyleTokens.cardTitle.copyWith(
                    fontSize: 34,
                    color: AppColorTokens.textPrimary,
                  ),
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ),
          ),
          if (state != null)
            Semantics(
              label: l10n.museumCountSemantics(
                state.collectedCount,
                state.totalChapters,
              ),
              excludeSemantics: true,
              child: NestySurface(
                style: _chip,
                radius: BorderRadius.circular(22),
                height: 44,
                padding: const EdgeInsetsDirectional.only(start: 12, end: 16),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      IconUses.familiesHome,
                      size: 26,
                      color: AppColorTokens.primaryEdge,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.museumCount(
                        state.collectedCount,
                        state.totalChapters,
                      ),
                      style: AppTextStyleTokens.number.copyWith(
                        fontSize: 22,
                        color: AppColorTokens.textPrimary,
                      ),
                      maxLines: 1,
                      softWrap: false,
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
