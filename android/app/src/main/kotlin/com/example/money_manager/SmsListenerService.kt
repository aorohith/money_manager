package com.example.money_manager

import android.app.Notification
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import io.flutter.plugin.common.MethodChannel

/**
 * NotificationListenerService that intercepts banking / payment app
 * notifications and forwards transaction-relevant ones to Flutter via a
 * MethodChannel.
 *
 * Registration:
 *   - Declared in AndroidManifest.xml with BIND_NOTIFICATION_LISTENER_SERVICE.
 *   - User must grant access in Settings → Notification Access.
 *
 * The [channel] static reference is set by [MainActivity.configureFlutterEngine]
 * so the service can call back into the active Flutter engine.
 */
class SmsListenerService : NotificationListenerService() {

    companion object {
        const val CHANNEL_NAME = "com.example.money_manager/sms"
        var channel: MethodChannel? = null
        private val mainHandler = Handler(Looper.getMainLooper())

        /** Package names of known banking / payment apps. */
        private val trustedPackages = setOf(
            // HDFC
            "com.hdfc.mobilebanking",
            // ICICI
            "com.csam.icici.bank.imobile",
            // SBI
            "com.sbi.lotusintouch",
            "com.sbi.SBIFreedomPlus",
            // Axis
            "com.axis.mobile",
            // Kotak
            "com.kotak.mahindra.kotak811",
            "com.msf.kbank.mobile",
            // Yes Bank
            "com.yesbank",
            // IndusInd
            "com.indusind.mobilebanking",
            // Paytm
            "net.one97.paytm",
            // PhonePe
            "com.phonepe.app",
            // Google Pay
            "com.google.android.apps.nbu.paisa.user",
            // BHIM
            "in.org.npci.upiapp",
            // Amazon Pay
            "in.amazon.mShop.android.shopping",
            // CRED
            "com.dreamplug.androidapp",
            // Slice
            "in.bankopen.app",
        )

        /** Title keywords that signal a transaction notification. */
        private val transactionKeywords = listOf(
            "debited", "credited", "spent", "paid", "withdrawn",
            "transaction", "UPI", "payment", "purchase", "debit",
            "₹", "rs.", "inr", "sent", "received",
        )

        fun isNotificationListenerEnabled(context: android.content.Context): Boolean {
            val flat = Settings.Secure.getString(
                context.contentResolver,
                "enabled_notification_listeners"
            ) ?: return false
            return flat.contains(context.packageName)
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        val sbn = sbn ?: return
        val pkg = sbn.packageName ?: return
        val extras = sbn.notification?.extras ?: return

        val title = extras.getString(Notification.EXTRA_TITLE) ?: ""
        val body = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""

        if (!isTrusted(pkg, title, body)) return

        val payload = mapOf(
            "sender" to pkg,
            "title" to title,
            "body" to body,
            "timestamp" to sbn.postTime,
        )

        mainHandler.post {
            channel?.invokeMethod("onNotificationReceived", payload)
        }
    }

    private fun isTrusted(pkg: String, title: String, body: String): Boolean {
        if (trustedPackages.contains(pkg)) return true
        val combined = (title + body).lowercase()
        return transactionKeywords.any { combined.contains(it.lowercase()) }
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
    }
}
