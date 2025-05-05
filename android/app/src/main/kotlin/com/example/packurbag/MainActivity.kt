package com.example.packurbag

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.os.Bundle
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.packurbag/shared_content"
    private var sharedData: Map<String, Any>? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSharedContent" -> {
                    result.success(sharedData)
                    sharedData = null
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent) {
        if (intent.action == Intent.ACTION_SEND) {
            val data = mutableMapOf<String, Any>()

            // Handle shared image
            if (intent.type?.startsWith("image/") == true) {
                val imageUri = intent.getParcelableExtra<android.net.Uri>(Intent.EXTRA_STREAM)
                if (imageUri != null) {
                    data["image"] = imageUri.toString()
                }
            }

            // Handle shared text
            if (intent.type == "text/plain") {
                val sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)
                if (sharedText != null) {
                    data["text"] = sharedText
                    
                    // Try to extract amount from GPay message
                    val amountPatterns = listOf(
                        Regex("""(?:Rs\.?|₹|INR)\s*(\d+(?:\.\d{2})?)""", RegexOption.IGNORE_CASE),
                        Regex("""(?:paid|sent|transferred)\s*(?:Rs\.?|₹|INR)?\s*(\d+(?:\.\d{2})?)""", RegexOption.IGNORE_CASE),
                        Regex("""amount\s*(?:Rs\.?|₹|INR)?\s*(\d+(?:\.\d{2})?)""", RegexOption.IGNORE_CASE)
                    )
                    
                    for (pattern in amountPatterns) {
                        val amountMatch = pattern.find(sharedText)
                        if (amountMatch != null) {
                            data["amount"] = amountMatch.groupValues[1]
                            break
                        }
                    }

                    // Try to extract description/recipient
                    val descriptionPatterns = listOf(
                        Regex("""(?:paid|sent|to)\s+([^,]+)""", RegexOption.IGNORE_CASE),
                        Regex("""(?:recipient|beneficiary):\s*([^,]+)""", RegexOption.IGNORE_CASE),
                        Regex("""(?:for|purpose):\s*([^,]+)""", RegexOption.IGNORE_CASE)
                    )
                    
                    for (pattern in descriptionPatterns) {
                        val descriptionMatch = pattern.find(sharedText)
                        if (descriptionMatch != null) {
                            data["description"] = descriptionMatch.groupValues[1].trim()
                            break
                        }
                    }

                    // Try to extract transaction ID
                    val transactionPattern = Regex("""(?:transaction|txn|ref)(?:id|no)?[:\s]+([A-Za-z0-9]+)""", RegexOption.IGNORE_CASE)
                    val transactionMatch = transactionPattern.find(sharedText)
                    if (transactionMatch != null) {
                        data["transactionId"] = transactionMatch.groupValues[1]
                    }
                }
            }

            if (data.isNotEmpty()) {
                sharedData = data
                // Notify Flutter that new shared content is available
                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                    .invokeMethod("onSharedContent", data)
            }
        }
    }
} 