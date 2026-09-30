import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:nesty_game/core/router/app_router.dart';

/// How the gameplay route comes on screen (frames 10.8, 10.8b; phase 4
/// architecture §3.13): [fromSplash] is the first launch's straight path
/// into Level 1, a 400 ms fade; [push] is every other entry.
enum GameplayEntrance {
  /// Home's Play, Continue, Chapters, Daily, rival select, …: the
  /// platform's page transition.
  push,

  /// The splash's first launch into Level 1: a fade (lane O passes it).
  fromSplash,
}

/// The gameplay route's transitions (`AppRouter`'s `CustomRoute`; §3.13).
///
/// The route lasts [duration] (400 ms, the fade's). A [GameplayEntrance.push]
/// runs the platform's default transition on the first 75 % of it, so it
/// still ends at 300 ms as the material route did; its pop runs over
/// [reverseDuration] (300 ms) as before.
abstract final class GameplayTransitions {
  /// The first launch's fade (tokens `motion`'s first-launch 400 ms).
  static const Duration duration = Duration(milliseconds: 400);

  /// A pop, as the material route's.
  static const Duration reverseDuration = Duration(milliseconds: 300);

  /// The platform transition's share of [duration]: 300 of 400 ms.
  static const Curve pushInterval = Interval(0, 0.75);

  /// The first launch's 400 ms fade with `easeOut` straight into Level 1
  /// (frame 10.8; ui-spec-game §2.4). Under reduce motion the fade is a cut:
  /// the level is simply there.
  static Widget firstLaunch(
    BuildContext context,
    Animation<double> animation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
      child: child,
    );
  }

  /// How the route with [animation] enters: its [GameplayEntrance], read
  /// from the route's own arguments (`GameplayRouteArgs.entrance`).
  static Widget build(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final route = ModalRoute.of(context);
    final settings = route?.settings;
    final args = settings is AutoRoutePage ? settings.routeData.args : null;
    if (args is GameplayRouteArgs &&
        args.entrance == GameplayEntrance.fromSplash) {
      return firstLaunch(context, animation, child);
    }
    final curved = CurvedAnimation(
      parent: animation,
      curve: pushInterval,
      reverseCurve: Curves.linear,
    );
    if (route is PageRoute<Object?>) {
      return Theme.of(context).pageTransitionsTheme.buildTransitions(
        route,
        context,
        curved,
        secondaryAnimation,
        child,
      );
    }
    return FadeTransition(opacity: curved, child: child);
  }
}
