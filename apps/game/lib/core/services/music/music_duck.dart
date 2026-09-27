import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/services/audio/jingle_player.dart';
import 'package:nesty_game/core/services/music/music_mix.dart';
import 'package:nesty_game/core/services/music/music_service.dart';

/// Ducks the music for [reason] while it is in the tree (AUDIO.md "Music
/// rules"): [MusicService.duck] when it mounts, [MusicService.unduck] when
/// it goes, so an overlay can't leave the music ducked. Wrap the overlay
/// with it: the win overlay (0.3), the out-of-moves sheet (0.4), the pause
/// dialog (0.5).
///
/// With a [jingle] it also plays that on [jingles] once the duck is in
/// (`duckIn`, 200 ms: "duck to 0.4, then `jingle_oom`"), unless it has gone
/// by then.
class MusicDuck extends StatefulWidget {
  const MusicDuck({
    required this.music,
    required this.reason,
    required this.child,
    this.jingles,
    this.jingle,
    super.key,
  });

  final MusicService music;
  final DuckReason reason;
  final Widget child;
  final JinglePlayer? jingles;
  final Jingle? jingle;

  @override
  State<MusicDuck> createState() => _MusicDuckState();
}

class _MusicDuckState extends State<MusicDuck> {
  Timer? _jingle;

  @override
  void initState() {
    super.initState();
    widget.music.duck(widget.reason);
    final jingles = widget.jingles;
    final jingle = widget.jingle;
    if (jingles != null && jingle != null) {
      _jingle = Timer(MusicMix.duckIn, () => jingles.playJingle(jingle));
    }
  }

  @override
  void didUpdateWidget(MusicDuck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.music != widget.music || oldWidget.reason != widget.reason) {
      // Duck first, so the music never comes up between the two.
      widget.music.duck(widget.reason);
      oldWidget.music.unduck(oldWidget.reason);
    }
  }

  @override
  void dispose() {
    _jingle?.cancel();
    widget.music.unduck(widget.reason);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
