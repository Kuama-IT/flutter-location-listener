package com.example.flutter_position_tracker

import android.app.Activity
import android.content.*
import android.util.Log
import androidx.annotation.NonNull
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.FlutterCallbackInformation
import net.kuama.android.backgroundLocation.service.BackgroundService
import java.lang.IllegalArgumentException

//import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter;


/** FlutterPositionTrackerPlugin */
@Suppress("DEPRECATED_IDENTITY_EQUALS")
class FlutterPositionTrackerPlugin: FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware, LifecycleEventObserver {
  val SHARED_PREFERENCES_KEY = "geofencing_plugin_cache"
  val USER_CALLBACK_ID_KEY = "userCallbackId"
  val PLUGIN_CALLBACK_ID_KEY = "pluginCallbackId"

  private var binaryMessenger: BinaryMessenger? = null
  private lateinit var context: Context
  private lateinit var activity: Activity
  private var location: Location? = null

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var methodChannel: MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    binaryMessenger = flutterPluginBinding.binaryMessenger
    context = flutterPluginBinding.applicationContext
    Log.e("And","onAttachedToEngine")
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    methodChannel = MethodChannel(binaryMessenger, "flutter_location_listener")
    methodChannel.setMethodCallHandler(this)
    activity = binding.activity

    Log.e("And","service started")
  }

  override fun onStateChanged(source: LifecycleOwner, event: Lifecycle.Event) {
    Log.e("And","onStateChanged $event ${source.lifecycle.currentState}")
//    if (event == Lifecycle.Event.ON_CREATE) {
//
//    }
  }

  override fun onDetachedFromActivityForConfigChanges() {
    Log.e("And","onDetachedFromActivityForConfigChanges")
//    activity.unregisterReceiver(receiver)
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    Log.e("And","onReattachedToActivityForConfigChanges")
//    activity.startService(Intent(activity, BackgroundService::class.java))
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    Log.e("And","onDetachedFromEngine")
//    methodChannel.setMethodCallHandler(null)
  }

  override fun onDetachedFromActivity() {
    Log.e("And","onDetachedFromActivity")
//    activity.unregisterReceiver(receiver)
  }
  private val receiver: MyBroadcastReceiver = MyBroadcastReceiver()

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    // listen position and push it
    Log.e("And","onMethodCall")
    when (call.method) {
      "startService" -> {
        Log.e("And","startService")
        val pluginCallbackId = parseLong(call, PLUGIN_CALLBACK_ID_KEY)
        val userCallbackId = parseLong(call, USER_CALLBACK_ID_KEY)

        context
          .getSharedPreferences(SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE)
          .edit()
          .putLong(PLUGIN_CALLBACK_ID_KEY, pluginCallbackId)
          .putLong(USER_CALLBACK_ID_KEY, userCallbackId)
          .apply()

        activity.applicationContext.registerReceiver(receiver, IntentFilter(BackgroundService::class.java.name))
        activity.applicationContext.startService(Intent(activity.applicationContext, BackgroundService::class.java))
        result.success(null)
      }
      "currentLocation" -> {
        result.success(location?.toMap())
        Log.e("And","currentLocation")
      }
      "stopService" -> {
        Log.e("And","stopService")
      }
    }
  }

  private var backgroundMethodChannel: MethodChannel? = null

  private inner class MyBroadcastReceiver: BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {

      val latitude = intent?.extras?.getDouble("latitude")
      val longitude = intent?.extras?.getDouble("longitude")

      if (latitude == null || longitude == null) return

      val preferences = context!!.getSharedPreferences(SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE)
      val pluginCallbackId = preferences.getLong(PLUGIN_CALLBACK_ID_KEY, -1)
      val userCallbackId = preferences.getLong(USER_CALLBACK_ID_KEY, -1)
      location = Location(latitude, longitude)

      if (backgroundMethodChannel == null) {
        val flutterLoader = FlutterLoader()
        flutterLoader.startInitialization(context)
        flutterLoader.ensureInitializationComplete(context, null)

        val userCallbackInformation = FlutterCallbackInformation.lookupCallbackInformation(pluginCallbackId)

        val args = DartExecutor.DartCallback(context.assets, flutterLoader.findAppBundlePath(), userCallbackInformation)

        val engine = FlutterEngine(context)
        engine.dartExecutor.executeDartCallback(args)

        backgroundMethodChannel = MethodChannel(engine.dartExecutor, "flutter_location_listener#callback")
      }

      val paramsMap = HashMap<String, Any>()
      paramsMap["location"] = location!!.toMap()
      paramsMap[USER_CALLBACK_ID_KEY] = userCallbackId
      backgroundMethodChannel!!.invokeMethod("FlutterLocationListener#onLocation", paramsMap)
    }
  }

  private fun parseLong(methodCall: MethodCall, name: String): Long {
    return when (val num = methodCall.argument<Any?>(name)) {
      is Long -> {
        num
      }
      is Int -> {
        num.toLong()
      }
      else -> {
        throw IllegalArgumentException(name)
      }
    }
  }
}

class Location constructor(private val latitude: Double, private val longitude: Double) {
  fun toMap(): HashMap<String, Double> {
    val hashMap: HashMap<String, Double> = HashMap()
    hashMap["latitude"] = latitude
    hashMap["longitude"] = longitude
    return hashMap
  }
}