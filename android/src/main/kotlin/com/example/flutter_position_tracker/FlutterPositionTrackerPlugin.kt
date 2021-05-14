package com.example.flutter_position_tracker

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import net.kuama.android.backgroundLocation.service.BackgroundService

/** FlutterPositionTrackerPlugin */
@Suppress("DEPRECATED_IDENTITY_EQUALS")
class FlutterPositionTrackerPlugin: FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware, BroadcastReceiver() {
  private var binaryMessenger: BinaryMessenger? = null
  private lateinit var activity: Activity
  private var latitude: Any? = null
  private var longitude: Any? = null

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var methodChannel: MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    binaryMessenger = flutterPluginBinding.binaryMessenger
    Log.e("And","onAttachedToEngine")
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
    Log.e("And","onDetachedFromEngine")
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    // listen position and push it
    Log.e("And","onMethodCall")
    when (call.method) {
        "startService" -> {
          Log.e("And","startService")


          val intentFilter = IntentFilter(BackgroundService::class.java.name)

          activity.registerReceiver(this, intentFilter)

          //ask permissions and then start the service
          activity.startService(Intent(activity, BackgroundService::class.java))
          result.success(null)
        }
        "currentLocation" -> {
          val hashMap : HashMap<String, Any?> = HashMap()
          hashMap["latitude"] = latitude
          hashMap["longitude"] = longitude
          result.success(hashMap)
          Log.e("And","currentLocation")
        }
        "stopService" -> {
          Log.e("And","stopService")
        }
    }
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    methodChannel = MethodChannel(binaryMessenger, "flutter_position_tracker")
    methodChannel.setMethodCallHandler(this)
    activity = binding.activity

    Log.e("And","service started")
  }

  override fun onDetachedFromActivityForConfigChanges() {
    Log.e("And","onDetachedFromActivityForConfigChanges")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    Log.e("And","onReattachedToActivityForConfigChanges")
  }

  override fun onDetachedFromActivity() {
    Log.e("And","onDetachedFromActivity")
  }

  override fun onReceive(context: Context?, intent: Intent?) {
    Log.e("And","onReceive")
    println(intent)
    latitude = intent?.extras?.getDouble("latitude")
    longitude = intent?.extras?.getDouble("longitude")
  }
}