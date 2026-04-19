package com.example.city_focus

import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

class BlockedAppMonitor(
    private val context: Context,
    private val events: EventChannel.EventSink?
) {
    private val handler = Handler(Looper.getMainLooper())
    private var blockedPackages: Set<String> = emptySet()
    private var active = false
    private var lastEventTime = System.currentTimeMillis()

    fun start(packages: List<String>) {
        blockedPackages = packages.toSet()
        if (active) return
        active = true
        poll()
    }

    fun stop() {
        active = false
        handler.removeCallbacksAndMessages(null)
    }

    private fun poll() {
        if (!active) return

        val now = System.currentTimeMillis()
        val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val usageEvents: UsageEvents = usageStatsManager.queryEvents(lastEventTime, now)
        val event = UsageEvents.Event()

        while (usageEvents.hasNextEvent()) {
            usageEvents.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND &&
                blockedPackages.contains(event.packageName)
            ) {
                events?.success("blocked_app_opened")
                stop()
                return
            }
        }

        lastEventTime = now
        handler.postDelayed({ poll() }, 1200)
    }
}
