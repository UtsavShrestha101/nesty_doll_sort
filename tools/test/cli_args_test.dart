import 'dart:io';

import 'package:nesty_tools/src/cli_args.dart';
import 'package:nesty_tools/src/file_writes.dart';
import 'package:nesty_tools/src/repo_root.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('CliArgs', () {
    test('parses flags, options and positionals', () {
      final args = CliArgs.parse(
        ['--check', '--out=a.json', '--seed', '7', 'levels.json'],
        flags: {'check'},
        options: {'out', 'seed'},
      );
      expect(args.flag('check'), isTrue);
      expect(args.options, {'out': 'a.json', 'seed': '7'});
      expect(args.rest, ['levels.json']);
    });

    test('rejects unknown arguments and missing option values', () {
      expect(
        () => CliArgs.parse(['--chek'], flags: {'check'}),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('--check'),
          ),
        ),
      );
      expect(
        () => CliArgs.parse(['--out'], options: {'out'}),
        throwsFormatException,
      );
      expect(
        () => CliArgs.parse(['--check=yes'], flags: {'check'}),
        throwsFormatException,
      );
    });
  });

  group('writeStringIfChanged', () {
    test('creates, skips identical content and updates', () {
      final dir = Directory.systemTemp.createTempSync('nesty_write_');
      addTearDown(() => dir.deleteSync(recursive: true));
      final file = File(p.join(dir.path, 'a', 'b.txt'));
      expect(
        writeStringIfChanged(file, 'x', dryRun: true),
        WriteOutcome.created,
      );
      expect(file.existsSync(), isFalse);
      expect(writeStringIfChanged(file, 'x'), WriteOutcome.created);
      expect(writeStringIfChanged(file, 'x'), WriteOutcome.unchanged);
      expect(
        writeStringIfChanged(file, 'y', dryRun: true),
        WriteOutcome.updated,
      );
      expect(file.readAsStringSync(), 'x');
      expect(writeStringIfChanged(file, 'y'), WriteOutcome.updated);
      expect(file.readAsStringSync(), 'y');
    });
  });

  test('findRepoRoot finds the workspace from a nested directory', () {
    final root = findRepoRoot();
    expect(File(p.join(root.path, 'CLAUDE.md')).existsSync(), isTrue);
    expect(findRepoRoot(p.join(root.path, 'tools', 'lib')).path, root.path);
    expect(() => findRepoRoot(Directory.systemTemp.path), throwsStateError);
  });
}
