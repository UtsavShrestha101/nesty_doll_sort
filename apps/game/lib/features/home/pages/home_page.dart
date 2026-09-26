import 'dart:async';

import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/ui/widgets/retry_view.dart';
import 'package:nesty_game/features/home/cubit/home_cubit.dart';

/// Spec §10.2 #2. Placeholder layout: only the big "Level N" play button.
///
/// TODO(M2): the Home hero of frame 2.1: chapter background, coin pill,
/// wordmark, settings gear, idle dolls and PLAY with Level N and its tier.
/// TODO(M3): the Daily/Museum/Remove Ads tiles and the bottom nav.
@RoutePage()
class HomePage extends StatelessWidget implements AutoRouteWrapper {
  const HomePage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) =>
      BlocProvider(create: (_) => get<HomeCubit>()..load(), child: this);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocBuilder<HomeCubit, AsyncValue<HomeState>>(
          builder: (context, state) => switch (state) {
            AsyncValueData(:final data) => FilledButton(
              // ButtonStyle.textStyle ignores color, so the theme's
              // onPrimary still colors the label.
              style: FilledButton.styleFrom(
                textStyle: context.headlineMedium,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 20,
                ),
              ),
              onPressed: () => unawaited(
                context.router.push(
                  GameplayRoute(levelNumber: data.currentLevel),
                ),
              ),
              child: Text(context.localizations.levelTitle(data.currentLevel)),
            ),
            AsyncValueError(:final exception) => RetryView(
              exception: exception,
              onRetry: context.read<HomeCubit>().load,
            ),
            AsyncValueInitial() ||
            AsyncValueLoading() => const CircularProgressIndicator(),
          },
        ),
      ),
    );
  }
}
