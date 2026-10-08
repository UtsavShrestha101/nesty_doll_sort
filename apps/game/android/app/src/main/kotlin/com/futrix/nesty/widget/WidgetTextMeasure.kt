package com.futrix.nesty.widget

import android.content.Context
import android.graphics.Paint
import android.graphics.Typeface
import android.text.Layout
import android.text.StaticLayout
import android.text.TextPaint
import android.text.TextUtils
import android.util.TypedValue
import kotlin.math.max

/**
 * Measures the widget's text the way its RemoteViews will draw it (design spec
 * §2.5 "Fit" and §8: RemoteViews can't auto-size, and API 24–25 has no
 * autosize at all, so the provider measures and picks).
 *
 * The faces match the layouts: [Face.DISPLAY] is `sans-serif-medium` bold
 * (numbers, titles, the line), [Face.TEXT] is `sans-serif` bold (labels and
 * the sub). Sizes are sp through `TypedValue`, so the phone's font scale
 * (non-linear on API 34+) is the one the launcher applies. Every result is in
 * dp, like the AppWidget options.
 */
internal class WidgetTextMeasure(context: Context) {
    enum class Face { DISPLAY, TEXT }

    private val metrics = context.resources.displayMetrics
    private val density = metrics.density
    private val display = Typeface.create("sans-serif-medium", Typeface.BOLD)
    private val text = Typeface.create("sans-serif", Typeface.BOLD)

    private fun paint(sp: Float, face: Face, tabular: Boolean = false) = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
        typeface = if (face == Face.DISPLAY) display else text
        textSize = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, sp, metrics)
        if (tabular) fontFeatureSettings = "tnum"
    }

    /** One line's advance width (the number, which never wraps). */
    fun widthDp(value: String, sp: Float, face: Face, tabular: Boolean = false): Float =
        paint(sp, face, tabular).measureText(value) / density

    /** True when [value] needs at most [maxLines] lines at [widthDp]. */
    fun fits(value: String, sp: Float, face: Face, widthDp: Float, maxLines: Int): Boolean =
        layout(value, sp, face, widthDp, Int.MAX_VALUE).lineCount <= maxLines

    /** The height [value] takes, cut to [maxLines] lines, in dp. */
    fun heightDp(value: String, sp: Float, face: Face, widthDp: Float, maxLines: Int): Float =
        layout(value, sp, face, widthDp, maxLines).height / density

    private fun layout(value: String, sp: Float, face: Face, widthDp: Float, maxLines: Int): StaticLayout {
        val widthPx = max(1, (widthDp * density).toInt())
        val builder = StaticLayout.Builder.obtain(value, 0, value.length, paint(sp, face), widthPx)
            .setBreakStrategy(Layout.BREAK_STRATEGY_BALANCED)
            .setHyphenationFrequency(Layout.HYPHENATION_FREQUENCY_NONE)
            .setIncludePad(false)
        if (maxLines != Int.MAX_VALUE) {
            builder.setMaxLines(maxLines).setEllipsize(TextUtils.TruncateAt.END)
        }
        return builder.build()
    }
}
