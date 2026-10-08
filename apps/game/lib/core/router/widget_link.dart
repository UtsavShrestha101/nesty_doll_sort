import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/services/analytics/analytics_service.dart';
import 'package:nesty_game/core/services/daily/daily_service.dart';

/// What the router does with a link from the home-screen widget.
enum WidgetLinkAction {
  /// Not the widget's link: the router handles it as before.
  passThrough,

  /// A cold start: go through the splash (it loads the levels), remember the
  /// Daily as the launch target, and let the splash honour it.
  viaSplash,

  /// The app is running: open the Daily over Home.
  openDaily,

  /// The app is running and the Daily is locked: stay where the player is.
  stay,
}

/// The widget's tap, `<scheme>://daily` (stage 4 contract §4;
/// plan-local-habits §4). The router's `deepLinkBuilder` asks [resolve];
/// the splash asks [takePending] once loading ends.
///
/// - Cold: the link is kept as a pending launch target through the splash,
///   which opens the Daily if it is unlocked, else Home; a first launch's
///   Level 1 rule wins over both.
/// - Warm: the Daily opens over Home. A board on screen was saved when the
///   app went to the background, so nothing is lost. With the Daily locked
///   (the widget showing "opens after Level 2") nothing moves.
///
/// `widget_open` is logged once per tap, as the link arrives.
@lazySingleton
class WidgetLink {
  WidgetLink(this._analytics, this._daily, this._levels);

  final AnalyticsService _analytics;
  final DailyService _daily;
  final LevelRepository _levels;

  bool _pending = false;

  /// A cold link is waiting for the splash.
  bool get pending => _pending;

  /// Whether [uri] is the widget's: `<scheme>://daily`, or the bare
  /// `/daily` path the contract names.
  static bool isDailyLink(Uri uri) {
    if (uri.host == 'daily') return true;
    if (uri.host.isNotEmpty) return false;
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    return segments.length == 1 && segments.single == 'daily';
  }

  /// Decides for an incoming platform link. [initial] is the app's first
  /// link (a cold start).
  WidgetLinkAction resolve(Uri uri, {required bool initial}) {
    if (!isDailyLink(uri)) return WidgetLinkAction.passThrough;
    unawaited(_logOpen());
    // Before the splash has loaded the levels even a warm link behaves like
    // a cold one: the guards would send it to the splash anyway.
    if (initial || _levels.levelCount <= 0) {
      _pending = true;
      return WidgetLinkAction.viaSplash;
    }
    return _daily.isUnlocked
        ? WidgetLinkAction.openDaily
        : WidgetLinkAction.stay;
  }

  /// True once when a cold link is waiting; the splash then opens the Daily
  /// (when unlocked) after its load.
  bool takePending() {
    final was = _pending;
    _pending = false;
    return was;
  }

  /// A failed event is dropped silently (CLAUDE.md rule 3).
  Future<void> _logOpen() async {
    try {
      // TODO(M4): the kid path keeps this off for under-13s (BACKLOG M4 kid-path analytics).
      await _analytics.logEvent('widget_open');
    } on Object {
      // Analytics never reaches the player.
    }
  }
}
