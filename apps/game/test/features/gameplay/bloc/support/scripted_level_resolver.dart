import 'package:nesty_game/core/models/play_entry.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/level_resolver.dart';

/// A fully scriptable [LevelResolver] for tests that need an exact
/// [PlayEntry] the shared `FakeLevelResolver` can't build directly: a
/// campaign entry that completes its chapter, or a bonus/daily entry with
/// a chosen reward, theme or tier.
class ScriptedLevelResolver implements LevelResolver {
  ScriptedLevelResolver({
    Map<PlayRequest, PlayEntry>? entries,
    this.nextOf,
    PlayRequest? homeRequest,
  }) : entries = entries ?? {},
       _homeRequest = homeRequest ?? const PlayRequest.campaign(1);

  /// What [resolve] answers, by request; unknown ones resolve to null.
  final Map<PlayRequest, PlayEntry> entries;

  /// What [next] answers; null (the default) for every request.
  final PlayRequest? Function(PlayRequest request)? nextOf;

  final PlayRequest _homeRequest;

  /// Requests [prefetch] was asked for, oldest first.
  final List<PlayRequest> prefetched = [];

  @override
  Future<PlayEntry?> resolve(PlayRequest request) async => entries[request];

  @override
  void prefetch(PlayRequest request) => prefetched.add(request);

  @override
  PlayRequest? next(PlayRequest request) => nextOf?.call(request);

  @override
  PlayRequest get homeRequest => _homeRequest;
}
