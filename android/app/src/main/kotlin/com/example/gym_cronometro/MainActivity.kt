package com.ambrosioking.gymtimer

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.drawable.Icon
import android.net.Uri
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    private var timerChannel: MethodChannel? = null

    /** "Next set" tapped on the timer notification: Dart restarts the rest. */
    private val nextSetReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            timerChannel?.invokeMethod("nextSet", null)
        }
    }

    override fun onDestroy() {
        unregisterReceiver(nextSetReceiver)
        timerChannel = null
        super.onDestroy()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        registerReceiver(
            nextSetReceiver,
            IntentFilter(nextSetAction()),
            Context.RECEIVER_NOT_EXPORTED,
        )

        // Battery optimization exemption: without it HyperOS/MIUI freezes the
        // process ~90 s after it leaves the screen, foreground service or not.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "gym_timer/battery")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isIgnoringBatteryOptimizations" -> {
                        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                        result.success(pm.isIgnoringBatteryOptimizations(packageName))
                    }
                    "requestIgnoreBatteryOptimizations" -> {
                        try {
                            startActivity(
                                Intent(
                                    Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                                    Uri.parse("package:$packageName"),
                                ),
                            )
                            result.success(true)
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        timerChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "gym_timer/timer_notification")
        timerChannel?.setMethodCallHandler { call, result ->
                when (call.method) {
                    "show" -> {
                        val systemDrawn = showTimerNotification(
                            id = call.argument<Int>("id")!!,
                            channelId = call.argument<String>("channelId")!!,
                            title = call.argument<String>("title")!!,
                            body = call.argument<String>("body")!!,
                            label = call.argument<String>("label")!!,
                            actionLabel = call.argument<String>("actionLabel")!!,
                            endMs = call.argument<Number>("endMs")!!.toLong(),
                            totalMs = call.argument<Number>("totalMs")!!.toLong(),
                        )
                        result.success(systemDrawn)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /** HyperOS/MIUI with focus notifications: the system draws the countdown. */
    private fun supportsFocusNotification(): Boolean =
        try {
            Settings.System.getInt(contentResolver, "notification_focus_protocol", 0) > 0
        } catch (e: Exception) {
            false
        }

    /**
     * Ongoing rest notification. On HyperOS it carries the "focus notification"
     * payload of the system clock timer, so the system itself draws the big
     * countdown (lock screen, shade, island). Elsewhere the extras are ignored
     * and the plain title/body show.
     *
     * Returns whether the system draws the countdown by itself; in that case the
     * caller must not repost every second, since each update rebuilds the card
     * (and swallows taps on its button).
     */
    private fun showTimerNotification(
        id: Int,
        channelId: String,
        title: String,
        body: String,
        label: String,
        actionLabel: String,
        endMs: Long,
        totalMs: Long,
    ): Boolean {
        val systemDrawn = supportsFocusNotification()
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (manager.getNotificationChannel(channelId) == null) {
            val channel = NotificationChannel(channelId, "Timer", NotificationManager.IMPORTANCE_DEFAULT)
            channel.description = "Shows rest timer countdown"
            channel.setSound(null, null)
            channel.enableVibration(false)
            manager.createNotificationChannel(channel)
        }

        val launch = packageManager.getLaunchIntentForPackage(packageName)
        val contentIntent = PendingIntent.getActivity(
            this, 0, launch, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val nextSetIntent = PendingIntent.getBroadcast(
            this,
            0,
            Intent(nextSetAction()).setPackage(packageName),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val nextSet = Notification.Action.Builder(
            Icon.createWithResource(this, R.drawable.ic_stat_next_set),
            actionLabel,
            nextSetIntent,
        ).build()

        val remainingPercent =
            if (totalMs <= 0) 0
            else ((endMs - System.currentTimeMillis()) * 100 / totalMs).coerceIn(0, 100).toInt()

        val timerInfo = JSONObject()
            .put("timerType", -1)
            .put("timerWhen", endMs)
            .put("timerSystemCurrent", endMs - totalMs)
            .put("timerTotal", totalMs)
        val focusV2 = JSONObject()
            .put("protocol", 1)
            .put("updatable", true)
            .put("enableFloat", false)
            .put("aodTitle", label)
            .put("aodPic", FOCUS_PIC)
            .put("business", "countdown")
            .put(
                "highlightInfo",
                JSONObject()
                    .put("timerInfo", timerInfo)
                    .put("subContent", body)
                    .put("colorSubContent", "#B28600")
                    .put("colorSubContentDark", "#FFC107")
                    .put("picFunction", FOCUS_PIC),
            )
            .put(
                "actions",
                JSONArray().put(
                    // Button with a ring around it that empties as the rest runs out.
                    JSONObject()
                        .put("type", 1)
                        .put("action", FOCUS_ACTION)
                        .put(
                            "progressInfo",
                            JSONObject()
                                .put("progress", remainingPercent)
                                .put("colorProgress", "#B28600")
                                .put("colorProgressDark", "#FFC107")
                                .put("colorProgressEnd", "#1A000000")
                                .put("colorProgressEndDark", "#29FFFFFF")
                                .put("isAutoProgress", true)
                                .put("isCCW", true),
                        ),
                ),
            )
        val focus = JSONObject()
            .put("protocol", 1)
            .put("scene", "timer")
            .put("ticker", label)
            .put("content", body)
            .put("timerType", -1)
            .put("timerWhen", endMs)
            .put("timerSystemCurrent", endMs - totalMs)
            .put("timerTotal", totalMs)
            .put("enableFloat", false)
            .put("updatable", true)
            .put("param_v2", focusV2)

        val pics = Bundle()
        pics.putParcelable(FOCUS_PIC, Icon.createWithResource(this, R.drawable.ic_stat_timer))
        val extras = Bundle()
        extras.putString("miui.focus.param", focus.toString())
        extras.putBundle("miui.focus.pics", pics)
        val focusActions = Bundle()
        focusActions.putParcelable(FOCUS_ACTION, nextSet)
        extras.putBundle("miui.focus.actions", focusActions)

        val builder = Notification.Builder(this, channelId)
            .setSmallIcon(R.drawable.ic_stat_timer)
            .setContentText(body)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
        if (systemDrawn) {
            // Posted once per rest, so the plain view counts down on its own too.
            builder.setContentTitle(label)
                .setShowWhen(true)
                .setWhen(endMs)
                .setUsesChronometer(true)
                .setChronometerCountDown(true)
        } else {
            builder.setContentTitle(title).setShowWhen(false)
        }
        val notification = builder
            .setCategory(Notification.CATEGORY_STOPWATCH)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setContentIntent(contentIntent)
            .addAction(nextSet)
            .addExtras(extras)
            .build()

        manager.notify(id, notification)
        return systemDrawn
    }

    private fun nextSetAction() = "$packageName.NEXT_SET"

    private companion object {
        const val FOCUS_PIC = "miui.focus.pic_timer"
        const val FOCUS_ACTION = "miui.focus.action_1"
    }
}
