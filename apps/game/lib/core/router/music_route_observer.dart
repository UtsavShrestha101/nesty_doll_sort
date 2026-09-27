import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/music/music_service.dart';

/// Plays the loop of the page on top (AUDIO.md "Music loops"): `music_home`
/// under Home and the meta screens, `music_game` under a level, nothing
/// yet under the splash. It sits on the root navigator
/// (`AppRouter.config(navigatorObservers:)` in `App`), mirrors its stack of
/// pages and tells [MusicService] whenever the top page changes; dialogs
/// and sheets are not pages, so they never change the track.
///
/// Leaving the splash for Home is "Splash ready": the first loop fades in
/// from silence (1200 ms). Home → a level and back crossfade (800 ms), and
/// Home resumes where it stopped. Continue on the win overlay stays on the
/// same page, so the level's loop just keeps playing.
///
/// A factory: a navigator takes its own observer instance.
@injectable
class MusicRouteObserver extends AutoRouterObserver {
  MusicRouteObserver(this._music);

  final MusicService _music;

  /// The navigator's page routes, bottom first.
  final List<Route<dynamic>> _pages = [];
  Route<dynamic>? _top;

  /// The loop under the page [routeName], or null for none (the splash).
  static MusicTrack? trackFor(String? routeName) => switch (routeName) {
    // The splash loads; the music starts as it hands over to Home.
    SplashRoute.name => null,
    // TODO(M3): the daily puzzle's and the bonus levels' boards play
    // music_game too (AUDIO.md); Daily, Museum, Shop, Skin detail and
    // Settings fall through to music_home.
    GameplayRoute.name => MusicTrack.game,
    _ => MusicTrack.home,
  };

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (!_isPage(route)) return;
    // The navigator reports pages added together in reverse order, each
    // with the page below it: place each above its page, or at the bottom.
    if (previousRoute == null) {
      _pages.insert(0, route);
    } else {
      final below = _pages.indexOf(previousRoute);
      if (below < 0) {
        _pages.add(route);
      } else {
        _pages.insert(below + 1, route);
      }
    }
    _sync();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_pages.remove(route)) _sync();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_pages.remove(route)) _sync();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final at = oldRoute == null ? -1 : _pages.indexOf(oldRoute);
    if (at >= 0) _pages.removeAt(at);
    if (newRoute != null && _isPage(newRoute)) {
      _pages.insert(at >= 0 ? at : _pages.length, newRoute);
    }
    _sync();
  }

  static bool _isPage(Route<dynamic> route) => route is PageRoute;

  void _sync() {
    final top = _pages.isEmpty ? null : _pages.last;
    if (identical(top, _top)) return;
    _top = top;
    if (top == null) return;
    switch (trackFor(top.settings.name)) {
      case MusicTrack.home:
        _music.playHome();
      case MusicTrack.game:
        _music.playGame();
      case null:
        break;
    }
  }
}
