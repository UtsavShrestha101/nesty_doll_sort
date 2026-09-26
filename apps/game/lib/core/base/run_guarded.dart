import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/error/app_exception.dart';

/// Shared body of `BaseAsyncCubit.runGuarded` and `BaseAsyncBloc.runGuarded`,
/// so the two can never drift apart.
///
/// Returns the state to emit, or `null` when nothing should be emitted
/// (the work was cancelled).
///
/// * success → `data(result)`
/// * [AppExceptionKind.cancelled] → `null` (swallowed, nothing logged)
/// * any other error → logged, then `data(onError(e))` if [onError] returns a
///   non-null recovery value, else `error(exception, data: previousData())`.
Future<AsyncValue<T>?> resolveGuarded<T>({
  required Future<T> Function() body,
  required T? Function() previousData,
  required String logName,
  T? Function(AppException exception)? onError,
}) async {
  try {
    return AsyncValue.data(data: await body());
  } on Object catch (error, stackTrace) {
    final exception = AppException.wrap(error, stackTrace);
    if (exception.isCancellation) return null;

    // TODO(M4): also report as a Crashlytics non-fatal (spec §14.4).
    developer.log(
      exception.message,
      name: logName,
      error: exception.cause ?? exception,
      stackTrace: exception.stackTrace ?? stackTrace,
    );
    // developer.log never reaches the `flutter run` terminal, so a bug inside
    // a guarded body would otherwise only show up as the generic retry view.
    // Not FlutterError.reportError: expected failures (bad credentials, a
    // failed load) aren't framework errors, and tests exercise them.
    if (kDebugMode) {
      debugPrint(
        '[$logName] ${exception.kind.name}: ${exception.message}\n'
        '${exception.stackTrace ?? stackTrace}',
      );
    }

    final recovery = onError?.call(exception);
    if (recovery != null) return AsyncValue.data(data: recovery);
    return AsyncValue.error(exception: exception, data: previousData());
  }
}
