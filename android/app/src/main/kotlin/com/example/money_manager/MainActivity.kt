package com.example.money_manager

import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Block balances + PIN entry from showing in the recent-apps task
        // switcher snapshot, and from external screen recording / casting.
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE,
        )
    }

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
