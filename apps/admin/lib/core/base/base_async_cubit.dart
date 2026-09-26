import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesty_admin/core/base/base_async_state.dart';
import 'package:nesty_admin/core/base/run_guarded.dart';
import 'package:nesty_admin/core/error/app_exception.dart';

/// Base for every async cubit. Default to this; use `BaseAsyncBloc` only for
/// genuinely event-driven flows.
///
/// ```dart
/// @injectable
/// class FooCubit extends BaseAsyncCubit<FooState> {
///   FooCubit(this._repo);
///
///   Future<void> load() async {
///     emit(AsyncValue.loading(data: state.data));
///     await runGuarded(() async => FooState(items: await _repo.fetch()));
///   }
/// }
/// ```
abstract class BaseAsyncCubit<T> extends Cubit<AsyncValue<T>> {
  /// Not `const AsyncValue.initial()`: a const default can't mention `T`, so
  /// it would be an `AsyncValue<Never>` at runtime.
  BaseAsyncCubit([AsyncValue<T>? initialState])
    : super(initialState ?? AsyncValue<T>.initial());

  /// Runs [body] and emits its result as `AsyncValue.data`.
  ///
  /// It never emits `loading` itself — callers do that first when they want
  /// a spinner. On failure it emits `AsyncValue.error` carrying the previous
  /// `state.data`, unless [onError] returns a non-null recovery value, which
  /// is emitted as data instead (optimistic-rollback path). Cancellations
  /// ([AppExceptionKind.cancelled]) emit nothing. A closed cubit neither runs
  /// [body] nor emits after it completes.
  @protected
  Future<void> runGuarded(
    Future<T> Function() body, {
    T? Function(AppException exception)? onError,
  }) async {
    if (isClosed) return;
    final next = await resolveGuarded<T>(
      body: body,
      previousData: () => state.data,
      logName: runtimeType.toString(),
      onError: onError,
    );
    if (next == null || isClosed) return;
    emit(next);
  }
}
