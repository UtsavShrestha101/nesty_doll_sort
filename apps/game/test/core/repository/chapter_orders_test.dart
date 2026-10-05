import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/repository/catalog_models.dart';
import 'package:nesty_game/core/repository/fake_catalog_repository.dart';

/// `ChapterOrders`: the one place a chapter's block of campaign orders is
/// found (spec §7.1, 20 levels each).
void main() {
  final chapters = FakeCatalogRepository().chapters;

  test('firstOrder is 1, 21, … 181 for chapters 1, 2, … 10', () {
    expect(chapters.first.firstOrder, 1);
    expect(chapters[1].firstOrder, 21);
    expect(chapters[9].firstOrder, 181);
  });

  test('doneAt counts the levels won in the chapter, clamped to 0-20', () {
    final second = chapters[1];
    expect(second.doneAt(1), 0);
    expect(second.doneAt(21), 0);
    expect(second.doneAt(31), 10);
    expect(second.doneAt(41), 20);
    expect(second.doneAt(150), 20);
  });
}
