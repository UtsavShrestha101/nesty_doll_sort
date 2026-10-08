package com.futrix.nesty.widget

import android.content.Context

/**
 * Where the app leaves the widget's snapshot (local habits stage 4, contract
 * §2): `SharedPreferences("nesty_widget")`, key `snapshot`. MainActivity's
 * `com.futrix.nesty/home_widget` channel writes it; the provider reads it at
 * every render, so a render after midnight with the app closed still finds it.
 */
object NestyWidgetStore {
    const val PREFS_NAME = "nesty_widget"
    const val KEY_SNAPSHOT = "snapshot"

    fun read(context: Context): String? =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).getString(KEY_SNAPSHOT, null)

    /**
     * Stores [json]. `commit` (not `apply`) because the channel answers "true
     * when stored" (contract §1); the channel calls it off the main thread.
     */
    fun write(context: Context, json: String): Boolean =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_SNAPSHOT, json)
            .commit()
}
