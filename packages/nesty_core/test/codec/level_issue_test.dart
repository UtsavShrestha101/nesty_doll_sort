// Spec §5.3: "Invalid levels are rejected by the admin and skipped with a
// log entry in the game." Design §3: issues are collected (not fail-fast)
// as LevelIssue{code, severity, path (JSON pointer), slotId, args, message}.
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

void main() {
  group('LevelIssue', () {
    test('defaults: an error about the whole document, no args', () {
      final issue = LevelIssue(
        code: IssueCodes.shelfCount,
        message: 'Too many shelves',
      );
      expect(issue.severity, IssueSeverity.error);
      expect(issue.isError, isTrue);
      expect(issue.path, '');
      expect(issue.slotId, isNull);
      expect(issue.args, isEmpty);
    });

    test('a warning is not an error', () {
      final issue = LevelIssue(
        code: IssueCodes.unproven,
        message: 'Not proven',
        severity: IssueSeverity.warning,
      );
      expect(issue.isError, isFalse);
    });

    test('copies args and exposes them unmodifiable', () {
      final args = <String, Object>{'color': 'red'};
      final issue = LevelIssue(
        code: IssueCodes.lockColorAbsent,
        message: 'No red dolls',
        args: args,
      );
      args['color'] = 'blue';
      expect(issue.args, {'color': 'red'});
      expect(() => issue.args['x'] = 1, throwsUnsupportedError);
    });

    group('pointer (RFC 6901)', () {
      test('joins segments with /', () {
        expect(LevelIssue.pointer(['shelves', 0, 2]), '/shelves/0/2');
        expect(
          LevelIssue.pointer(['shelves', 0, 2, 'stack', 1]),
          '/shelves/0/2/stack/1',
        );
      });

      test('the empty path is the whole document', () {
        expect(LevelIssue.pointer(const []), '');
      });

      test('escapes ~ as ~0 and / as ~1', () {
        expect(LevelIssue.pointer(['a/b', 'c~d', '~1']), '/a~1b/c~0d/~01');
      });
    });

    test('equality by every field, args by content', () {
      LevelIssue make({Map<String, Object> args = const {'color': 'red'}}) =>
          LevelIssue(
            code: IssueCodes.alreadyFull,
            message: 'Already a full set',
            path: '/shelves/0/0/nest',
            slotId: 'r0c0',
            args: args,
          );
      expect(make(), make(args: {'color': 'red'}));
      expect(make().hashCode, make(args: {'color': 'red'}).hashCode);
      expect(make(), isNot(make(args: {'color': 'blue'})));
      expect(make(), isNot(make(args: const {})));
    });

    test('toString names severity, code, location and message', () {
      final issue = LevelIssue(
        code: IssueCodes.notConsecutive,
        message: 'Sizes must be consecutive',
        path: '/shelves/0/1/nest',
        slotId: 'r0c1',
      );
      expect(
        issue.toString(),
        'error nest.notConsecutive at /shelves/0/1/nest r0c1: '
        'Sizes must be consecutive',
      );
      expect(
        LevelIssue(code: IssueCodes.invalidJson, message: 'Bad').toString(),
        'error schema.invalidJson: Bad',
      );
    });
  });

  group('IssueCodes', () {
    test('includes every code of the M1 design (§3)', () {
      expect(
        IssueCodes.all,
        containsAll(const [
          'schema.unsupportedVersion',
          'schema.missingField',
          'schema.unknownField',
          'schema.wrongType',
          'slot.unknownType',
          'doll.badToken',
          'doll.unknownColor',
          'doll.sizeOutOfRange',
          'ice.negative',
          'gold.notSupported',
          'level.maxSizeOutOfRange',
          'layout.shelfCount',
          'layout.slotsPerShelf',
          'layout.noRoomForExtraSlots',
          'nest.empty',
          'nest.mixedColors',
          'nest.notConsecutive',
          'nest.alreadyFull',
          'counts.notFullSets',
          'tower.tooDeep',
          'tower.emptyAtStart',
          'locked.colorAbsent',
          'locked.colorAllSealed',
          'moves.noLegalFirstMove',
          'solver.unsolvable',
          'solver.unproven',
          'gen.segmentsInfeasible',
        ]),
      );
    });

    test('codes are unique "group.name" identifiers', () {
      expect(IssueCodes.all.toSet(), hasLength(IssueCodes.all.length));
      for (final code in IssueCodes.all) {
        expect(
          code,
          matches(RegExp(r'^[a-z]+\.[a-z][a-zA-Z]*$')),
          reason: code,
        );
      }
    });
  });
}
