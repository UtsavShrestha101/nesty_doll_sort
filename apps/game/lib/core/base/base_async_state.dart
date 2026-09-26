import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nesty_game/core/error/app_exception.dart';

part 'base_async_state.freezed.dart';

/// The state every async cubit/bloc emits.
///
/// `initial`, `loading` and `error` optionally carry the previous [data] so a
/// failed refresh keeps rendering what the screen already had.
///
/// The case classes are public so callers can use Dart 3 pattern matching:
/// `switch (state) { AsyncValueData(:final data) => ..., ... }`. They are not
/// named `AsyncError` etc. because `dart:async` already exports `AsyncError`.
@freezed
sealed class AsyncValue<T> with _$AsyncValue<T> {
  const factory AsyncValue.initial({T? data}) = AsyncValueInitial<T>;

  const factory AsyncValue.loading({T? data}) = AsyncValueLoading<T>;

  const factory AsyncValue.data({required T data}) = AsyncValueData<T>;

  const factory AsyncValue.error({required AppException exception, T? data}) =
      AsyncValueError<T>;
}

/// Runtime-type checks on the four cases. Note these ask "which case is this",
/// not "is there data": `AsyncValue.loading(data: x).hasData` is false even
/// though `.data` is `x`.
extension AsyncValueX<T> on AsyncValue<T> {
  bool get isInitial => this is AsyncValueInitial<T>;

  bool get isLoading => this is AsyncValueLoading<T>;

  bool get hasData => this is AsyncValueData<T>;

  bool get hasError => this is AsyncValueError<T>;

  /// The failure on the error case, `null` on every other case.
  AppException? get exceptionOrNull => switch (this) {
    AsyncValueError<T>(:final exception) => exception,
    _ => null,
  };
}
