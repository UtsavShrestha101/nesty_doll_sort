import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/features/daily/share/daily_share_text.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

/// The daily's Share text (spec-prop §10.2 #11; copy.md G.6; phase 4
/// architecture §3.10): three lines, one belly-symbol emoji per family in
/// board order, spoiler-free by construction (never the board, a slot id or
/// a move list).
void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));
  final day = LocalDate(2026, 9, 30);

  String textFor({
    List<DollColor> families = const [
      DollColor.red,
      DollColor.blue,
      DollColor.green,
      DollColor.purple,
      DollColor.navy,
    ],
    int moves = 18,
    int streakDay = 12,
    bool streakLit = true,
  }) => DailyShareText.of(
    l10n,
    localeName: 'en_US',
    data: (
      date: day,
      families: families,
      moves: moves,
      streakDay: streakDay,
      streakLit: streakLit,
    ),
  );

  test("copy.md G.6's example, exactly", () {
    expect(
      textFor(),
      'Nesty Daily · Sep 30\n'
      '❤️ 💧 🍃 ⭐ 🌙\n'
      'Solved in 18 moves · Day 12 🔥',
    );
  });

  test('every DollColor has its own glyph, none shared', () {
    final glyphs = {
      for (final color in DollColor.values) l10n.dailyShareGlyph(color.id),
    };
    expect(glyphs, hasLength(DollColor.values.length));
    expect(glyphs, isNot(contains('🪆')));
  });

  test('a streak of 0, or a paused one, takes the no-streak line', () {
    for (final (day, lit) in [(0, true), (5, false)]) {
      final text = textFor(streakDay: day, streakLit: lit);
      expect(text.split('\n').last, 'Solved in 18 moves', reason: '$day $lit');
      expect(text, isNot(contains('🔥')));
    }
  });

  test('one move reads in the singular', () {
    expect(textFor(moves: 1).split('\n').last, 'Solved in 1 move · Day 12 🔥');
    expect(
      textFor(moves: 1, streakDay: 0).split('\n').last,
      'Solved in 1 move',
    );
  });

  test('the glyph row is capped at maxGlyphs (12), in board order', () {
    final families = [for (var i = 0; i < 20; i++) DollColor.values[i % 10]];
    final row = textFor(families: families).split('\n')[1].split(' ');
    expect(DailyShareText.maxGlyphs, 12);
    expect(row, hasLength(12));
    expect(row.first, l10n.dailyShareGlyph('red'));
    expect(row[1], l10n.dailyShareGlyph('orange'));
  });

  test('never carries a colour name, a slot id or a move list', () {
    final text = textFor().toLowerCase();
    for (final leak in ['red', 'blue', 'green', 'slot', 'r0c', 'row']) {
      expect(text, isNot(contains(leak)), reason: leak);
    }
  });
}
