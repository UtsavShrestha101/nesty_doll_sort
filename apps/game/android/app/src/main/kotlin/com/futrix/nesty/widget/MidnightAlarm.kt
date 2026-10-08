package com.futrix.nesty.widget

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import java.time.ZoneId

/**
 * The widget's day rollover (plan-local-habits §4 "Midnight"): one inexact
 * `AlarmManager.set(RTC, next local midnight + 5 s)`. RTC (not RTC_WAKEUP)
 * waits for the phone to wake, and no exact-alarm permission is asked (the
 * manifest removes both). It is set in `onEnabled`, `onUpdate`, after every
 * publish, by the alarm itself and on the clock broadcasts
 * ([NestyWidgetClockReceiver]); `onDisabled` cancels it. A late alarm still
 * draws the right day, because the render looks today up when it runs.
 */
object MidnightAlarm {
    const val ACTION_MIDNIGHT = "com.futrix.nesty.widget.action.MIDNIGHT"

    fun schedule(context: Context) {
        val alarms = context.getSystemService(AlarmManager::class.java) ?: return
        val at = WidgetTimeline.alarmAtMillis(System.currentTimeMillis(), ZoneId.systemDefault())
        // The same PendingIntent replaces any earlier alarm: there is only ever one.
        alarms.set(AlarmManager.RTC, at, pendingIntent(context))
    }

    fun cancel(context: Context) {
        val alarms = context.getSystemService(AlarmManager::class.java) ?: return
        alarms.cancel(pendingIntent(context))
    }

    private fun pendingIntent(context: Context): PendingIntent {
        val intent = Intent(context, NestyWidgetClockReceiver::class.java).setAction(ACTION_MIDNIGHT)
        return PendingIntent.getBroadcast(
            context,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }
}
