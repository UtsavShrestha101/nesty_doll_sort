package com.futrix.nesty.widget

import kotlin.math.floor
import kotlin.math.max
import kotlin.math.min

/**
 * The widget's sizing decisions, in dp, with no Android types so the JVM tests
 * cover them (design spec §2.5 and gap 4; tokens `habits.widget.android` and
 * `layout`). The renderer measures text with `StaticLayout` and hands the
 * results here.
 */
object WidgetFit {
    /** Tokens `habits.widget.android.layouts`: from 250 dp wide, the 4 × 2 layout. */
    const val MEDIUM_MIN_WIDTH_DP = 250f

    /** Tokens `habits.widget.android.padding`. */
    const val PADDING_DP = 16f

    /** Design spec §2.5 gap 4: the shortest small widget drops to 12. */
    const val COMPACT_PADDING_DP = 12f

    /** Small: dolls 15 wide with a 4 gap, up to 6 (tokens `layout.small.dolls`). */
    const val SMALL_DOLL_WIDTH_DP = 15f
    const val SMALL_DOLL_GAP_DP = 4f
    const val SMALL_DOLL_MAX = 6

    /** Medium: dolls 19 wide with a 5 gap, up to 8 (tokens `layout.medium.right`). */
    const val MEDIUM_DOLL_WIDTH_DP = 19f
    const val MEDIUM_DOLL_GAP_DP = 5f
    const val MEDIUM_DOLL_MAX = 8

    /** Medium columns: left 104 · 14 · 1.5 divider · 14 · right. */
    const val MEDIUM_LEFT_DP = 104f
    const val MEDIUM_LOCKED_LEFT_DP = 64f
    const val MEDIUM_GUTTER_DP = 14f + 1.5f + 14f

    /** Tokens `textFit.widget.number`: never below 0.8 of its size. */
    const val NUMBER_MIN_SCALE = 0.8f

    /** Which layout a width takes. */
    fun isMedium(widthDp: Float): Boolean = widthDp >= MEDIUM_MIN_WIDTH_DP

    /** The medium layout's right column for a widget [widthDp] wide. */
    fun mediumRightWidth(widthDp: Float, paddingDp: Float, leftDp: Float = MEDIUM_LEFT_DP): Float =
        max(0f, widthDp - 2 * paddingDp - leftDp - MEDIUM_GUTTER_DP)

    /** How many of [available] dolls fit a small widget's content width. */
    fun smallDollCount(contentWidthDp: Float, available: Int): Int =
        dollCount(contentWidthDp, available, SMALL_DOLL_WIDTH_DP, SMALL_DOLL_GAP_DP, SMALL_DOLL_MAX)

    /**
     * How many of [available] dolls fit the medium's right column (design spec
     * §2.5: `min(8, floor((rightWidth + 5) / 24))`). The first N in puzzle
     * order, no "+N" (gap 15).
     */
    fun mediumDollCount(rightWidthDp: Float, available: Int): Int =
        dollCount(rightWidthDp, available, MEDIUM_DOLL_WIDTH_DP, MEDIUM_DOLL_GAP_DP, MEDIUM_DOLL_MAX)

    private fun dollCount(width: Float, available: Int, doll: Float, gap: Float, cap: Int): Int {
        val fit = floor((width + gap) / (doll + gap)).toInt()
        return max(0, min(min(cap, available), fit))
    }

    /**
     * The number's size factor: 1 when it fits, else shrunk to fit but never
     * below [NUMBER_MIN_SCALE] (then the view ellipsizes).
     */
    fun numberScale(textWidth: Float, availableWidth: Float): Float = when {
        textWidth <= availableWidth || textWidth <= 0f -> 1f
        else -> max(NUMBER_MIN_SCALE, availableWidth / textWidth)
    }

    /**
     * The fit order of `textFit.widget` and copy.md's short forms: the full
     * text when it fits, else the short form when there is one, else the full
     * text (the view ellipsizes it).
     */
    fun pick(full: String, short: String?, fullFits: Boolean): String =
        if (fullFits || short.isNullOrEmpty()) full else short

    /** One way to lay a size out: its padding and the content height it needs. */
    data class Option(val paddingDp: Float, val needDp: Float)

    /**
     * The height tiers (design spec §2.5, gap 4): the index of the first
     * option whose content fits [heightDp] inside its padding; the last option
     * when none does. Options go from the full look to the most compact.
     */
    fun firstFit(heightDp: Float, options: List<Option>): Int {
        require(options.isNotEmpty())
        val index = options.indexOfFirst { it.needDp <= heightDp - 2 * it.paddingDp + FIT_TOLERANCE_DP }
        return if (index < 0) options.lastIndex else index
    }

    /** Rounding between the launcher's whole dp and measured text. */
    private const val FIT_TOLERANCE_DP = 0.5f
}
