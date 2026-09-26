/// A plain-text table with a header row and two spaces between columns, for
/// the CLI's reports. Columns listed in [rightAligned] (numbers) are padded
/// on the left.
String renderTable(
  List<String> headers,
  List<List<String>> rows, {
  Set<int> rightAligned = const {},
}) {
  final widths = [
    for (var c = 0; c < headers.length; c++)
      [
        headers[c].length,
        for (final row in rows) row[c].length,
      ].reduce((a, b) => a > b ? a : b),
  ];
  String line(List<String> cells) => [
    for (var c = 0; c < cells.length; c++)
      rightAligned.contains(c)
          ? cells[c].padLeft(widths[c])
          : cells[c].padRight(widths[c]),
  ].join('  ').trimRight();
  return [line(headers), for (final row in rows) line(row)].join('\n');
}
