import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_admin/core/base/base_async_bloc.dart';
import 'package:nesty_admin/core/base/base_async_state.dart';
import 'package:nesty_admin/core/error/app_exception.dart';

sealed class _ProbeEvent {}

final class _Succeed extends _ProbeEvent {}

final class _Fail extends _ProbeEvent {}

final class _Cancel extends _ProbeEvent {}

/// Finishes well after an event added right behind it would.
final class _Slow extends _ProbeEvent {}

final class _Fast extends _ProbeEvent {}

class _ProbeBloc extends BaseAsyncBloc<_ProbeEvent, int> {
  @override
  Future<void> handleEvent(_ProbeEvent event, Emitter<AsyncValue<int>> emit) =>
      switch (event) {
        _Succeed() => runGuarded(emit, () async => 1),
        _Fail() => runGuarded(
          emit,
          () async => throw const AppException(AppExceptionKind.network),
        ),
        _Cancel() => runGuarded(
          emit,
          () async => throw const AppException(AppExceptionKind.cancelled),
        ),
        _Slow() => runGuarded(emit, () async {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return 10;
        }),
        _Fast() => runGuarded(emit, () async => 20),
      };
}

/// Breaks the one-handler rule on purpose.
class _SelfRegisteringBloc extends BaseAsyncBloc<_ProbeEvent, int> {
  _SelfRegisteringBloc() {
    on<_Succeed>((event, emit) {});
  }

  @override
  Future<void> handleEvent(
    _ProbeEvent event,
    Emitter<AsyncValue<int>> emit,
  ) async {}
}

void main() {
  test('starts in a typed initial state', () {
    final bloc = _ProbeBloc();
    addTearDown(bloc.close);
    expect(bloc.state, isA<AsyncValueInitial<int>>());
  });

  blocTest<_ProbeBloc, AsyncValue<int>>(
    'runGuarded shares the cubit contract: data, then error keeping data',
    build: _ProbeBloc.new,
    act: (bloc) => bloc
      ..add(_Succeed())
      ..add(_Fail()),
    expect: () => [
      const AsyncValue<int>.data(data: 1),
      isA<AsyncValueError<int>>()
          .having((s) => s.data, 'data', 1)
          .having((s) => s.exception.kind, 'kind', AppExceptionKind.network),
    ],
  );

  blocTest<_ProbeBloc, AsyncValue<int>>(
    'a cancellation emits nothing',
    build: _ProbeBloc.new,
    act: (bloc) => bloc.add(_Cancel()),
    expect: () => <AsyncValue<int>>[],
  );

  // bloc 9 handles events concurrently by default; the level editor
  // (edit/undo/redo) relies on this ordering.
  blocTest<_ProbeBloc, AsyncValue<int>>(
    'handles events strictly in the order they were added',
    build: _ProbeBloc.new,
    act: (bloc) => bloc
      ..add(_Slow())
      ..add(_Fast()),
    wait: const Duration(milliseconds: 100),
    expect: () => const [
      AsyncValue<int>.data(data: 10),
      AsyncValue<int>.data(data: 20),
    ],
    verify: (bloc) => expect(bloc.state, const AsyncValue<int>.data(data: 20)),
  );

  test('a subclass cannot register its own on<> handler', () {
    expect(_SelfRegisteringBloc.new, throwsStateError);
  });
}
