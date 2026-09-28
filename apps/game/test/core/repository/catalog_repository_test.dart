import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/repository/bundled_catalog_repository.dart';
import 'package:nesty_game/core/repository/fake_catalog_repository.dart';
import 'package:nesty_render/nesty_render.dart';

/// The bundled catalog (spec §7.1, §7.2, §7.4; docs/plans/m3-design.md
/// §9.1): frames 7.3 and 7.7's prices, the design's ten figurines, and
/// chapters 7–10 on the six themes.
void main() {
  final catalog = BundledCatalogRepository();

  test('ten chapters of 20 levels, each with its figurine', () {
    expect(catalog.chapters, hasLength(10));
    for (final (i, chapter) in catalog.chapters.indexed) {
      expect(chapter.number, i + 1);
      expect(chapter.id, 'ch${(i + 1).toString().padLeft(2, '0')}');
      expect(chapter.levels, 20);
      expect(chapter.figurine.number, i + 1);
      expect(catalog.chapterNumbered(i + 1), chapter);
      expect(catalog.chapter(chapter.id), chapter);
      // Chapters 7+ cycle ch01–ch06 until their art arrives (Q38).
      expect(chapter.themeId, ChapterTheme.forChapter(i + 1).id);
    }
    expect(catalog.chapter('ch11'), isNull);
    expect(catalog.chapterNumbered(0), isNull);
  });

  test('the figurine art names are design/museum/png\'s', () {
    final design = Directory('../../design/museum/png');
    for (final chapter in catalog.chapters) {
      for (final asset in [
        chapter.figurine.artAsset,
        chapter.figurine.lockedArtAsset,
      ]) {
        final name = asset.split('/').last;
        expect(asset, startsWith('assets/museum/'));
        expect(File('${design.path}/$name').existsSync(), isTrue, reason: name);
      }
    }
  });

  test('skins: the frame 7.3 prices, Space by default, forest-bear unsold', () {
    final prices = {for (final s in catalog.skins) s.id: s.priceCoins};
    expect(prices, {
      'classic': 0,
      'space': 1200,
      'ocean': 800,
      'sweets': 1500,
      'forest': 2000,
      'winter': 3000,
      'forest-bear': 0,
    });
    expect(catalog.skin('forest-bear')?.sold, isFalse);
    for (final skin in catalog.skins) {
      expect(skin.previewColors, hasLength(3), reason: skin.id);
      expect(Directory('../../design/skins/${skin.id}').existsSync(), isTrue);
    }
  });

  test('themes: frame 7.7 prices, owned once their chapter is reached', () {
    final prices = {for (final t in catalog.themes) t.id: t.priceCoins};
    expect(prices, {
      'ch01': 0,
      'ch02': 800,
      'ch03': 1000,
      'ch04': 1200,
      'ch05': 1500,
      'ch06': 2000,
    });
    final ch04 = catalog.theme('ch04')!;
    expect(
      ch04.isOwned(ownedThemes: const ['ch01'], reachedChapter: 3),
      isFalse,
    );
    expect(
      ch04.isOwned(ownedThemes: const ['ch01'], reachedChapter: 4),
      isTrue,
    );
    expect(
      ch04.isOwned(ownedThemes: const ['ch04'], reachedChapter: 1),
      isTrue,
    );
  });

  test('the fake serves the bundled catalog unless told otherwise', () {
    final fake = FakeCatalogRepository();
    expect(fake.chapters, catalog.chapters);
    expect(fake.skins, catalog.skins);
    expect(fake.themes, catalog.themes);
    final small = FakeCatalogRepository(skins: [catalog.skin('ocean')!]);
    expect(small.skin('classic'), isNull);
    expect(small.skin('ocean')?.priceCoins, 800);
  });
}
