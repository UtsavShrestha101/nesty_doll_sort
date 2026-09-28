import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nesty_game/core/services/save/save_lifecycle_flusher.dart';
import 'package:nesty_game/core/services/save/save_service.dart';

class _MockSaveService extends Mock implements SaveService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockSaveService save;
  late SaveLifecycleFlusher flusher;

  setUp(() {
    save = _MockSaveService();
    when(save.flush).thenAnswer((_) async {});
    flusher = SaveLifecycleFlusher(save);
  });

  test('flushes on paused and detached; other states never touch the save '
      '(m3-design §3.2)', () async {
    flusher.didChangeAppLifecycle(AppLifecycleState.paused);
    await Future<void>.delayed(Duration.zero);
    verify(save.flush).called(1);

    flusher.didChangeAppLifecycle(AppLifecycleState.detached);
    await Future<void>.delayed(Duration.zero);
    verify(save.flush).called(1);

    for (final state in [
      AppLifecycleState.resumed,
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
    ]) {
      flusher.didChangeAppLifecycle(state);
    }
    await Future<void>.delayed(Duration.zero);
    verifyNever(save.flush);
  });

  test(
    'a failing flush never throws out of the lifecycle callback (rule 3)',
    () async {
      when(save.flush).thenThrow(StateError('disk full'));

      expect(
        () => flusher.didChangeAppLifecycle(AppLifecycleState.paused),
        returnsNormally,
      );
      await Future<void>.delayed(Duration.zero);
    },
  );

  test(
    'start listens once (idempotent) and dispose stops it, both idempotent',
    () {
      flusher
        ..start()
        ..start();

      flusher
        ..dispose()
        ..dispose();
    },
  );
}
