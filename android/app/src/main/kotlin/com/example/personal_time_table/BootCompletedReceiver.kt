package com.example.personal_time_table

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootCompletedReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d("BootCompletedReceiver", "Device boot completed, rescheduling notifications")

            // The Flutter app will reschedule notifications on startup automatically
            // via the timetable_provider reschedul logic in main.dart
        }
    }
}
