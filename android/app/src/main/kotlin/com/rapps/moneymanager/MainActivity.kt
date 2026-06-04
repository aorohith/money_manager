package com.rapps.moneymanager

import android.Manifest
import android.content.pm.PackageManager
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import android.view.WindowManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingSmsSyncResult: MethodChannel.Result? = null

    companion object {
        private const val READ_SMS_REQUEST_CODE = 4217
        private const val DEFAULT_SMS_SYNC_LIMIT = 250
        private const val SMS_SYNC_WINDOW_DAYS = 90L
    }

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
                "syncActiveNotifications" -> {
                    result.success(SmsListenerService.syncActiveNotifications())
                }
                "syncSmsInbox" -> {
                    val limit = call.argument<Int>("limit") ?: DEFAULT_SMS_SYNC_LIMIT
                    syncSmsInbox(result, limit)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun syncSmsInbox(result: MethodChannel.Result, limit: Int) {
        if (
            ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) !=
                PackageManager.PERMISSION_GRANTED
        ) {
            if (pendingSmsSyncResult != null) {
                result.success(syncResult(granted = false, messages = emptyList()))
                return
            }
            pendingSmsSyncResult = result
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.READ_SMS),
                READ_SMS_REQUEST_CODE,
            )
            return
        }

        result.success(syncResult(granted = true, messages = readRecentSms(limit)))
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != READ_SMS_REQUEST_CODE) return

        val result = pendingSmsSyncResult ?: return
        pendingSmsSyncResult = null

        val granted = grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED
        result.success(
            syncResult(
                granted = granted,
                messages = if (granted) readRecentSms(DEFAULT_SMS_SYNC_LIMIT) else emptyList(),
            ),
        )
    }

    private fun syncResult(
        granted: Boolean,
        messages: List<Map<String, Any?>>,
    ): Map<String, Any?> {
        return mapOf(
            "granted" to granted,
            "messages" to messages,
        )
    }

    private fun readRecentSms(limit: Int): List<Map<String, Any?>> {
        val messages = mutableListOf<Map<String, Any?>>()
        val since = System.currentTimeMillis() - SMS_SYNC_WINDOW_DAYS * 24L * 60L * 60L * 1000L
        val cursor: Cursor? = contentResolver.query(
            Uri.parse("content://sms/inbox"),
            arrayOf("address", "body", "date"),
            "date >= ?",
            arrayOf(since.toString()),
            "date DESC",
        )

        cursor?.use {
            val addressIndex = it.getColumnIndex("address")
            val bodyIndex = it.getColumnIndex("body")
            val dateIndex = it.getColumnIndex("date")
            while (it.moveToNext() && messages.size < limit) {
                val body = it.getString(bodyIndex) ?: continue
                if (!isTransactionSmsCandidate(body)) continue
                messages.add(
                    mapOf(
                        "sender" to (it.getString(addressIndex) ?: ""),
                        "title" to "",
                        "body" to body,
                        "timestamp" to it.getLong(dateIndex),
                    ),
                )
            }
        }

        return messages
    }

    private fun isTransactionSmsCandidate(body: String): Boolean {
        val text = body.lowercase()
        val hasMoneySignal = listOf(
            "debited", "credited", "spent", "paid", "withdrawn",
            "transaction", "upi", "payment", "purchase", "debit",
            "rs.", "inr", "sent", "received", "a/c", "account",
            "dr", "cr", "a/c debited", "a/c credited",
        ).any { text.contains(it) } || text.contains("₹")

        val blocked = listOf(
            "otp", "one time password", "verification code", "failed",
            "declined", "reversed", "refund initiated",
        ).any { text.contains(it) }

        return hasMoneySignal && !blocked
    }
}
