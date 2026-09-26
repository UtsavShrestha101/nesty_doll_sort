import 'package:nesty_tools/src/levels/cli_context.dart';
import 'package:nesty_tools/src/levels/fixtures_check.dart';
import 'package:nesty_tools/src/levels/text_table.dart';

/// `fixtures check`: nesty_core's solver fixtures are canonical, pass rules
/// 1–7, and give the solver's expected verdict and optimal move count
/// ([checkFixtures]).
int runFixturesCheck(CliContext cli, List<String> arguments) {
  cli.parse(arguments);
  final check = checkFixtures(cli.root);
  if (check.results.isNotEmpty) {
    cli.out.writeln(
      renderTable(
        ['fixture', 'expected', 'verdict', 'moves', 'nodes', 'budget-limited'],
        [
          for (final r in check.results)
            [
              '${r.folder}/${r.name}',
              r.folder == 'solvable'
                  ? '${r.expectedMoves ?? '?'} moves'
                  : 'unsolvable',
              r.solve?.verdict.name ?? '-',
              r.solve?.solution?.length.toString() ?? '-',
              r.solve?.nodes.toString() ?? '-',
              r.budgetSolve == null
                  ? ''
                  : '${r.budgetSolve!.verdict.name} at ${r.budgetSolve!.nodes} nodes',
            ],
        ],
        rightAligned: const {3, 4},
      ),
    );
  }
  final errors = cli.report(
    check.findings,
    what: 'fixtures check (${check.results.length} fixtures)',
  );
  return errors == 0 ? ExitCodes.ok : ExitCodes.failed;
}
