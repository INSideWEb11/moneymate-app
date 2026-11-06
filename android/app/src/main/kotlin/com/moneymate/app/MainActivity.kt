package com.moneymate.app

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val SMS_CHANNEL = "com.moneymate.app/sms_parser"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getRecentFinancialSms" -> {
                    // Safe native layer: returns empty list until granted Play SMS permission approval
                    val messages = SmsParserPlugin.readRecentFinancialMessages(this)
                    result.success(messages)
                }
                "checkSmsPermission" -> {
                    val hasPerm = SmsParserPlugin.hasPermission(this)
                    result.success(hasPerm)
                }
                else -> result.notImplemented()
            }
        }
    }
}
