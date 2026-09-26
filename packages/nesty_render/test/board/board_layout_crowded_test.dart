// Boards the design never drew (D22): rows of 5–6 slots, 1 and 4 shelves,
// maxSize 6. BoardLayout extends the design's system for them; nothing on
// the board may collide.
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_render/nesty_render.dart';

import 'board_fixtures.dart';

const _eps = 1e-6;

/// The highest point any piece of [s] reaches: its tallest doll on the
/// stand, its glass case (locked slots), its ice overlay (any slot) and, on
/// the top shelf, its deepest buried silhouettes (towers). Excluded: a lower
/// shelf's buried nests, which peek over the plank above by design (D21),
/// and the doll sealed in a case, which may stand taller than its case
/// exactly as the design's maxSize-5 doll does (NestyBoard:169: 6 dp above
/// it; checked against the designed row by [_expectSealedAndFrozenFit]).
double _contentTop(SlotGeometry s, int maxSize) {
  var top = s.dollTopY(maxSize, s.surfaceY);
  if (s.kind == SlotShapeKind.locked && s.glassCaseRect.top < top) {
    top = s.glassCaseRect.top;
  }
  if (s.iceRect.top < top) top = s.iceRect.top;
  if (s.row == 0 && s.kind == SlotShapeKind.tower) {
    for (
      var buried = 1;
      buried <= BoardLayoutConstants.maxBuriedNests;
      buried++
    ) {
      final silhouette = s.buriedSilhouetteRect(
        buried,
        maxSize,
        buried: buried,
      );
      if (silhouette.top < top) top = silhouette.top;
    }
  }
  return top;
}

/// On a crowded row, a doll sealed in a case or frozen in ice never looks
/// worse than on the narrowest full-size row (4 slots) of the same preset
/// (review
/// RENDER-3): it overhangs its case's sides, and rises above the case top
/// or the ice top, by no more than the designed row does (the design's own
/// maxSize-5 doll is 89 wide in an 86-wide case), scaled with the row's
/// pieces.
void _expectSealedAndFrozenFit(BoardGeometry g, String label) {
  final maxSize = g.shape.maxSize;
  final reference = BoardLayout.compute(
    board([
      for (var r = 0; r < g.shelves.length; r++) 'olto',
    ], maxSize: maxSize),
    BoardViewport.reference,
  );
  final designed = reference.slot('r0c1');
  final designedScale = designed.furnitureScale;
  // A tower's stand is taller, so its doll sits higher against the ice.
  double iceOverOf(SlotGeometry d) =>
      math.max(0.0, d.iceRect.top - d.dollTopY(maxSize, d.surfaceY));
  final iceOverOpen = iceOverOf(reference.slot('r0c0'));
  final iceOverTower = iceOverOf(reference.slot('r0c2'));
  final caseOver = math.max(
    0.0,
    designed.glassCaseRect.top -
        designed.dollTopY(maxSize, designed.lockedDollBaseY),
  );
  final sideOver = math.max(
    0.0,
    designed.dollWidth(maxSize) - designed.glassCaseRect.width,
  );
  for (final s in g.slots) {
    // Only rows that shrink their pieces (5–6 slots); a full-size row keeps
    // the design's own proportions (a 3-slot row's maxSize-6 doll is wider
    // than its case already: BACKLOG "Design gaps").
    if (s.pieceScale >= g.preset.pieceScale) continue;
    final ratio = s.furnitureScale / designedScale;
    final reason = '$label: ${s.id}';
    expect(
      s.dollWidth(maxSize) - s.glassCaseRect.width,
      lessThanOrEqualTo(sideOver * ratio + _eps),
      reason: '$reason (sealed doll wider than its case)',
    );
    expect(
      s.glassCaseRect.top - s.dollTopY(maxSize, s.lockedDollBaseY),
      lessThanOrEqualTo(caseOver * ratio + _eps),
      reason: '$reason (sealed doll above its case)',
    );
    final iceOver = s.kind == SlotShapeKind.tower ? iceOverTower : iceOverOpen;
    expect(
      s.iceRect.top - s.dollTopY(maxSize, s.surfaceY),
      lessThanOrEqualTo(iceOver * ratio + _eps),
      reason: '$reason (frozen doll above its ice)',
    );
  }
}

void _expectNoCollisions(BoardGeometry g, String label) {
  final maxSize = g.shape.maxSize;
  final s0 = g.scale;
  for (final shelf in g.shelves) {
    final slots = shelf.slots;
    for (var i = 1; i < slots.length; i++) {
      final a = slots[i - 1];
      final b = slots[i];
      final reason = '$label: ${a.id} vs ${b.id}';
      expect(
        a.standRect.right,
        lessThanOrEqualTo(b.standRect.left + _eps),
        reason: reason,
      );
      expect(
        a.dollRect(maxSize).right,
        lessThanOrEqualTo(b.dollRect(maxSize).left + _eps),
        reason: reason,
      );
      expect(
        a.glassCaseRect.right,
        lessThanOrEqualTo(b.glassCaseRect.left + _eps),
        reason: reason,
      );
      // Neighbouring ice overlays may touch no more than they do on the
      // designed 4-slot row (96 wide at pitch 93: 3 dp).
      expect(
        a.iceRect.right - b.iceRect.left,
        lessThanOrEqualTo(3 * s0 + _eps),
        reason: reason,
      );
      // Below a 48 dp pitch the 48 dp minimum makes columns overlap and the
      // nearest centre wins (board_layout_screens_test).
      if (shelf.pitch >= BoardLayoutConstants.minHitExtent) {
        expect(
          a.hitRect.right,
          lessThanOrEqualTo(b.hitRect.left + _eps),
          reason: reason,
        );
      }
    }
    for (final s in slots) {
      // A doll never outgrows its column (render §1, dollMinGap).
      expect(
        s.dollWidth(maxSize),
        lessThanOrEqualTo(
          s.pitch - BoardLayoutConstants.dollMinGap * s0 + _eps,
        ),
        reason: '$label: ${s.id}',
      );
      expect(s.standRect.width, lessThanOrEqualTo(s.pitch - 3 * s0 + _eps));
      expect(s.pipDiameter, greaterThan(0));
      // Every pip sits on the stand face.
      expect(s.pipCenterX(0), greaterThan(s.standRect.left));
      expect(s.pipCenterX(s.pipCount - 1), lessThan(s.standRect.right));
      expect(s.pipCenterY, lessThan(s.standRect.bottom));
      expect(s.pipCenterY, greaterThan(s.standRect.top));
      expect(s.iceRect.bottom, lessThanOrEqualTo(g.boardArea.bottom + _eps));
    }
  }
  for (var r = 0; r < g.shelves.length; r++) {
    for (final s in g.shelves[r].slots) {
      final top = _contentTop(s, maxSize);
      // The top shelf stays under the HUD; lower shelves stay clear of the
      // stands (and the dolls on them) of the shelf above.
      final limit = r == 0
          ? g.fit.frame.top
          : g.shelves[r - 1].slots.first.standRect.bottom;
      expect(
        top,
        greaterThanOrEqualTo(limit - _eps),
        reason: '$label: ${s.id} reaches $top above $limit',
      );
    }
  }
}

void main() {
  final crowded = <String, BoardShape>{
    '3 shelves 5/5/4, maxSize 5': board(['ooooo', 'toolo', 'oooo'], maxSize: 5),
    '3 shelves 4/4/6 (2 extras), maxSize 6': board([
      'oooo',
      'tool',
      'olooxx',
    ], maxSize: 6),
    '3 shelves 5/5/6, maxSize 4': board([
      'ooooo',
      'ooloo',
      'otooxx',
    ], maxSize: 4),
    '4 shelves 5/5/5/4, maxSize 6': board([
      'ooooo',
      'toloo',
      'ooooo',
      'oolo',
    ], maxSize: 6),
    '4 shelves 4/4/4/6, maxSize 4': board([
      'oooo',
      'tool',
      'oooo',
      'oootxx',
    ], maxSize: 4),
    '4 shelves 2/3/4/5, maxSize 3': board([
      'oo',
      'ool',
      'otoo',
      'ooooo',
    ], maxSize: 3),
    '2 shelves 5/6, maxSize 6': board(['ooloo', 'ootoxx'], maxSize: 6),
    '1 shelf 6, maxSize 6': board(['oloxox'], maxSize: 6),
    // Top-shelf towers: 3 buried silhouettes must stay under the HUD
    // (review RENDER-4).
    '3 shelves, top-row towers, maxSize 5': board([
      'otot',
      'oooo',
      'ooo',
    ], maxSize: 5),
    '3 shelves, top-row tower, maxSize 6': board([
      'oto',
      'ooo',
      'oooo',
    ], maxSize: 6),
    // maxSize 5: on 4 shelves a top-row tower's own maxSize-6 doll already
    // stands 2 dp above the frame (BACKLOG "Design gaps", 4-shelf preset).
    '4 shelves, top-row tower, maxSize 5': board([
      'toooo',
      'oooo',
      'oooo',
      'oooo',
    ], maxSize: 5),
    '1 shelf 2, maxSize 6': board(['ol'], maxSize: 6),
  };

  for (final entry in crowded.entries) {
    for (final screen in screens.entries) {
      test('${entry.key} on ${screen.key}: nothing collides', () {
        final g = BoardLayout.compute(entry.value, screen.value);
        _expectNoCollisions(g, '${entry.key} on ${screen.key}');
        _expectSealedAndFrozenFit(g, '${entry.key} on ${screen.key}');
      });
    }
  }

  test('the designed boards pass the same checks', () {
    for (final shape in [mainBoard, fullBoard, tutorialBoard, bonusBoard]) {
      _expectNoCollisions(
        BoardLayout.compute(shape, BoardViewport.reference),
        '$shape',
      );
    }
  });

  group('stand shrink (render §1)', () {
    test('full size while the pitch is ≥ 93, then pitch − 4', () {
      expect(BoardLayout.standScaleForPitch(96), 1);
      expect(BoardLayout.standScaleForPitch(93), 1);
      expect(BoardLayout.standScaleForPitch(74.4), closeTo(70.4 / 90, exact));
      expect(BoardLayout.standScaleForPitch(62), closeTo(58 / 90, exact));
      expect(
        [for (var n = 1; n <= 6; n++) BoardLayout.rowPitch(n)],
        [96, 96, 96, 93, 74.4, 62],
      );
    });

    test('6 slots: stands 58 wide, pieces scaled with them', () {
      final g = BoardLayout.compute(
        board(['oooo', 'oooo', 'ootoxx'], maxSize: 4),
        BoardViewport.reference,
      );
      const k = 58 / 90;
      final tower = g.slot('r2c2');
      expect(tower.pieceScale, closeTo(k, exact));
      expect(tower.standRect.width, closeTo(58, exact));
      expect(tower.standRect.height, closeTo(39 * k, exact));
      expect(tower.pipCenterY, closeTo(tower.standTop + 31.9 * k, exact));
      expect(tower.pipPitch, closeTo(7.8 * k, exact));
      expect(tower.buriedBaseY(1), closeTo(tower.surfaceY - 18 * k, exact));
      expect(tower.iceRect.width, closeTo(96 * k, exact));
      expect(tower.glowRingRect.width, closeTo(116 * k, exact));
      expect(tower.hintArrowRect(4).width, closeTo(40 * k, exact));
      // Dolls: one scale for the board, from the narrowest shelf. Its
      // pieces shrink by k, below the width limit (62 − 8/3) / 78, and the
      // dolls follow them (review RENDER-3).
      expect(g.dollHeightScale, closeTo(k, exact));
      expect(g.slot('r0c0').dollWidth(4), closeTo(78 * k, exact));
      expect(k, lessThan((62 - 8 / 3) / 78));
      expect(g.slot('r0c0').pieceScale, 1);
    });
  });

  group('undesigned presets (D22, TODO(design))', () {
    test('1 shelf: plank 540, Hs 150', () {
      final g = BoardLayout.compute(
        board(['oooo'], maxSize: 4),
        BoardViewport.reference,
      );
      expect(g.preset.designed, isFalse);
      expect(g.shelves.single.plankTop, 540);
      expect(g.maxDollHeight, closeTo(117, exact));
    });

    test('4 shelves: planks 250/395/539/684, Hs 104, pieces × 104/150', () {
      final g = BoardLayout.compute(
        board(['oooo', 'oooo', 'oooo', 'oooo'], maxSize: 6),
        BoardViewport.reference,
      );
      expect(g.preset.designed, isFalse);
      expect([for (final s in g.shelves) s.plankTop], [250, 395, 539, 684]);
      expect(g.maxDollHeight, closeTo(104, exact));
      expect(g.dollHeightScale, 1);
      const q = 104 / 150;
      final s = g.slot('r1c0');
      expect(s.pieceScale, closeTo(q, exact));
      expect(s.standRect.width, closeTo(90 * q, exact));
      expect(s.glassCaseRect.height, closeTo(143 * q, exact));
      expect(s.standRect.bottom, closeTo(404, exact));
    });
  });
}
