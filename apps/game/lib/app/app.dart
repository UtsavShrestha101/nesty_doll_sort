import 'dart:async';

import 'package:nesty_game/app/localization_cubit/language_cubit.dart';
import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/flavor/flavor_config.dart';
import 'package:nesty_game/core/models/reduce_motion_mode.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/router/music_route_observer.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/ui/theme/app_theme.dart';
import 'package:nesty_game/core/ui/theme/reduce_motion_override.dart';
import 'package:nesty_game/core/ui/widgets/feedback/toast_queue.dart';

/// Root widget: app-level cubits + `MaterialApp.router`.
class App extends StatefulWidget {
  const App({required this.router, super.key});

  final AppRouter router;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // Built once so a locale rebuild of MaterialApp keeps the same router
  // delegate and navigation stack. The music follows the page on top
  // (AUDIO.md "Music loops").
  late final RouterConfig<UrlState> _routerConfig = widget.router.config(
    navigatorObservers: () => [get<MusicRouteObserver>()],
  );

  final DatabaseService _database = get<DatabaseService>();

  /// The reduce-motion override (E14; docs/plans/m7-design.md §14), read
  /// once and then followed live so a change from Pause → Settings reaches
  /// every screen, including the one already on top.
  late ReduceMotionMode _reduceMotionMode = _database.reduceMotion;
  StreamSubscription<ReduceMotionMode>? _reduceMotionSubscription;

  @override
  void initState() {
    super.initState();
    _reduceMotionSubscription = _database.reduceMotionChanges.listen((mode) {
      if (mounted) setState(() => _reduceMotionMode = mode);
    });
  }

  @override
  void dispose() {
    unawaited(_reduceMotionSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // App-level cubits only; feature cubits are provided at their route.
      providers: [BlocProvider.value(value: get<LanguageCubit>())],
      child: BlocBuilder<LanguageCubit, LanguageState>(
        buildWhen: (previous, current) =>
            previous.currentLanguageCode != current.currentLanguageCode,
        builder: (context, languageState) => MaterialApp.router(
          title: FlavorConfig.values.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          locale: languageState.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: _routerConfig,
          // Respect system text scaling in menus, up to 1.3× (spec §16),
          // then the reduce-motion override inside it (E14, m7-design
          // §14): every reader of `MediaQuery.disableAnimations`
          // (`context.reduceMotion`, `LottieFxView`, the UI kit's duration
          // tokens, the board's `MotionSpec`) follows it without change.
          // System follows either OS flag, iOS's Reduce Motion included
          // (review R7).
          //
          // The app's toast queue sits over every route (phase 4
          // architecture §3.12): `NestyToast.show` from any screen waits
          // its turn there; a result card adds its own scoped host.
          builder: (context, child) => MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: ReduceMotionOverride(
              mode: _reduceMotionMode,
              child: ToastHost(
                top: ToastHost.appTop,
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
