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

/// The race board's rival strip (frames 9.3-9.3e, 9.3h, 9.3i;
/// `layout.rivalStrip`; phase 4 ui-spec-game §2.1): a 48 dp card in the
/// HUD's top row, right of Pause, in place of the level and coin pills (the
/// HUD gives it x 76 to W − 16 at top 62). [RivalPortrait] 38, the name and
/// [ComputerTag] over the state line, and the family count over one dot per
/// family on the right; a [RivalStripForm] makes room for a long name.
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

  /// `layout.rivalStrip.height`: the strip's height, but in the
  /// [RivalStripForm.tagSecondLine] form at large text
  /// ([RivalStripForm.heightOf]).
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
    return LayoutBuilder(
      builder: (context, outer) {
        // The form is picked from the strip's inner width, before its
        // height: the tag on the second line grows the strip at large text.
        final form = RivalStripForm.of(
          context,
          width: outer.maxWidth - RivalStripTokens.padding.horizontal,
          name: name,
          total: data.totalSets,
          glyphOnly: glyphOnly,
        );
        final height = RivalStripForm.heightOf(context, form);
        return SizedBox(
          height: height,
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
                    height: height,
                    padding: RivalStripTokens.padding,
                    child: Row(
                      children: [
                        _MovedBeat(
                          key: ValueKey('moved-${data.rivalMoves}'),
                          // `ui_rival_react`: it breathes, and pops its ring
                          // and sparkles when the computer completes a
                          // family.
                          child: RivalReact(
                            number: data.rival,
                            size: RivalStripTokens.portrait,
                            familyCount: data.rivalSets,
                          ),
                        ),
                        const SizedBox(width: RivalStripTokens.gap),
                        Expanded(
                          // The outer FittedBox only scales for height (the
                          // strip is fixed); the lines inside fit the width
                          // one by one.
                          child: LayoutBuilder(
                            builder: (context, box) => FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: SizedBox(
                                width: box.maxWidth,
                                child: _Lines(
                                  form: form,
                                  name: name,
                                  data: data,
                                  glyphOnly: glyphOnly,
                                  showState: showState,
                                  playerFirst: playerFirst,
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
                          dots: form == RivalStripForm.full,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // The announcer: never visible, its own live region so a
              // screen reader hears only what changed (m7-design P2.9).
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
      },
    );
  }
}

/// The strip's middle column in its [form]: the name and the tag over the
/// state line, or (9.3i) the name over the tag and its state glyph.
class _Lines extends StatelessWidget {
  const _Lines({
    required this.form,
    required this.name,
    required this.data,
    required this.glyphOnly,
    required this.showState,
    required this.playerFirst,
  });

  final RivalStripForm form;
  final String name;
  final RivalStripData data;
  final bool glyphOnly;
  final bool showState;
  final bool playerFirst;

  @override
  Widget build(BuildContext context) {
    final nameText = Text(
      name,
      style: RivalStripTokens.name,
      maxLines: 1,
      softWrap: false,
    );
    if (form == RivalStripForm.tagSecondLine) {
      final glyph = _StateGlyph.of(
        activity: data.activity,
        playerFirst: playerFirst,
        held: data.held,
      );
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // The name alone may still scale, as the last resort.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: nameText,
          ),
          const SizedBox(height: 2),
          // The last form: the tag's line, too, scales rather than overflow
          // (a long tag at 1.3× text on 360 dp, ja).
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              key: RivalStripForm.tagLineKey,
              mainAxisSize: MainAxisSize.min,
              children: [
                const ComputerTag(),
                if (glyph != null) ...[
                  const SizedBox(width: RivalStripTokens.formsStateGlyphGap),
                  glyph,
                ],
              ],
            ),
          ),
        ],
      );
    }
    // Each line scales on its own, so a long state line doesn't shrink the
    // rival's name below the readability floor (l10n 5B). The tag keeps its
    // word at 360 dp and up (RivalStripForm).
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: nameText,
              ),
            ),
            const SizedBox(width: RivalStripForm.tagGap),
            ComputerTag(glyphOnly: glyphOnly),
          ],
        ),
        if (showState)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: _StateLine(
              activity: data.activity,
              playerFirst: playerFirst,
              held: data.held,
            ),
          ),
      ],
    );
  }
}

/// How the strip makes room for the rival's name and the word "Computer"
/// (spec-prop §1.1 rule 5; `layout.rivalStrip.forms`, m7-5). In a race the
/// strip is the only on-screen rival label, so at 360 dp and up the word
/// always shows (D192; 5C ethics, D271). The strip takes the first form that
/// fits, measured at the current text scale: the full one, then the count
/// without its dots, then the tag on the second line.
enum RivalStripForm {
  /// 9.3: the name and the tag on one line, the state line under them, the
  /// count over its dots (at most 8).
  full,

  /// 9.3h: as [full] with the count alone, centred on the strip; also every
  /// race with more than 8 families.
  countOnly,

  /// 9.3i: the name alone on line 1; the tag on line 2 in place of the state
  /// line, followed by a 16 dp state glyph; the count alone. At large text
  /// the strip grows to `formsHeightAt13` (58).
  tagSecondLine;

  /// The gap between the name and the tag.
  static const double tagGap = 6;

  /// The tag's line in [tagSecondLine], for tests.
  @visibleForTesting
  static const Key tagLineKey = Key('rival-strip-tag-line');

  /// The thinking glyph's pulse, for tests.
  @visibleForTesting
  static const Key pulseKey = Key('rival-strip-state-pulse');

  /// The strip's form for its inner [width] (the strip less its padding).
  /// Under 360 dp the tag is its glyph alone, which fits beside any name
  /// (D192): the full form, or the count alone above 8 families.
  static RivalStripForm of(
    BuildContext context, {
    required double width,
    required String name,
    required int total,
    required bool glyphOnly,
  }) {
    final dots = total <= RivalStripTokens.formsFullMaxDots;
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
    // The dots never shrink (`formsDotsMinSize`).
    final dotsWidth =
        total * RivalStripTokens.dotsSize +
        (total - 1) * RivalStripTokens.dotsGap;
    // The name's box is the strip less the portrait, both gaps and the
    // progress column; the name and the tag fit it at the text scale.
    bool fits(double progress) {
      final box =
          width -
          RivalStripTokens.portrait -
          2 * RivalStripTokens.gap -
          progress;
      return box - tagGap - tagWidth >= nameWidth;
    }

    if (dots && fits(math.max(countWidth, dotsWidth))) return full;
    if (fits(countWidth)) return countOnly;
    return tagSecondLine;
  }

  /// The strip's height in [form]: 48, or `formsHeightAt13` (58) when the
  /// tag takes the second line at more than 1.1× text (NestyStrip: the
  /// state glyph and the tag need the room; the HUD moves the family
  /// counter down with it).
  static double heightOf(BuildContext context, RivalStripForm form) {
    if (form != tagSecondLine) return RivalStripTokens.height;
    final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
    return scale > _growAbove
        ? RivalStripTokens.formsHeightAt13
        : RivalStripTokens.height;
  }

  /// NestyStrip's `k > 1.1`.
  static const double _growAbove = 1.1;
}

/// 9.3i's state glyph after the tag (`layout.rivalStrip.forms.stateGlyph`),
/// 16 dp at 1.0× text and growing with it: `more_horiz` pulsing like the
/// three dots while the computer thinks, `replay` when it starts over, a
/// green `check_circle` when it finishes. None before the start or once the
/// player has finished first (the glyph would read as the computer's).
class _StateGlyph extends StatelessWidget {
  const _StateGlyph({
    required this.glyph,
    required this.color,
    this.pulse = false,
    this.animate = false,
  });

  final IconData glyph;
  final Color color;

  /// The thinking glyph pulses; [animate] is false when held or under
  /// reduced motion.
  final bool pulse;
  final bool animate;

  static Widget? of({
    required RivalActivity activity,
    required bool playerFirst,
    required bool held,
  }) {
    if (playerFirst) return null;
    return switch (activity) {
      RivalActivity.idle => null,
      RivalActivity.thinking => Builder(
        builder: (context) => _StateGlyph(
          glyph: IconUses.raceStripThinking,
          color: RivalStripTokens.formsStateGlyphThinkingColor,
          pulse: true,
          animate: !held && !context.reduceMotion,
        ),
      ),
      RivalActivity.startingOver => const _StateGlyph(
        glyph: IconUses.raceStripStartingOver,
        color: RivalStripTokens.formsStateGlyphStartingOverColor,
      ),
      RivalActivity.finished => const _StateGlyph(
        glyph: IconUses.raceStripFinished,
        color: RivalStripTokens.formsStateGlyphFinishedColor,
      ),
    };
  }

  /// The glyph's size at 1.0× text.
  static const double size = 16;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      glyph,
      key: ValueKey('rivalStateGlyph-${glyph.codePoint}'),
      size: MediaQuery.textScalerOf(context).scale(size),
      color: color,
    );
    if (!pulse || !animate) return icon;
    return _Pulse(child: icon);
  }
}

/// The thinking glyph's pulse: the three dots' 1.2 s turn
/// (`stateThinkingPeriodMs`), between their lit (1) and dim (0.3) opacity.
class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});

  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(
      milliseconds: RivalStripTokens.stateThinkingPeriodMs,
    ),
  );

  @override
  void initState() {
    super.initState();
    final controller = _controller;
    // After the first frame, as `_Thinking` does: a repeat notifies at once.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.repeat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    key: RivalStripForm.pulseKey,
    opacity: _opacity,
    child: widget.child,
  );

  late final Animation<double> _opacity = _controller.drive(_PulseTween());
}

/// 1 → 0.3 → 1 over one turn, smoothly.
class _PulseTween extends Animatable<double> {
  @override
  double transform(double t) => 0.65 + 0.35 * math.cos(2 * math.pi * t);
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
/// stands alone (`RivalStripForm`: above 8 families, or a long name).
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
    // 9.3h: without its dots the count stands alone, centred on the strip
    // at the 9.3 size; the dots never shrink below 8 dp.
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
