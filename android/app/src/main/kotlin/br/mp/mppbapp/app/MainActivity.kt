package br.mp.mppbapp.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import android.content.Context
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }

        val channel = NotificationChannel(
            NOTIFICATION_CHANNEL_ID,
            "Alertas MPPB+",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Notificações de notícias e designações"
            enableVibration(true)
            lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
        }

        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.createNotificationChannel(channel)
    }

    companion object {
        private const val NOTIFICATION_CHANNEL_ID = "mppb_alertas"
    }
}
