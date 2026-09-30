import 'dart:async';

import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/chapters/cubit/chapters_cubit.dart';
import 'package:nesty_game/features/chapters/widgets/chapter_section_card.dart';

/// The Chapters screen (E7; spec-prop §10.2 #18; docs/plans/m7-design.md
/// §11, §15.1), pushed on the root router from Home and the Museum.
@RoutePage()
class ChaptersPage extends StatelessWidget implements AutoRouteWrapper {
  const ChaptersPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) =>
      BlocProvider(create: (_) => get<ChaptersCubit>()..load(), child: this);

  @override
  Widget build(BuildContext context) => const ChaptersView();
}

/// The Chapters body over a `ChaptersCubit` ancestor: every catalog
/// chapter's 20-level grid (m7-design §15.1), each cell won (with its best
/// moves), current or locked. A tap plays [ChapterLevel.request] on the
/// root router, so the level opens over the whole app, not just this
/// screen's own stack.
///
/// Auto-scrolls to the chapter holding the current level once, the first
/// time its data loads (owner's simulator review, 2026-09-28, D111): an
/// instant jump (`duration: Duration.zero`), not an animation — nothing to
/// leave running if the player navigates away before it would finish, and
/// nothing for a widget test to settle.
class ChaptersView extends StatelessWidget {
  const ChaptersView({super.key});

  @override
  Widget build(BuildContext context) => const _ChaptersBody();
}

class _ChaptersBody extends StatefulWidget {
  const _ChaptersBody();

  @override
  State<_ChaptersBody> createState() => _ChaptersBodyState();
}

class _ChaptersBodyState extends State<_ChaptersBody> {
  final _currentChapterKey = GlobalKey();
  bool _scrolled = false;

  /// The one open chapter (menus spec 3: an accordion): the current chapter
  /// when the data first lands, then whichever row the player taps. Null
  /// once it is folded again.
  String? _openChapterId;
  bool _openChosen = false;

  void _chooseInitialOpen(ChaptersState data) {
    if (_openChosen) return;
    _openChosen = true;
    for (final section in data.chapters) {
      if (section.isCurrent) _openChapterId = section.chapterId;
    }
  }

  void _toggle(ChapterSection section) => setState(
    () => _openChapterId = _openChapterId == section.chapterId
        ? null
        : section.chapterId,
  );

  void _play(BuildContext context, PlayRequest request) =>
      unawaited(context.router.root.push(GameplayRoute(request: request)));

  void _scrollToCurrentOnce() {
    if (_scrolled) return;
    _scrolled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _currentChapterKey.currentContext;
      if (target == null || !mounted) return;
      unawaited(
        Scrollable.ensureVisible(
          target,
          alignment: 0.1,
          duration: Duration.zero,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return BlocBuilder<ChaptersCubit, AsyncValue<ChaptersState>>(
      builder: (context, value) {
        final data = value.data;
        final error = value.exceptionOrNull;
        if (data != null) {
          _chooseInitialOpen(data);
          _scrollToCurrentOnce();
        }
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScreenHeader(
                    title: l10n.chaptersTitle,
                    onBack: () => context.router.maybePop(),
                  ),
                  const SizedBox(height: 4),
                  if (data != null)
                    _OverallProgress(
                      currentLevel: data.currentLevel,
                      totalLevels: data.totalLevels,
                      won: data.wonCount,
                    ),
                  Expanded(
                    child: data != null
                        ? WideScreenColumn(
                            child: ListView(
                              // Every catalog chapter (10 at launch) built
                              // up front, never lazily dropped: the
                              // scroll-to-current below needs the current
                              // chapter's own `KeyedSubtree` already mounted
                              // to find it, and the default cache extent
                              // (250 dp) can fall short of it once a
                              // chapter's card grows (the star total,
                              // m7-design P3.7, found by this file's own
                              // overflow test at 360×640).
                              cacheExtent: 5000,
                              padding: const EdgeInsets.only(bottom: 24),
                              children: [
                                for (
                                  var i = 0;
                                  i < data.chapters.length;
                                  i++
                                ) ...[
                                  _StaggerFadeIn(
                                    index: i,
                                    child: KeyedSubtree(
                                      key: data.chapters[i].isCurrent
                                          ? _currentChapterKey
                                          : null,
                                      child: ChapterSectionCard(
                                        key: ValueKey(
                                          data.chapters[i].chapterId,
                                        ),
                                        section: data.chapters[i],
                                        expanded:
                                            _openChapterId ==
                                            data.chapters[i].chapterId,
                                        onToggle: () =>
                                            _toggle(data.chapters[i]),
                                        onPlay: (request) =>
                                            _play(context, request),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: ChaptersTokens.gap),
                                ],
                              ],
                            ),
                          )
                        : error != null
                        ? Center(
                            child: RetryView(
                              exception: error,
                              onRetry: () =>
                                  context.read<ChaptersCubit>().load(),
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

/// The header's overall line (frame 10.4; tokens `layout.chapters.
/// progressLine`): "Level 67 of 200" in Fredoka 700 17 on the left, "66 won"
/// on the right, over a 12 dp bar in the green progress fill, so the whole
/// campaign reads at a glance before scrolling to any one chapter.
class _OverallProgress extends StatelessWidget {
  const _OverallProgress({
    required this.currentLevel,
    required this.totalLevels,
    required this.won,
  });

  final int currentLevel;
  final int totalLevels;
  final int won;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final label = l10n.chaptersOverallProgress(currentLevel, totalLevels);
    final fraction = totalLevels == 0 ? 0.0 : currentLevel / totalLevels;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    label,
                    style: AppTextStyleTokens.cardTitle.copyWith(
                      fontSize: 17,
                      color: AppColorTokens.textPrimary,
                    ),
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.chaptersWonCount(won),
                style: AppTextStyleTokens.row.copyWith(
                  fontSize: 15,
                  color: AppColorTokens.textSecondary,
                ),
                maxLines: 1,
                softWrap: false,
              ),
            ],
          ),
          const SizedBox(height: 6),
          NestyProgressBar(
            value: fraction,
            height: ChaptersTokens.progressLineBar,
            semanticLabel: label,
          ),
        ],
      ),
    );
  }
}

/// A light staggered fade-in on the chapter list's first build (owner's
/// simulator review, 2026-09-28, design request I.4, "cool, clean, elegant,
/// addictive"): each card's own [duration] grows a little with [index], so
/// they settle in one after another instead of all at once. None of it runs
/// under reduce motion (spec §16): [child] then shows immediately, at full
/// opacity, with nothing ticking.
///
/// Keyed by the card above it (`ValueKey(chapterId)`), so this only ever
/// plays once per chapter, on the element's first mount, never again on a
/// later `SaveService.changes` rebuild (the element, and this widget's
/// `State`, persist across those).
class _StaggerFadeIn extends StatelessWidget {
  const _StaggerFadeIn({required this.index, required this.child});

  final int index;
  final Widget child;

  static const _base = Duration(milliseconds: ChaptersMotionTokens.durationMs);
  static const _stepMs = ChaptersMotionTokens.staggerMs;

  /// Caps the stagger so a 10-chapter list still finishes settling quickly.
  static const _maxSteps = 6;

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) return child;
    final steps = index < _maxSteps ? index : _maxSteps;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: _base + Duration(milliseconds: _stepMs * steps),
      curve: Curves.easeOut,
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value,
        // A screen reader shouldn't lose the card just because its visual
        // fade hasn't finished (the effect is purely decorative): keep it
        // in the semantics tree through every frame, including opacity 0
        // at the very start, when `TweenAnimationBuilder`'s first `build`
        // still reflects its tween's `begin` value.
        alwaysIncludeSemantics: true,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 12),
          child: child,
        ),
      ),
    );
  }
}
