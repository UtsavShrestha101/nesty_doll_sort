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
import 'package:nesty_game/core/ui/theme/locale_script.dart';
import 'package:nesty_game/core/ui/theme/reduce_motion_override.dart';
import 'package:nesty_game/core/ui/widgets/feedback/toast_queue.dart';

/// Root widget: app-level cubits + `MaterialApp.router`.
class App extends StatefulWidget {
  const App({required this.router, super.key});

  final AppRouter router;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  // Built once so a locale rebuild of MaterialApp keeps the same router
  // delegate and navigation stack. The music follows the page on top
  // (AUDIO.md "Music loops").
  late final RouterConfig<UrlState> _routerConfig = widget.router.config(
    navigatorObservers: () => [get<MusicRouteObserver>()],
  );

  final DatabaseService _database = get<DatabaseService>();

  /// The app's language (spec §16): the setting resolved against the
  /// phone's languages, which this root feeds it from the binding at start
  /// and on every change (l10n plan §1.4).
  final LanguageCubit _language = get<LanguageCubit>();

  /// The reduce-motion override (E14; docs/plans/m7-design.md §14), read
  /// once and then followed live so a change from Pause → Settings reaches
  /// every screen, including the one already on top.
  late ReduceMotionMode _reduceMotionMode = _database.reduceMotion;
  StreamSubscription<ReduceMotionMode>? _reduceMotionSubscription;

  @override
  void initState() {
    super.initState();
    final binding = WidgetsBinding.instance..addObserver(this);
    _language.deviceLocalesChanged(binding.platformDispatcher.locales);
    _reduceMotionSubscription = _database.reduceMotionChanges.listen((mode) {
      if (mounted) setState(() => _reduceMotionMode = mode);
    });
  }

  /// The phone's language list changed (Android while the app runs; iOS
  /// relaunches): a player who follows the phone sees the new language at
  /// once.
  @override
  void didChangeLocales(List<Locale>? locales) {
    _language.deviceLocalesChanged(
      locales ?? WidgetsBinding.instance.platformDispatcher.locales,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_reduceMotionSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // App-level cubits only; feature cubits are provided at their route.
      providers: [BlocProvider.value(value: _language)],
      child: BlocBuilder<LanguageCubit, LanguageState>(
        buildWhen: (previous, current) =>
            previous.currentLanguageCode != current.currentLanguageCode,
        builder: (context, languageState) => MaterialApp.router(
          title: FlavorConfig.values.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.forLocale(languageState.locale),
          // Always the resolved language (never null), so Flutter's own
          // matching, whose fallback is `supportedLocales.first`, never
          // picks a different one; the callback answers as the resolver
          // does for the same reason.
          locale: languageState.locale,
          localeListResolutionCallback:
              AppLocaleResolver.app.resolveForMaterialApp,
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
            // Japanese is drawn at 0.94 of every size (tokens font.scripts).
            child: LocaleScriptScope(
              child: ReduceMotionOverride(
                mode: _reduceMotionMode,
                child: ToastHost.app(child: child ?? const SizedBox.shrink()),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
