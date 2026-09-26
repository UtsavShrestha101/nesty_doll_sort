/// The `runGuarded` / `AsyncValue` contract every feature cubit relies on.
/// Kept identical to the game's copy (apps/game/test/core/base/).
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_admin/core/base/base_async_cubit.dart';
import 'package:nesty_admin/core/base/base_async_state.dart';
import 'package:nesty_admin/core/error/app_exception.dart';

/// Minimal concrete cubit so the base class is tested on its own.
class _ProbeCubit extends BaseAsyncCubit<String> {
  Future<void> run(
    Future<String> Function() body, {
    String? Function(AppException exception)? onError,
  }) => runGuarded(body, onError: onError);
}

TypeMatcher<AsyncValueError<String>> _errorWith({
  required AppExceptionKind kind,
  String? data,
}) => isA<AsyncValueError<String>>()
    .having((s) => s.exception.kind, 'kind', kind)
    .having((s) => s.data, 'data', data);

void main() {
  group('AsyncValue', () {
    test('the case getters check the case, not the presence of data', () {
      const loading = AsyncValue<String>.loading(data: 'held');
      expect(loading.isLoading, isTrue);
      expect(loading.hasData, isFalse);
      expect(loading.data, 'held');

      const initial = AsyncValue<String>.initial(data: 'held');
      expect(initial.isInitial, isTrue);
      expect(initial.hasData, isFalse);
      expect(initial.data, 'held');
    });

    test('exceptionOrNull is only set on the error case', () {
      const exception = AppException(AppExceptionKind.network);
      expect(const AsyncValue<String>.data(data: 'ok').exceptionOrNull, isNull);
      expect(
        const AsyncValue<String>.error(exception: exception).exceptionOrNull,
        same(exception),
      );
    });

    test('the default initial state is typed, not AsyncValue<Never>', () {
      final cubit = _ProbeCubit();
      addTearDown(cubit.close);
      expect(cubit.state, isA<AsyncValueInitial<String>>());
      expect(cubit.state.isInitial, isTrue);
    });
  });

  group('runGuarded', () {
    blocTest<_ProbeCubit, AsyncValue<String>>(
      'emits exactly one data state and never loading on its own',
      build: _ProbeCubit.new,
      act: (cubit) => cubit.run(() async => 'done'),
      expect: () => [const AsyncValue<String>.data(data: 'done')],
    );

    blocTest<_ProbeCubit, AsyncValue<String>>(
      'an AppException becomes an error carrying the previous data',
      build: _ProbeCubit.new,
      seed: () => const AsyncValue.data(data: 'previous'),
      act: (cubit) => cubit.run(
        () async => throw const AppException(AppExceptionKind.network),
      ),
      expect: () => [
        _errorWith(kind: AppExceptionKind.network, data: 'previous'),
      ],
    );

    blocTest<_ProbeCubit, AsyncValue<String>>(
      'any other throwable is wrapped as unknown, keeping the cause',
      build: _ProbeCubit.new,
      act: (cubit) => cubit.run(() async => throw StateError('kaboom')),
      expect: () => [
        _errorWith(
          kind: AppExceptionKind.unknown,
        ).having((s) => s.exception.cause, 'cause', isA<StateError>()),
      ],
    );

    blocTest<_ProbeCubit, AsyncValue<String>>(
      'a cancellation emits nothing and skips onError',
      build: _ProbeCubit.new,
      seed: () => const AsyncValue.data(data: 'previous'),
      act: (cubit) => cubit.run(
        () async => throw const AppException(AppExceptionKind.cancelled),
        onError: (_) => fail('onError must not run on a cancellation'),
      ),
      expect: () => <AsyncValue<String>>[],
      verify: (cubit) => expect(cubit.state.data, 'previous'),
    );

    blocTest<_ProbeCubit, AsyncValue<String>>(
      'a non-null onError recovery is emitted as data',
      build: _ProbeCubit.new,
      seed: () => const AsyncValue.data(data: 'previous'),
      act: (cubit) => cubit.run(
        () async => throw const AppException(AppExceptionKind.network),
        onError: (exception) {
          expect(exception.kind, AppExceptionKind.network);
          return 'rolled back';
        },
      ),
      expect: () => [const AsyncValue<String>.data(data: 'rolled back')],
    );

    blocTest<_ProbeCubit, AsyncValue<String>>(
      'a null onError recovery falls through to the error state',
      build: _ProbeCubit.new,
      act: (cubit) => cubit.run(
        () async => throw const AppException(AppExceptionKind.content),
        onError: (_) => null,
      ),
      expect: () => [_errorWith(kind: AppExceptionKind.content)],
    );

    test('a closed cubit neither runs the body nor emits', () async {
      final cubit = _ProbeCubit();
      await cubit.close();
      var ran = false;

      await cubit.run(() async {
        ran = true;
        return 'done';
      });

      expect(ran, isFalse);
      expect(cubit.state.isInitial, isTrue);
    });

    test('a cubit closed mid-flight does not emit its result', () async {
      final cubit = _ProbeCubit();
      final emitted = <AsyncValue<String>>[];
      final subscription = cubit.stream.listen(emitted.add);
      addTearDown(subscription.cancel);

      final inFlight = cubit.run(() async {
        await Future<void>.delayed(Duration.zero);
        return 'late';
      });
      await cubit.close();
      await inFlight;

      expect(emitted, isEmpty);
    });
  });
}
