package com.abhicracker.downgram

import android.content.Intent
import android.net.Uri
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "downgram_scan"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "sendBroadcast") {
                    val filePath = call.argument<String>("filePath")
                    sendBroadcast(filePath)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun sendBroadcast(filePath: String?) {
        val fileUri = Uri.parse(filePath)
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            val mediaScanIntent = Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, fileUri)
            sendBroadcast(mediaScanIntent)
        }
    }
}
