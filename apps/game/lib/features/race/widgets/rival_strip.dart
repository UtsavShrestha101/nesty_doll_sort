import 'dart:async';
import 'dart:math' as math;

import 'package:get_it/get_it.dart';
import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/race/cubit/race_cubit.dart';

/// What [RivalStripView] draws, selected from `RaceCubit`'s state (m7-design
/// P2.9): the record the cubit emits once per rival step, never per frame.
///
/// [over] is the race's end ([RacePhase.finished]): the player won, or the
/// rival finished first.
typedef RivalStripData = ({
  int rival,
  RivalActivity activity,
  int rivalSets,
  int totalSets,
  int rivalMoves,
  bool held,
  bool over,
});

/// The race board's rival strip (frames 9.3-9.3e; `layout.rivalStrip`; phase
/// 4 ui-spec-game §2.1): a 48 dp card in the HUD's top row, right of Pause,
/// in place of the level and coin pills (the HUD gives it x 76 to W − 16 at
/// top 62). [RivalPortrait] 38, the name and [ComputerTag] over the state
/// line, and the family count over one dot per family on the right.
///
/// A `BlocSelector`, so the Flame board never rebuilds for a rival move: it
/// sits in its own `RepaintBoundary`, and nothing here touches the
/// `GameplayBloc`'s state. The HUD puts it under an `IgnorePointer`.
///
/// `rival_complete` plays here, on the SFX bus, each time the rival lands a
/// family (no haptic; AUDIO.md, D192). The [audio] is the page's service;
/// without one it uses the app's registered [AudioService] (like
/// `TactileFeedback`), and none in a bare widget test.
class RivalStrip extends StatelessWidget {
  const RivalStrip({required this.cubit, this.audio, super.key});

  final RaceCubit cubit;
  final AudioService? audio;

  /// `layout.rivalStrip.height`.
  static const double height = RivalStripTokens.height;

  static AudioService? _locate() {
    final locator = GetIt.instance;
    return locator.isRegistered<AudioService>()
        ? locator<AudioService>()
        : null;
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<RaceCubit, AsyncValue<RaceState>>(
        bloc: cubit,
        listenWhen: (previous, current) {
          final before = previous.data;
          final after = current.data;
          return before != null &&
              after != null &&
              after.rivalSets > before.rivalSets;
        },
        listener: (context, value) =>
            (audio ?? _locate())?.play(SoundEffect.rivalComplete),
        child: BlocSelector<RaceCubit, AsyncValue<RaceState>, RivalStripData?>(
          bloc: cubit,
          selector: (value) {
            final state = value.data;
            if (state == null) return null;
            return (
              rival: state.rival,
              activity: state.activity,
              rivalSets: state.rivalSets,
              totalSets: state.totalSets,
              rivalMoves: state.rivalMoves,
              held: state.held,
              over: state.phase == RacePhase.finished,
            );
          },
          builder: (context, data) => data == null
              ? const SizedBox(height: height)
              : RepaintBoundary(child: RivalStripView(data: data)),
        ),
      );
}

/// The strip's visuals for one [data] snapshot, decoupled from the cubit so
/// a test can pump it directly. Tracks the announcer's live region as
/// [data] changes.
class RivalStripView extends StatefulWidget {
  const RivalStripView({required this.data, super.key});

  final RivalStripData data;

  @override
  State<RivalStripView> createState() => _RivalStripViewState();
}

class _RivalStripViewState extends State<RivalStripView> {
  String _announcement = '';
  Timer? _throttle;
  String? _pending;

  /// At most one live announcement every 2,000 ms (m7-design P2.9); the
  /// latest wins.
  static const _throttleWindow = Duration(milliseconds: 2000);

  @override
  void didUpdateWidget(RivalStripView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = oldWidget.data;
    final data = widget.data;
    if (old.activity == RivalActivity.idle &&
        data.activity == RivalActivity.thinking) {
      // Start was tapped (copy.md A11y `a11y_race_start`; spec §16).
      _queue(
        context.localizations.raceAnnounceStart(
          context.localizations.raceRivalName(data.rival),
        ),
      );
    } else if (data.rivalSets > old.rivalSets &&
        data.rivalSets < data.totalSets) {
      _queue(
        context.localizations.raceAnnounceFamily(
          data.rivalSets,
          data.totalSets,
        ),
      );
    } else if (data.activity == RivalActivity.startingOver &&
        old.activity != RivalActivity.startingOver) {
      _queue(context.localizations.raceAnnounceStartingOver);
    } else if (data.activity == RivalActivity.finished &&
        old.activity != RivalActivity.finished) {
      _queue(context.localizations.raceAnnounceFinished);
    }
  }

  void _queue(String text) {
    if (_throttle != null) {
      _pending = text;
      return;
    }
    setState(() => _announcement = text);
    _throttle = Timer(_throttleWindow, _drain);
  }

  void _drain() {
    _throttle = null;
    final pending = _pending;
    if (pending == null) return;
    _pending = null;
    _queue(pending);
  }

  @override
  void dispose() {
    _throttle?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final data = widget.data;
    final name = l10n.raceRivalName(data.rival);
    final width = MediaQuery.sizeOf(context).width;
    final glyphOnly = width < RivalStripTokens.narrowTagGlyphOnlyBelowWidth;
    final showState = width >= RivalStripTokens.narrowStateHiddenBelowWidth;
    // The player finished first: the rival's activity never leaves
    // `thinking`, so the line names the win instead (frame 9.6's strip).
    final playerFirst = data.over && data.activity != RivalActivity.finished;
    return SizedBox(
      height: RivalStrip.height,
      child: Stack(
        children: [
          Semantics(
            label: l10n.raceStripSemantics(
              name,
              data.rivalSets,
              data.totalSets,
            ),
            container: true,
            child: ExcludeSemantics(
              child: NestySurface(
                style: SurfaceStyles.raised,
                radius: const BorderRadius.all(
                  Radius.circular(RivalStripTokens.radius),
                ),
                height: RivalStrip.height,
                padding: RivalStripTokens.padding,
                child: LayoutBuilder(
                  builder: (context, inner) {
                    final room = _StripRoom.of(
                      context,
                      width: inner.maxWidth,
                      name: name,
                      total: data.totalSets,
                      glyphOnly: glyphOnly,
                    );
                    return Row(
                      children: [
                        _MovedBeat(
                          key: ValueKey('moved-${data.rivalMoves}'),
                          // `ui_rival_react`: it breathes, and pops its ring and
                          // sparkles when the computer completes a family.
                          child: RivalReact(
                            number: data.rival,
                            size: RivalStripTokens.portrait,
                            familyCount: data.rivalSets,
                          ),
                        ),
                        const SizedBox(width: RivalStripTokens.gap),
                        Expanded(
                          // The outer FittedBox only scales for height (the strip
                          // is fixed); the lines inside fit the width one by one.
                          child: LayoutBuilder(
                            builder: (context, box) => FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: SizedBox(
                                width: box.maxWidth,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Each line scales on its own, so a long state line
                                    // doesn't shrink the rival's name below the
                                    // readability floor (l10n 5B). The tag keeps
                                    // its word at 360 dp and up (_StripRoom).
                                    if (room == _StripRoom.stacked) ...[
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment:
                                            AlignmentDirectional.centerStart,
                                        child: Text(
                                          name,
                                          style: RivalStripTokens.name,
                                          maxLines: 1,
                                          softWrap: false,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const ComputerTag(),
                                    ] else ...[
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              alignment: AlignmentDirectional
                                                  .centerStart,
                                              child: Text(
                                                name,
                                                style: RivalStripTokens.name,
                                                maxLines: 1,
                                                softWrap: false,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: _StripRoom.tagGap,
                                          ),
                                          ComputerTag(glyphOnly: glyphOnly),
                                        ],
                                      ),
                                      if (showState)
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment:
                                              AlignmentDirectional.centerStart,
                                          child: _StateLine(
                                            activity: data.activity,
                                            playerFirst: playerFirst,
                                            held: data.held,
                                          ),
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: RivalStripTokens.gap),
                        _Progress(
                          key: const ValueKey('rivalProgress'),
                          done: data.rivalSets,
                          total: data.totalSets,
                          dots: room == _StripRoom.full,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          // The announcer: never visible, its own live region so a screen
          // reader hears only what changed (m7-design P2.9).
          Positioned(
            left: 0,
            top: 0,
            child: ExcludeSemantics(
              excluding: false,
              child: Semantics(
                liveRegion: true,
                label: _announcement,
                child: const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// How the strip makes room for the rival's name and the word "Computer"
/// (spec-prop §1.1 rule 5). In a race the strip is the only on-screen rival
/// label, so at 360 dp and up the word always shows (D192; 5C ethics, D271):
/// the name scales down to the readability floor first, then the dots give
/// way to the count alone, then the tag takes the state line's place.
enum _StripRoom {
  /// The name and the tag on one line, the state line, the count over its
  /// dots.
  full,

  /// As [full] with the count alone (also every race above 8 families).
  countOnly,

  /// The name, then the tag on the second line, and the count alone; no
  /// state line (the portrait's motion and the announcer still carry it).
  stacked;

  /// The gap between the name and the tag.
  static const double tagGap = 6;

  /// Frame 9.3 draws one dot per family up to 8.
  static const int _maxDots = 8;

  /// The readability floor (textFit's `minScale`).
  static const double _minScale = 0.75;

  static _StripRoom of(
    BuildContext context, {
    required double width,
    required String name,
    required int total,
    required bool glyphOnly,
  }) {
    final dots = total <= _maxDots;
    // Under 360 dp the glyph alone fits beside any name (D192).
    if (glyphOnly || !width.isFinite) return dots ? full : countOnly;
    final nameWidth = ComputerTag.lineWidth(
      context,
      name,
      RivalStripTokens.name,
    );
    final tagWidth = ComputerTag.fullWidth(context);
    final countWidth = ComputerTag.lineWidth(
      context,
      context.localizations.raceStripFamilies(total, total),
      RivalStripTokens.count,
    );
    final dotsWidth =
        total * RivalStripTokens.dotsSize +
        (total - 1) * RivalStripTokens.dotsGap;
    // The name's box is the strip less the portrait, both gaps and the
    // progress column; beside the tag the name may scale to the floor.
    bool fits(double progress) {
      final box =
          width -
          RivalStripTokens.portrait -
          2 * RivalStripTokens.gap -
          progress;
      return box - tagGap - tagWidth >= nameWidth * _minScale;
    }

    if (dots && fits(math.max(countWidth, dotsWidth))) return full;
    if (fits(countWidth)) return countOnly;
    return stacked;
  }
}

/// The strip's second line (frames 9.3-9.3d, `layout.rivalStrip.state`):
/// "Ready when you are", "Thinking" with three animated dots, "Starting
/// over" with a `refresh` glyph, "Finished" with a `check_circle`, and, once
/// the player finished first, "You finished first" with a green check. A
/// hold (Pause, a sheet) keeps the last line and stops the dots.
class _StateLine extends StatelessWidget {
  const _StateLine({
    required this.activity,
    required this.playerFirst,
    required this.held,
  });

  final RivalActivity activity;
  final bool playerFirst;
  final bool held;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    const style = RivalStripTokens.state;
    Widget text(String value) =>
        Text(value, style: style, maxLines: 1, softWrap: false);
    Widget withGlyph(IconData glyph, double size, Color color, String value) =>
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(glyph, size: size, color: color),
            const SizedBox(width: 4),
            text(value),
          ],
        );
    if (playerFirst) {
      return withGlyph(
        NestyIcons.checkCircle,
        14,
        AppColorTokens.success,
        l10n.raceStripPlayerFinished,
      );
    }
    return switch (activity) {
      RivalActivity.idle => text(l10n.raceStripReady),
      RivalActivity.thinking => _Thinking(
        label: l10n.raceStripThinking,
        animate: !held && !context.reduceMotion,
      ),
      RivalActivity.startingOver => withGlyph(
        NestyIcons.refresh,
        12,
        AppColorTokens.textSecondary,
        l10n.raceStripStartingOver,
      ),
      RivalActivity.finished => withGlyph(
        NestyIcons.checkCircle,
        14,
        AppColorTokens.versus,
        l10n.raceStripFinished,
      ),
    };
  }
}

/// "Thinking" and three 3 dp dots that rise in turn (`stateThinking*`: a
/// 1.2 s loop, 200 ms apart). Without [animate] (reduced motion, a hold) it
/// is the label alone, with its own ellipsis.
class _Thinking extends StatefulWidget {
  const _Thinking({required this.label, required this.animate});

  final String label;
  final bool animate;

  @override
  State<_Thinking> createState() => _ThinkingState();
}

class _ThinkingState extends State<_Thinking>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(
      milliseconds: RivalStripTokens.stateThinkingPeriodMs,
    ),
  );

  @override
  void initState() {
    super.initState();
    // Built now, never first in dispose (a lazy ticker can't look up its
    // ancestors once unmounted).
    final controller = _controller;
    if (widget.animate) {
      // After the first frame: a repeat notifies at once, which inside a
      // LayoutBuilder's build would mark a listener dirty out of scope.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.animate) controller.repeat();
      });
    }
  }

  @override
  void didUpdateWidget(_Thinking oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const style = RivalStripTokens.state;
    if (!widget.animate) {
      return Text(widget.label, style: style, maxLines: 1, softWrap: false);
    }
    // The copy's own ellipsis is what the dots replace.
    final word = widget.label.replaceAll('…', '').trimRight();
    const size = RivalStripTokens.stateThinkingDotSize;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(word, style: style, maxLines: 1, softWrap: false),
        const SizedBox(width: 3),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < RivalStripTokens.stateThinkingDots; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Opacity(
                    opacity: _dotOpacity(i),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColorTokens.textSecondary,
                      ),
                      child: SizedBox.square(dimension: size),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Dot [i]'s brightness: a pulse, staggered by 200 ms per dot.
  double _dotOpacity(int i) {
    const period = RivalStripTokens.stateThinkingPeriodMs;
    const stagger = RivalStripTokens.stateThinkingStaggerMs;
    final t = (_controller.value * period - i * stagger) % period / period;
    final phase = t < 0 ? t + 1 : t;
    // Lit for the first third of its turn, dim otherwise.
    return phase < 1 / 3 ? 1 : 0.3;
  }
}

/// The right column: the family count ("2/4", Fredoka 700 17 `#3242A8`,
/// tabular) over one dot per family. Both bump (1.3, `easeOutBack`, 240 ms:
/// `motion.rivalDot`) when the rival lands a family, and skip it under
/// reduced motion, which fills the dot at once. Without [dots] the count
/// stands alone (`_StripRoom`: above 8 families, or a long name).
class _Progress extends StatelessWidget {
  const _Progress({
    required this.done,
    required this.total,
    required this.dots,
    super.key,
  });

  final int done;
  final int total;

  /// The dot row under the count.
  final bool dots;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final bump = !context.reduceMotion && done > 0;
    // TODO(design): frame 9.3 draws up to 8 dots and one name line; above 8
    // families, or when a long name and the "Computer" word need the room,
    // the count stands alone (our proposal, ui-spec-game §2.1 "Open"; D271).
    const dot = RivalStripTokens.dotsSize;
    const gap = RivalStripTokens.dotsGap;
    return ExcludeSemantics(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerEnd,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TweenAnimationBuilder<double>(
              key: ValueKey('rivalCounterBump-$done'),
              tween: Tween(
                begin: bump ? RivalMotionTokens.dotBump : 1.0,
                end: 1.0,
              ),
              duration: bump ? _bump : Duration.zero,
              curve: RivalMotionTokens.dotCurve,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Text(
                l10n.raceStripFamilies(done, total),
                style: RivalStripTokens.count,
                maxLines: 1,
                softWrap: false,
              ),
            ),
            if (dots) const SizedBox(height: 2),
            if (dots)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < total; i++) ...[
                    if (i > 0) const SizedBox(width: gap),
                    _Dot(
                      key: ValueKey('rivalDot-$i'),
                      filled: i < done,
                      size: dot,
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  static const _bump = Duration(milliseconds: RivalMotionTokens.dotFillMs);
}

/// One family's dot: empty (`#EAD3B0`, sunk) or filled (`#4E5FD9` with a
/// 1.5 dp ring), popping with a 1.3 overshoot as it fills.
class _Dot extends StatefulWidget {
  const _Dot({required this.filled, required this.size, super.key});

  final bool filled;
  final double size;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: RivalMotionTokens.dotFillMs),
    value: 1,
  );

  @override
  void didUpdateWidget(_Dot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filled && !oldWidget.filled && !context.reduceMotion) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const ring = RivalStripTokens.dotsFilledRing;
    final size = widget.size;
    // The ring adds to the dot, so a row of dots keeps the token's pitch.
    final face = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.filled
            ? RivalStripTokens.dotsFilled
            : RivalStripTokens.dotsEmpty,
        border: widget.filled
            ? Border.all(color: ring.color, width: ring.width)
            : null,
        boxShadow: widget.filled
            ? null
            : const [BoxShadow(color: Color(0x1F5A2D0F), offset: Offset(0, 1))],
      ),
      child: SizedBox.square(dimension: size),
    );
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // 0 → past 1 → 1: the curve's overshoot is the design's bump.
        final t = RivalMotionTokens.dotCurve.transform(_controller.value);
        return Transform.scale(scale: widget.filled ? t : 1, child: child);
      },
      child: face,
    );
  }
}

/// The strip's short "moved" beat on the rival's portrait (`motion.rivalMove`:
/// a 1.06 scale for 160 ms each time the rival makes a move; its key is
/// `rivalMoves`), no sound and no haptic, and none under reduced motion.
class _MovedBeat extends StatelessWidget {
  const _MovedBeat({required this.child, super.key});

  final Widget child;

  static const double scale = RivalMotionTokens.movePortraitScale;
  static const Duration duration = Duration(
    milliseconds: RivalMotionTokens.moveMs,
  );

  @override
  Widget build(BuildContext context) {
    final beat = !context.reduceMotion;
    return TweenAnimationBuilder<double>(
      key: const ValueKey('rivalMovedBeat'),
      tween: Tween(begin: beat ? scale : 1.0, end: 1.0),
      duration: beat ? duration : Duration.zero,
      curve: UiMotionTokens.curveEaseOut,
      builder: (context, value, child) =>
          Transform.scale(scale: value, child: child),
      child: child,
    );
  }
}
