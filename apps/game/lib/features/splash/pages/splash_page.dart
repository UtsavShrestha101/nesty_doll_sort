import 'dart:async';

import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/ui/widgets/retry_view.dart';
import 'package:nesty_game/features/splash/cubit/splash_cubit.dart';

/// Spec §10.2 #1: logo and a quick loading bar, then Home.
///
/// TODO(design): logo wordmark and styled loading bar (design/screens/splash).
@RoutePage()
class SplashPage extends StatelessWidget implements AutoRouteWrapper {
  const SplashPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) =>
      BlocProvider(create: (_) => get<SplashCubit>()..load(), child: this);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SplashCubit, AsyncValue<SplashState>>(
      listenWhen: (previous, current) => !previous.hasData && current.hasData,
      // replaceAll: Splash must not stay underneath Home on the back stack.
      listener: (context, _) =>
          unawaited(context.router.replaceAll([const HomeRoute()])),
      builder: (context, state) => Scaffold(
        body: Center(
          child: switch (state) {
            AsyncValueError(:final exception) => RetryView(
              exception: exception,
              onRetry: context.read<SplashCubit>().load,
            ),
            // Data only lasts until the listener above replaces the route.
            AsyncValueInitial() ||
            AsyncValueLoading() ||
            AsyncValueData() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.localizations.appName,
                  style: context.displayMedium,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 160,
                  child: LinearProgressIndicator(
                    semanticsLabel: context.localizations.splashLoading,
                  ),
                ),
              ],
            ),
          },
        ),
      ),
    );
  }
}
