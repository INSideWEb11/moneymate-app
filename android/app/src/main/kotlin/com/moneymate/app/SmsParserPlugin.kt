package com.moneymate.app

import android.content.Context
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat

object SmsParserPlugin {
    fun hasPermission(context: Context): Boolean {
        return ContextCompat.checkSelfPermission(
            context,
            android.Manifest.permission.READ_SMS
        ) == PackageManager.PERMISSION_GRANTED
    }

    fun readRecentFinancialMessages(context: Context): List<Map<String, Any>> {
        // Safe design according to Google Play financial policies:
        // Reads on-device financial transactional messages only when explicitly granted.
        val results = mutableListOf<Map<String, Any>>()
        if (!hasPermission(context)) {
            return results
        }

        try {
            val cursor = context.contentResolver.query(
                android.net.Uri.parse("content://sms/inbox"),
                arrayOf("address", "body", "date"),
                null,
                null,
                "date DESC LIMIT 50"
            )

            cursor?.use {
                val addressIdx = it.getColumnIndex("address")
                val bodyIdx = it.getColumnIndex("body")
                val dateIdx = it.getColumnIndex("date")

                while (it.moveToNext()) {
                    val address = if (addressIdx != -1) it.getString(addressIdx) else ""
                    val body = if (bodyIdx != -1) it.getString(bodyIdx) else ""
                    val date = if (dateIdx != -1) it.getLong(dateIdx) else 0L

                    // Basic financial heuristic filter on device
                    if (isFinancialMessage(body)) {
                        results.add(
                            mapOf(
                                "sender" to address,
                                "body" to body,
                                "timestamp" to date
                            )
                        )
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return results
    }

    private fun isFinancialMessage(body: String): Boolean {
        val lower = body.lowercase()
        return (lower.contains("debited") || lower.contains("credited") || 
                lower.contains("spent") || lower.contains("inr") || 
                lower.contains("rs.") || lower.contains("upi"))
    }
}
