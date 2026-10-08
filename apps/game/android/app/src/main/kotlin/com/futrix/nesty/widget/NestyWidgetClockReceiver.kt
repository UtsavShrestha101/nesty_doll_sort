package com.futrix.nesty.widget

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Redraws the widget when the day may have changed (plan-local-habits §4
 * "Midnight"): its own midnight alarm, and the clock broadcasts a manifest
 * receiver may still get from API 26 (each is on the implicit-broadcast
 * exemption list): a reboot (alarms don't survive one), the time or the time
 * zone set by hand, and a new phone language (the first-run strings are native
 * resources). An app update re-arms it too. The boot permission is already
 * declared for the daily reminder.
 */
class NestyWidgetClockReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            MidnightAlarm.ACTION_MIDNIGHT,
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED,
            Intent.ACTION_LOCALE_CHANGED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            -> NestyWidgetProvider.refreshAll(context)
        }
    }
}
