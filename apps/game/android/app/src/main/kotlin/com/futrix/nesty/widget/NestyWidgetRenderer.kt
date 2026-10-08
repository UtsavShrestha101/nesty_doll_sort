package com.futrix.nesty.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.util.SizeF
import android.util.TypedValue
import android.view.View
import android.widget.RemoteViews
import com.futrix.nesty.MainActivity
import com.futrix.nesty.R
import com.futrix.nesty.widget.WidgetTextMeasure.Face
import java.time.ZoneId
import kotlin.math.max

/**
 * Builds the widget's RemoteViews (design spec §2.5, §2.6, §5; the lead's
 * rulings). Two layouts: `nesty_widget_small` under 250 dp wide and
 * `nesty_widget_medium` from 250 dp. On API 31+ one RemoteViews per size the
 * launcher reports (`OPTION_APPWIDGET_SIZES`), each fitted to its size; before
 * 31, the portrait and landscape pair from the min/max options.
 *
 * A launcher may reapply a new RemoteViews onto the views it already shows,
 * so every render sets every view it can change (visibility, text, size,
 * padding, tint, description), never only what differs from the default.
 */
internal object NestyWidgetRenderer {
    private const val TAG = "NestyWidget"

    /** Frame 14.4's 2 × 2 (164 × 164), when the launcher gave no size yet. */
    private const val DEFAULT_SIZE_DP = 164f

    /** `RemoteViews(Map)` takes at most 16 sizes. */
    private const val MAX_SIZES = 16

    /** A URL scheme as RFC 3986 spells it; anything else falls back to the resource. */
    private val SCHEME = Regex("^[a-z][a-z0-9+.-]*$")

    fun render(context: Context, manager: AppWidgetManager, ids: IntArray) {
        if (ids.isEmpty()) return
        val snapshot = WidgetTimeline.decode(NestyWidgetStore.read(context))
        val today = WidgetTimeline.today(System.currentTimeMillis(), ZoneId.systemDefault())
        val content = WidgetTimeline.content(snapshot, today)
        val scheme = snapshot?.scheme?.takeIf { SCHEME.matches(it) }
            ?: context.getString(R.string.app_url_scheme)
        val draw = Draw(context, content, tapIntent(context, scheme))
        for (id in ids) {
            try {
                manager.updateAppWidget(id, draw.forOptions(manager.getAppWidgetOptions(id)))
            } catch (e: RuntimeException) {
                Log.w(TAG, "drawing widget $id failed", e)
            }
        }
    }

    /**
     * The one tap target (§5): `MainActivity` with `<scheme>://daily`. The
     * engine's deep linking hands the URL to the router, cold (the initial
     * route) or warm (`onNewIntent` on the singleTop activity).
     */
    private fun tapIntent(context: Context, scheme: String): PendingIntent {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("$scheme://daily"), context, MainActivity::class.java)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        return PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }

    private class Draw(
        private val context: Context,
        private val content: WidgetContent,
        private val tap: PendingIntent,
    ) {
        private val measure = WidgetTextMeasure(context)
        private val density = context.resources.displayMetrics.density

        fun forOptions(options: Bundle?): RemoteViews {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val sizes = exactSizes(options)
                if (sizes.isNotEmpty()) {
                    return RemoteViews(sizes.associateWith { at(it.width, it.height) })
                }
            }
            val minW = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH) ?: 0
            val minH = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT) ?: 0
            val maxW = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_WIDTH) ?: 0
            val maxH = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT) ?: 0
            if (minW <= 0 || minH <= 0 || maxW <= 0 || maxH <= 0) {
                return at(DEFAULT_SIZE_DP, DEFAULT_SIZE_DP)
            }
            // Before API 31 the launcher reports a range: portrait shows the
            // min width at the max height, landscape the max width at the min
            // height (AppWidgetManager's option docs).
            val portrait = at(minW.toFloat(), maxH.toFloat())
            val landscape = at(maxW.toFloat(), minH.toFloat())
            return RemoteViews(landscape, portrait)
        }

        @Suppress("DEPRECATION") // The typed getter is API 33+ and buggy there.
        private fun exactSizes(options: Bundle?): List<SizeF> {
            val sizes = options?.getParcelableArrayList<SizeF>(AppWidgetManager.OPTION_APPWIDGET_SIZES)
                ?: return emptyList()
            return sizes.filter { it.width > 0f && it.height > 0f }.distinct().take(MAX_SIZES)
        }

        /** The views for a widget [w] × [h] dp. */
        fun at(w: Float, h: Float): RemoteViews {
            val medium = WidgetFit.isMedium(w)
            val views = when (val c = content) {
                WidgetContent.FirstRun -> {
                    // TODO(design): the first-run state isn't drawn (design spec
                    // gap 3); the default is the locked look with the gallery's
                    // own strings, read as they are by TalkBack.
                    val title = context.getString(R.string.widget_locked_title)
                    val line = context.getString(R.string.widget_gallery_description)
                    if (medium) mediumLocked(title, line, w, h) else smallLocked(title, line, w, h)
                }
                is WidgetContent.Locked -> {
                    val l = c.locked
                    if (medium) mediumLocked(l.title, l.medium, w, h) else smallLocked(l.title, l.small, w, h)
                }
                is WidgetContent.Day -> if (medium) mediumDay(c.day, w, h) else smallDay(c.day, w, h)
            }
            val description = when (val c = content) {
                WidgetContent.FirstRun -> null
                is WidgetContent.Locked -> c.locked.a11y
                is WidgetContent.Day -> c.day.a11y
            }
            views.setContentDescription(android.R.id.background, description)
            views.setOnClickPendingIntent(android.R.id.background, tap)
            return views
        }

        // ---- 2 × 2 -----------------------------------------------------------

        private fun smallDay(day: WidgetDay, w: Float, h: Float): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.nesty_widget_small)
            // Height tiers (gap 4): full; the dolls dropped; padding 12 with
            // the line's short form on one line.
            val plans = listOf(
                smallDayPlan(day, w, WidgetFit.PADDING_DP, dolls = true, compact = false),
                smallDayPlan(day, w, WidgetFit.PADDING_DP, dolls = false, compact = false),
                smallDayPlan(day, w, WidgetFit.COMPACT_PADDING_DP, dolls = false, compact = true),
            )
            val plan = plans[WidgetFit.firstFit(h, plans.map { it.option })]

            setPadding(views, plan.option.paddingDp)
            views.setViewVisibility(R.id.nesty_widget_streak, View.VISIBLE)
            views.setViewVisibility(R.id.nesty_widget_mark, View.GONE)
            views.setViewVisibility(R.id.nesty_widget_locked, View.GONE)
            setFlame(views, day)
            setNumber(views, day.number, plan.numberSp)
            views.setTextViewText(R.id.nesty_widget_label, plan.label)
            setDolls(views, SMALL_DOLLS, day.dolls, plan.dolls)
            views.setViewVisibility(R.id.nesty_widget_line, View.VISIBLE)
            views.setTextViewText(R.id.nesty_widget_line, plan.line)
            views.setInt(R.id.nesty_widget_line, "setMaxLines", plan.lineMaxLines)
            return views
        }

        private fun smallDayPlan(day: WidgetDay, w: Float, pad: Float, dolls: Boolean, compact: Boolean): DayPlan {
            val width = w - 2 * pad
            val numberSp = day.number?.let { numberSp(it, SMALL_NUMBER_SP, width - SMALL_FLAME_DP - SMALL_NUMBER_GAP_DP) }
                ?: SMALL_NUMBER_SP
            val label = WidgetFit.pick(
                day.label,
                day.labelShort,
                measure.fits(day.label, LABEL_SP, Face.TEXT, width, 1),
            )
            val labelH = measure.heightDp(label, LABEL_SP, Face.TEXT, width, 1)
            val lineMaxLines = if (compact) 1 else 2
            val line = if (compact) {
                day.lineShort?.takeIf { it.isNotEmpty() } ?: day.line
            } else {
                WidgetFit.pick(day.line, day.lineShort, measure.fits(day.line, SMALL_LINE_SP, Face.DISPLAY, width, 2))
            }
            val lineH = measure.heightDp(line, SMALL_LINE_SP, Face.DISPLAY, width, lineMaxLines)
            val dollCount = if (dolls) WidgetFit.smallDollCount(width, day.dolls.size) else 0
            val dollsH = if (dollCount > 0) SMALL_DOLLS_TOP_DP + SMALL_DOLL_HEIGHT_DP else 0f
            val need = SMALL_ROW_DP + SMALL_LABEL_TOP_DP + labelH + dollsH + lineH
            return DayPlan(WidgetFit.Option(pad, need), numberSp, label, dollCount, line, lineMaxLines)
        }

        private fun smallLocked(title: String, line: String, w: Float, h: Float): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.nesty_widget_small)
            val titleH = measure.heightDp(title, LOCKED_TITLE_SP, Face.DISPLAY, w - 2 * WidgetFit.PADDING_DP, 1)
            fun lineH(pad: Float, lines: Int) =
                measure.heightDp(line, SMALL_LOCKED_LINE_SP, Face.TEXT, w - 2 * pad, lines)
            val text = titleH + SMALL_LOCKED_LINE_TOP_DP
            // The same tiers for the locked look: full; padding 12 with the
            // line on one line; then without the mark.
            // TODO(design): gap 4 only tiers the streak look; the locked
            // look's tiers here are the default.
            val options = listOf(
                WidgetFit.Option(WidgetFit.PADDING_DP, SMALL_MARK_DP + text + lineH(WidgetFit.PADDING_DP, 2)),
                WidgetFit.Option(WidgetFit.COMPACT_PADDING_DP, SMALL_MARK_DP + text + lineH(WidgetFit.COMPACT_PADDING_DP, 1)),
                WidgetFit.Option(WidgetFit.COMPACT_PADDING_DP, text + lineH(WidgetFit.COMPACT_PADDING_DP, 1)),
            )
            val tier = WidgetFit.firstFit(h, options)

            setPadding(views, options[tier].paddingDp)
            views.setViewVisibility(R.id.nesty_widget_streak, View.GONE)
            views.setViewVisibility(R.id.nesty_widget_line, View.GONE)
            views.setViewVisibility(R.id.nesty_widget_mark, if (tier < 2) View.VISIBLE else View.GONE)
            views.setViewVisibility(R.id.nesty_widget_locked, View.VISIBLE)
            views.setTextViewText(R.id.nesty_widget_locked_title, title)
            views.setTextViewText(R.id.nesty_widget_locked_line, line)
            views.setInt(R.id.nesty_widget_locked_line, "setMaxLines", if (tier == 0) 2 else 1)
            return views
        }

        // ---- 4 × 2 -----------------------------------------------------------

        private fun mediumDay(day: WidgetDay, w: Float, h: Float): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.nesty_widget_medium)
            // The two columns tier on their own (the left wraps its label, the
            // right drops its dolls); padding 12 when either needs it.
            // TODO(design): gap 4 tiers the 2 × 2 only; the 4 × 2's tiers here
            // follow it by default.
            val left = listOf(
                mediumLeftPlan(day, WidgetFit.PADDING_DP, labelLines = 2),
                mediumLeftPlan(day, WidgetFit.PADDING_DP, labelLines = 1),
                mediumLeftPlan(day, WidgetFit.COMPACT_PADDING_DP, labelLines = 1),
            )
            val right = listOf(
                mediumRightPlan(day, w, WidgetFit.PADDING_DP, dolls = true, compact = false),
                mediumRightPlan(day, w, WidgetFit.PADDING_DP, dolls = false, compact = false),
                mediumRightPlan(day, w, WidgetFit.COMPACT_PADDING_DP, dolls = false, compact = true),
            )
            var leftTier = WidgetFit.firstFit(h, left.map { it.option })
            var rightTier = WidgetFit.firstFit(h, right.map { it.option })
            if (leftTier == 2 || rightTier == 2) {
                leftTier = 2
                rightTier = 2
            }
            val l = left[leftTier]
            val r = right[rightTier]

            setPadding(views, l.option.paddingDp)
            views.setViewVisibility(R.id.nesty_widget_left, View.VISIBLE)
            views.setViewVisibility(R.id.nesty_widget_left_locked, View.GONE)
            setFlame(views, day)
            setNumber(views, day.number, l.numberSp)
            views.setTextViewText(R.id.nesty_widget_label, l.label)
            views.setInt(R.id.nesty_widget_label, "setMaxLines", l.labelMaxLines)
            views.setTextViewText(R.id.nesty_widget_title, day.title)
            if (day.sub.isNullOrEmpty()) {
                views.setViewVisibility(R.id.nesty_widget_sub, View.GONE)
            } else {
                views.setViewVisibility(R.id.nesty_widget_sub, View.VISIBLE)
                views.setTextViewText(R.id.nesty_widget_sub, day.sub)
            }
            setDolls(views, MEDIUM_DOLLS, day.dolls, r.dolls)
            views.setTextViewText(R.id.nesty_widget_line, r.line)
            views.setInt(R.id.nesty_widget_line, "setMaxLines", r.lineMaxLines)
            return views
        }

        private fun mediumLeftPlan(day: WidgetDay, pad: Float, labelLines: Int): LeftPlan {
            val width = WidgetFit.MEDIUM_LEFT_DP
            val numberSp = day.number?.let { numberSp(it, MEDIUM_NUMBER_SP, width) } ?: MEDIUM_NUMBER_SP
            // Medium label (gap 11): up to two lines, then the short form,
            // then the ellipsis.
            val label = WidgetFit.pick(
                day.label,
                day.labelShort,
                measure.fits(day.label, LABEL_SP, Face.TEXT, width, labelLines),
            )
            val labelH = measure.heightDp(label, LABEL_SP, Face.TEXT, width, labelLines)
            val numberH = if (day.number == null) {
                0f
            } else {
                measure.heightDp(day.number, numberSp, Face.DISPLAY, width, 1) + MEDIUM_LABEL_TOP_DP
            }
            val need = MEDIUM_FLAME_DP + numberH + labelH
            return LeftPlan(WidgetFit.Option(pad, need), numberSp, label, labelLines)
        }

        private fun mediumRightPlan(day: WidgetDay, w: Float, pad: Float, dolls: Boolean, compact: Boolean): DayPlan {
            val width = WidgetFit.mediumRightWidth(w, pad)
            val titleH = measure.heightDp(day.title, MEDIUM_TITLE_SP, Face.DISPLAY, width, 1)
            val subH = day.sub?.takeIf { it.isNotEmpty() }
                ?.let { MEDIUM_SUB_TOP_DP + measure.heightDp(it, MEDIUM_SUB_SP, Face.TEXT, width, 1) }
                ?: 0f
            val lineMaxLines = if (compact) 1 else 2
            val line = if (compact) {
                day.lineShort?.takeIf { it.isNotEmpty() } ?: day.line
            } else {
                WidgetFit.pick(day.line, day.lineShort, measure.fits(day.line, MEDIUM_LINE_SP, Face.DISPLAY, width, 2))
            }
            val lineH = measure.heightDp(line, MEDIUM_LINE_SP, Face.DISPLAY, width, lineMaxLines)
            val dollCount = if (dolls) WidgetFit.mediumDollCount(width, day.dolls.size) else 0
            val dollsH = if (dollCount > 0) MEDIUM_DOLLS_TOP_DP + MEDIUM_DOLL_HEIGHT_DP else 0f
            val need = titleH + subH + dollsH + lineH
            return DayPlan(WidgetFit.Option(pad, need), 0f, "", dollCount, line, lineMaxLines)
        }

        private fun mediumLocked(title: String, line: String, w: Float, h: Float): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.nesty_widget_medium)
            fun need(pad: Float, lines: Int): Float {
                val width = WidgetFit.mediumRightWidth(w, pad, WidgetFit.MEDIUM_LOCKED_LEFT_DP)
                val text = measure.heightDp(title, MEDIUM_TITLE_SP, Face.DISPLAY, width, 1) +
                    measure.heightDp(line, MEDIUM_LINE_SP, Face.DISPLAY, width, lines)
                return max(MEDIUM_MARK_DP, text)
            }
            val options = listOf(
                WidgetFit.Option(WidgetFit.PADDING_DP, need(WidgetFit.PADDING_DP, 2)),
                WidgetFit.Option(WidgetFit.COMPACT_PADDING_DP, need(WidgetFit.COMPACT_PADDING_DP, 1)),
            )
            val tier = WidgetFit.firstFit(h, options)

            setPadding(views, options[tier].paddingDp)
            views.setViewVisibility(R.id.nesty_widget_left, View.GONE)
            views.setViewVisibility(R.id.nesty_widget_left_locked, View.VISIBLE)
            views.setTextViewText(R.id.nesty_widget_title, title)
            views.setViewVisibility(R.id.nesty_widget_sub, View.GONE)
            setDolls(views, MEDIUM_DOLLS, emptyList(), 0)
            views.setTextViewText(R.id.nesty_widget_line, line)
            views.setInt(R.id.nesty_widget_line, "setMaxLines", if (tier == 0) 2 else 1)
            return views
        }

        // ---- shared ----------------------------------------------------------

        private fun setPadding(views: RemoteViews, dp: Float) {
            val px = (dp * density + 0.5f).toInt()
            views.setViewPadding(android.R.id.background, px, px, px, px)
        }

        /** Lit only when today's daily is solved; `-night` swaps the unlit art. */
        private fun setFlame(views: RemoteViews, day: WidgetDay) {
            val flame = if (day.state == DayState.SOLVED) {
                R.drawable.nesty_widget_flame_lit
            } else {
                R.drawable.nesty_widget_flame_unlit
            }
            views.setImageViewResource(R.id.nesty_widget_flame, flame)
        }

        /** Zero has no number (the flame alone); otherwise pre-formatted text. */
        private fun setNumber(views: RemoteViews, number: String?, sp: Float) {
            if (number == null) {
                views.setViewVisibility(R.id.nesty_widget_number, View.GONE)
                return
            }
            views.setViewVisibility(R.id.nesty_widget_number, View.VISIBLE)
            views.setTextViewText(R.id.nesty_widget_number, number)
            views.setTextViewTextSize(R.id.nesty_widget_number, TypedValue.COMPLEX_UNIT_SP, sp)
        }

        /** The number's size, shrunk to fit but never below 0.8 (`textFit.widget.number`). */
        private fun numberSp(number: String, baseSp: Float, availableDp: Float): Float {
            val width = measure.widthDp(number, baseSp, Face.DISPLAY, tabular = true)
            return baseSp * WidgetFit.numberScale(width, availableDp)
        }

        /** The first [count] dolls, each a black template tinted its family's base colour. */
        private fun setDolls(views: RemoteViews, ids: IntArray, colors: List<Int>, count: Int) {
            views.setViewVisibility(R.id.nesty_widget_dolls, if (count > 0) View.VISIBLE else View.GONE)
            for ((index, id) in ids.withIndex()) {
                if (index < count) {
                    views.setViewVisibility(id, View.VISIBLE)
                    views.setInt(id, "setColorFilter", colors[index])
                } else {
                    views.setViewVisibility(id, View.GONE)
                }
            }
        }
    }

    /** One size's choice for the streak look (the 2 × 2, or the 4 × 2's right column). */
    private data class DayPlan(
        val option: WidgetFit.Option,
        val numberSp: Float,
        val label: String,
        val dolls: Int,
        val line: String,
        val lineMaxLines: Int,
    )

    /** The 4 × 2's left column: the number's size and the label. */
    private data class LeftPlan(
        val option: WidgetFit.Option,
        val numberSp: Float,
        val label: String,
        val labelMaxLines: Int,
    )

    private val SMALL_DOLLS = intArrayOf(
        R.id.nesty_widget_doll_0,
        R.id.nesty_widget_doll_1,
        R.id.nesty_widget_doll_2,
        R.id.nesty_widget_doll_3,
        R.id.nesty_widget_doll_4,
        R.id.nesty_widget_doll_5,
    )
    private val MEDIUM_DOLLS = SMALL_DOLLS + intArrayOf(R.id.nesty_widget_doll_6, R.id.nesty_widget_doll_7)

    // Sizes in dp and sp, from tokens `habits.widget.layout` and design spec
    // §2.5 (the layouts carry the same values).
    private const val SMALL_ROW_DP = 40f
    private const val SMALL_FLAME_DP = 36f
    private const val SMALL_NUMBER_GAP_DP = 5f
    private const val SMALL_NUMBER_SP = 36f
    private const val SMALL_LABEL_TOP_DP = 3f
    private const val SMALL_DOLLS_TOP_DP = 12f
    private const val SMALL_DOLL_HEIGHT_DP = 20f
    private const val SMALL_LINE_SP = 14f
    private const val SMALL_MARK_DP = 42f
    private const val SMALL_LOCKED_LINE_TOP_DP = 4f
    private const val SMALL_LOCKED_LINE_SP = 13f
    private const val LABEL_SP = 12f
    private const val LOCKED_TITLE_SP = 17f
    private const val MEDIUM_FLAME_DP = 46f
    private const val MEDIUM_NUMBER_SP = 42f
    private const val MEDIUM_LABEL_TOP_DP = 4f
    private const val MEDIUM_TITLE_SP = 17f
    private const val MEDIUM_SUB_TOP_DP = 3f
    private const val MEDIUM_SUB_SP = 12.5f
    private const val MEDIUM_DOLLS_TOP_DP = 12f
    private const val MEDIUM_DOLL_HEIGHT_DP = 26f
    private const val MEDIUM_LINE_SP = 15f
    private const val MEDIUM_MARK_DP = 56f
}
