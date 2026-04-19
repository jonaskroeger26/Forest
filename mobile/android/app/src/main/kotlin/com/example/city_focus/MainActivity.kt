package com.example.city_focus

import android.app.AppOpsManager
import android.content.Context
import android.os.Binder
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val methodChannelName = "city_focus/blocked_apps"
    private val eventChannelName = "city_focus/blocked_apps_events"
    private var monitor: BlockedAppMonitor? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, methodChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startMonitoring" -> {
                        val args = call.arguments as? Map<*, *>
                        val packages = (args?.get("packages") as? List<*>)?.filterIsInstance<String>() ?: emptyList()
                        monitor?.start(packages)
                        result.success(null)
                    }
                    "stopMonitoring" -> {
                        monitor?.stop()
                        result.success(null)
                    }
                    "hasUsageAccess" -> result.success(hasUsageStatsPermission())
                    else -> result.notImplemented()
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, eventChannelName)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    monitor = BlockedAppMonitor(applicationContext, events)
                }

                override fun onCancel(arguments: Any?) {
                    monitor?.stop()
                    monitor = null
                }
            })
    }

    private fun hasUsageStatsPermission(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) return false
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            "android:get_usage_stats",
            Binder.getCallingUid(),
            packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }
}
