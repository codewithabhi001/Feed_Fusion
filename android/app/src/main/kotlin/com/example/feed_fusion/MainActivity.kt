package com.example.feed_fusion

import android.os.Build
import android.view.Display
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onResume() {
        super.onResume()
        enableHighRefreshRate()
    }

    private fun enableHighRefreshRate() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val display = display
            if (display != null) {
                val supportedModes = display.supportedModes
                // Find mode with highest refresh rate
                val maxRefreshRateMode = supportedModes.maxByOrNull { it.refreshRate }
                if (maxRefreshRateMode != null) {
                    window.attributes.preferredDisplayModeId = maxRefreshRateMode.modeId
                }
            }
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            // For Android 6.0 to 10
            val modes = window.windowManager.defaultDisplay.supportedModes
            val maxMode = modes.maxByOrNull { it.refreshRate }
            if (maxMode != null) {
                val params = window.attributes
                params.preferredDisplayModeId = maxMode.modeId
                window.attributes = params
            }
        }
    }
}
