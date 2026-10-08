import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/features/welcome_back/cubit/welcome_back_cubit.dart';

/// The welcome-back card's Play: Home, then the Daily, then today's board.
///
/// The daily's win card says "Back to Daily" and pops the board, so the
/// stack must hold the Daily under it (it then shows the relit streak card)
/// instead of Home. The request is the Daily's own Play's
/// (`DailyService.todayRequest`), so a board in progress resumes.
Future<void> playWelcomeBack(BuildContext context) async {
  final request = context.read<WelcomeBackCubit>().play();
  await context.router.root.pushAll([
    const DailyRoute(),
    GameplayRoute(request: request),
  ]);
}
