package com.futrix.nesty.widget

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

/** The widget's sizing decisions (design spec §2.5, gap 4, 11–16). */
class WidgetFitTest {
    @Test
    fun theLayoutSwitchesAt250Dp() {
        assertFalse(WidgetFit.isMedium(110f))
        assertFalse(WidgetFit.isMedium(249.9f))
        assertTrue(WidgetFit.isMedium(250f))
        assertTrue(WidgetFit.isMedium(348f))
    }

    @Test
    fun smallDollsFitTheContentWidthUpToSix() {
        // Frame 14.4's 164 dp: 132 of content holds six 15 dp dolls with 4 gaps.
        assertEquals(6, WidgetFit.smallDollCount(132f, 8))
        assertEquals(2, WidgetFit.smallDollCount(132f, 2))
        // 110 dp wide: 78 of content holds four.
        assertEquals(4, WidgetFit.smallDollCount(78f, 8))
        assertEquals(0, WidgetFit.smallDollCount(10f, 8))
        assertEquals(0, WidgetFit.smallDollCount(132f, 0))
    }

    @Test
    fun mediumDollsFollowTheRightColumn() {
        // 348 dp (frame 14.4): 348 − 32 − 104 − 29.5 = 182.5 → floor(187.5 / 24) = 7.
        val right = WidgetFit.mediumRightWidth(348f, WidgetFit.PADDING_DP)
        assertEquals(182.5f, right, 0.001f)
        assertEquals(7, WidgetFit.mediumDollCount(right, 11))
        // 250 dp: an 84.5 dp column holds 3 (gap 13).
        assertEquals(3, WidgetFit.mediumDollCount(WidgetFit.mediumRightWidth(250f, WidgetFit.PADDING_DP), 11))
        // Wide: capped at 8, and never more than the puzzle has.
        assertEquals(8, WidgetFit.mediumDollCount(WidgetFit.mediumRightWidth(600f, WidgetFit.PADDING_DP), 11))
        assertEquals(5, WidgetFit.mediumDollCount(WidgetFit.mediumRightWidth(600f, WidgetFit.PADDING_DP), 5))
        // The locked column is 64.
        assertEquals(
            222.5f,
            WidgetFit.mediumRightWidth(348f, WidgetFit.PADDING_DP, WidgetFit.MEDIUM_LOCKED_LEFT_DP),
            0.001f,
        )
        assertEquals(0f, WidgetFit.mediumRightWidth(100f, WidgetFit.PADDING_DP), 0f)
    }

    @Test
    fun theNumberShrinksButNeverBelowFourFifths() {
        assertEquals(1f, WidgetFit.numberScale(40f, 91f), 0f)
        assertEquals(0.9f, WidgetFit.numberScale(100f, 90f), 0.0001f)
        assertEquals(0.8f, WidgetFit.numberScale(200f, 90f), 0f)
        assertEquals(1f, WidgetFit.numberScale(0f, 0f), 0f)
    }

    @Test
    fun theShortFormOnlyWhenTheFullOneDoesNotFit() {
        assertEquals("day streak · resting", WidgetFit.pick("day streak · resting", "resting", fullFits = true))
        assertEquals("resting", WidgetFit.pick("day streak · resting", "resting", fullFits = false))
        // No short form (ready's label, the locked lines): the full one, ellipsized.
        assertEquals("day streak", WidgetFit.pick("day streak", null, fullFits = false))
        assertEquals("day streak", WidgetFit.pick("day streak", "", fullFits = false))
    }

    @Test
    fun theHeightTiersPickTheFirstThatFits() {
        val options = listOf(
            WidgetFit.Option(16f, 122f), // full
            WidgetFit.Option(16f, 90f), // no dolls
            WidgetFit.Option(12f, 74f), // compact
        )
        assertEquals(0, WidgetFit.firstFit(164f, options))
        assertEquals(0, WidgetFit.firstFit(154f, options))
        assertEquals(1, WidgetFit.firstFit(153f, options))
        assertEquals(1, WidgetFit.firstFit(122f, options))
        assertEquals(2, WidgetFit.firstFit(121f, options))
        assertEquals(2, WidgetFit.firstFit(110f, options))
        // Nothing fits: the most compact.
        assertEquals(2, WidgetFit.firstFit(40f, options))
        // Half a dp of rounding is forgiven.
        assertEquals(0, WidgetFit.firstFit(153.6f, options))
    }
}
