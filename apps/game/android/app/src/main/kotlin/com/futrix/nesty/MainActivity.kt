package com.futrix.nesty

import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Log
import com.futrix.nesty.widget.NestyWidgetProvider
import com.futrix.nesty.widget.NestyWidgetStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // "Open phone settings" (frames 10.2d and 10.2f, Q140; phase 4
        // architecture 3.8): the Dart side is ChannelSystemSettingsService.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SYSTEM_SETTINGS_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "openNotificationSettings" -> result.success(openNotificationSettings())
                else -> result.notImplemented()
            }
        }
        // The home-screen widget (local habits stage 4, contract §1): the
        // Dart side is ChannelHomeWidgetService. readBack and storeInfo are
        // for integration_test/home_widget_test.dart, so a release build
        // answers notImplemented (Dart reads null).
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            HOME_WIDGET_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "publish" -> publishWidgetSnapshot(call.arguments as? String, result)
                "readBack" -> if (isDebuggable()) {
                    result.success(NestyWidgetStore.read(applicationContext))
                } else {
                    result.notImplemented()
                }
                "storeInfo" -> if (isDebuggable()) {
                    result.success(
                        mapOf(
                            "prefs" to NestyWidgetStore.PREFS_NAME,
                            "providers" to NestyWidgetProvider.widgetIds(applicationContext).size,
                        ),
                    )
                } else {
                    result.notImplemented()
                }
                else -> result.notImplemented()
            }
        }
    }

    /// API 26+ opens the app's notification page; API 24-25 (minSdk 24) its
    /// app details. False when nothing could open, never a crash.
    private fun openNotificationSettings(): Boolean {
        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
        } else {
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                .setData(Uri.parse("package:$packageName"))
        }
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        return try {
            startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }

    /// Stores the snapshot, then redraws every placed widget (contract §1-2).
    /// Off the main thread: the store commits to disk and the redraw measures
    /// text. True when stored, whatever the redraw does; a phone with no
    /// widget support stores it and answers true too.
    private fun publishWidgetSnapshot(json: String?, result: MethodChannel.Result) {
        if (json == null) {
            result.success(false)
            return
        }
        val context: Context = applicationContext
        NestyWidgetProvider.work.execute {
            var stored = false
            try {
                stored = NestyWidgetStore.write(context, json)
                if (stored) NestyWidgetProvider.refreshAll(context)
            } catch (e: Throwable) {
                // Rule 3: even an Error here must not end the app's process
                // from this thread, and Dart always gets its answer.
                Log.w(TAG, "storing the widget snapshot failed", e)
            } finally {
                val answer = stored
                mainHandler.post { result.success(answer) }
            }
        }
    }

    /// Debug builds only (FLAG_DEBUGGABLE: off in profile and release).
    private fun isDebuggable(): Boolean =
        (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0

    companion object {
        const val SYSTEM_SETTINGS_CHANNEL = "com.futrix.nesty/system_settings"
        const val HOME_WIDGET_CHANNEL = "com.futrix.nesty/home_widget"
        private const val TAG = "NestyWidget"

        private val mainHandler = Handler(Looper.getMainLooper())
    }
}
