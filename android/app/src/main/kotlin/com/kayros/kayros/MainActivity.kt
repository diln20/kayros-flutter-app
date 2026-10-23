package com.kayros.kayros

import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val hasFirebase = flutterEngine.plugins.has(FlutterFirebaseCorePlugin::class.java)
        Log.i("KayrosPluginCheck", "Firebase Core registered after super: $hasFirebase")
        if (!hasFirebase) {
            GeneratedPluginRegistrant.registerWith(flutterEngine)
            Log.i("KayrosPluginCheck", "Firebase Core registered after explicit: " +
                flutterEngine.plugins.has(FlutterFirebaseCorePlugin::class.java))
        }
    }
}
