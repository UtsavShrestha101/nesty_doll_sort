package com.futrix.nesty.widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.os.Bundle
import android.util.Log

/**
 * The home-screen widget (local habits stage 4; plan-local-habits §4
 * "Android"): one provider for every flavor (the applicationId suffix keeps
 * the three installs apart), declared in the main manifest with
 * `res/xml/nesty_widget_info.xml`.
 *
 * It is static: no timer, no countdown, one tap target (the respect rules,
 * D92). Each render looks today up in the stored snapshot, so a late
 * midnight alarm still draws the right day.
 */
class NestyWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        safely("update") {
            NestyWidgetRenderer.render(context, appWidgetManager, appWidgetIds)
            MidnightAlarm.schedule(context)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle?,
    ) {
        // A resize: the layout, the tiers and the fit depend on the size.
        safely("resize") { NestyWidgetRenderer.render(context, appWidgetManager, intArrayOf(appWidgetId)) }
    }

    override fun onEnabled(context: Context) {
        safely("enable") { MidnightAlarm.schedule(context) }
    }

    override fun onDisabled(context: Context) {
        safely("disable") { MidnightAlarm.cancel(context) }
    }

    companion object {
        private const val TAG = "NestyWidget"

        /** Every placed widget's id; empty when none is (or no widget support). */
        fun widgetIds(context: Context): IntArray {
            val manager = AppWidgetManager.getInstance(context) ?: return IntArray(0)
            return manager.getAppWidgetIds(ComponentName(context, NestyWidgetProvider::class.java))
                ?: IntArray(0)
        }

        /**
         * Redraws every placed widget and keeps the midnight alarm set; with
         * no widget placed, the alarm is cancelled instead. The channel's
         * `publish` and every clock broadcast end here.
         */
        fun refreshAll(context: Context) {
            safely("refresh") {
                val manager = AppWidgetManager.getInstance(context) ?: return@safely
                val ids = manager.getAppWidgetIds(ComponentName(context, NestyWidgetProvider::class.java))
                if (ids == null || ids.isEmpty()) {
                    MidnightAlarm.cancel(context)
                    return@safely
                }
                NestyWidgetRenderer.render(context, manager, ids)
                MidnightAlarm.schedule(context)
            }
        }

        // Rule 3: a widget never crashes the app's process.
        private inline fun safely(what: String, block: () -> Unit) {
            try {
                block()
            } catch (e: Exception) {
                Log.w(TAG, "widget $what failed", e)
            }
        }
    }
}
