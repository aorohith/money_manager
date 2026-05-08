package com.example.money_manager

import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Wire the shared MethodChannel so SmsListenerService can call back
        // into the active Flutter engine.
        val channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SmsListenerService.CHANNEL_NAME,
        )
        SmsListenerService.channel = channel

        // Handle calls from Dart → Kotlin
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isNotificationListenerEnabled" -> {
                    result.success(
                        SmsListenerService.isNotificationListenerEnabled(this)
                    )
                }
                "openNotificationSettings" -> {
                    val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    startActivity(intent)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
