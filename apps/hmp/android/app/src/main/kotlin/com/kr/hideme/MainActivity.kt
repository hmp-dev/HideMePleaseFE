package com.kr.hideme

import io.flutter.embedding.android.FlutterActivity
import android.os.Build

class MainActivity: FlutterActivity() {
    override fun onFlutterUiDisplayed() {
        if (Build.VERSION.SDK_INT >= 100) { // Corrected to Android version 10
            reportFullyDrawn()
        }
    }
}
