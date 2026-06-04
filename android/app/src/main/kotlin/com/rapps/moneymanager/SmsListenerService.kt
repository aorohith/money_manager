package com.rapps.moneymanager

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
        // Keep in sync with AppConfig.smsMethodChannel in lib/core/constants/app_config.dart
        const val CHANNEL_NAME = "com.rapps.moneymanager/sms"
        var channel: MethodChannel? = null
        private var activeService: SmsListenerService? = null
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
            "₹", "rs.", "inr", "sent", "received", "dr", "cr",
            "a/c debited", "a/c credited",
        )

        fun isNotificationListenerEnabled(context: android.content.Context): Boolean {
            val flat = Settings.Secure.getString(
                context.contentResolver,
                "enabled_notification_listeners"
            ) ?: return false
            return flat.contains(context.packageName)
        }

        fun syncActiveNotifications(): Int {
            return activeService?.syncActiveTransactionNotifications() ?: 0
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        val sbn = sbn ?: return
        forwardIfTrusted(sbn)
    }

    private fun syncActiveTransactionNotifications(): Int {
        val notifications = activeNotifications ?: return 0
        var dispatched = 0
        for (sbn in notifications) {
            if (forwardIfTrusted(sbn)) dispatched++
        }
        return dispatched
    }

    private fun forwardIfTrusted(sbn: StatusBarNotification): Boolean {
        val pkg = sbn.packageName ?: return false
        val extras = sbn.notification?.extras ?: return false

        val title = extras.getString(Notification.EXTRA_TITLE) ?: ""
        val body = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""

        if (!isTrusted(pkg, title, body)) return false

        val payload = mapOf(
            "sender" to pkg,
            "title" to title,
            "body" to body,
            "timestamp" to sbn.postTime,
        )

        mainHandler.post {
            channel?.invokeMethod("onNotificationReceived", payload)
        }
        return true
    }

    private fun isTrusted(pkg: String, title: String, body: String): Boolean {
        // Both the package allowlist AND a transaction keyword must match.
        // The previous OR check let any noisy notification mentioning "UPI"
        // or "₹" through, including spam SMS-mirror apps and chat threads.
        if (!trustedPackages.contains(pkg)) return false
        val combined = (title + body).lowercase()
        return transactionKeywords.any { combined.contains(it.lowercase()) }
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        activeService = this
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        if (activeService == this) {
            activeService = null
        }
    }
}
