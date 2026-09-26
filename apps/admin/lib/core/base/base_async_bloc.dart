import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesty_admin/core/base/base_async_state.dart';
import 'package:nesty_admin/core/base/run_guarded.dart';
import 'package:nesty_admin/core/error/app_exception.dart';

/// Base for event-driven async flows, e.g. an M5 level-editor controller that
/// queues edit/undo/redo events so they are handled strictly in order, or the
/// playtest board driving `nesty_core`'s `GameSession` (spec §15 #3).
/// Prefer `BaseAsyncCubit` everywhere else.
///
/// Events are handled one at a time, in the order they were added: the next
/// event starts only after the previous [handleEvent] has completed.
///
/// ```dart
/// class FooBloc extends BaseAsyncBloc<FooEvent, FooState> {
///   @override
///   Future<void> handleEvent(
///     FooEvent event,
///     Emitter<AsyncValue<FooState>> emit,
///   ) => switch (event) {
///     FooStarted() => runGuarded(emit, () async => const FooState()),
///     FooEdited(:final edit) => runGuarded(emit, () => _apply(edit)),
///   };
/// }
/// ```
abstract class BaseAsyncBloc<E, S> extends Bloc<E, AsyncValue<S>> {
  BaseAsyncBloc([AsyncValue<S>? initialState])
    : super(initialState ?? AsyncValue<S>.initial()) {
    // Why a single handler: bloc 9 runs handlers concurrently by default, and
    // every `on<...>` registration has its own subscription, so even a
    // sequential transformer per event type would not order events of
    // different types. One handler over the base event type, fed through
    // `asyncExpand`, is the only way to get FIFO without bloc_concurrency.
    super.on<E>(
      handleEvent,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }

  /// Handles one event. Implement it with an exhaustive `switch` over the
  /// sealed event type. It is never called for the next event until the
  /// returned future completes.
  @protected
  Future<void> handleEvent(E event, Emitter<AsyncValue<S>> emit);

  /// Subclasses must not register their own handlers: the event would then
  /// also run outside the ordered queue (twice, and out of order).
  @override
  void on<T extends E>(
    EventHandler<T, AsyncValue<S>> handler, {
    EventTransformer<T>? transformer,
  }) {
    throw StateError(
      '$runtimeType: implement handleEvent instead of calling on<$T>. '
      'BaseAsyncBloc registers the only handler so events stay in order.',
    );
  }

  /// Same contract as `BaseAsyncCubit.runGuarded`, for use inside
  /// [handleEvent]. Also stops if [emit] is already done (the bloc was closed
  /// while the body was running).
  @protected
  Future<void> runGuarded(
    Emitter<AsyncValue<S>> emit,
    Future<S> Function() body, {
    S? Function(AppException exception)? onError,
  }) async {
    if (isClosed || emit.isDone) return;
    final next = await resolveGuarded<S>(
      body: body,
      previousData: () => state.data,
      logName: runtimeType.toString(),
      onError: onError,
    );
    if (next == null || isClosed || emit.isDone) return;
    emit(next);
  }
}
