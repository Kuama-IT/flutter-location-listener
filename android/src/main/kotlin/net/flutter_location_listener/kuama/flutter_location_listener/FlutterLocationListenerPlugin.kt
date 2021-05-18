package net.flutter_location_listener.kuama.flutter_location_listener

import android.content.*
import androidx.annotation.NonNull

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.FlutterCallbackInformation

import net.kuama.android.backgroundLocation.service.BackgroundService
import java.lang.IllegalArgumentException

private const val SHARED_PREFERENCES_KEY = "geofencing_plugin_cache"
private const val USER_CALLBACK_ID_KEY = "userCallbackId"
private const val PLUGIN_CALLBACK_ID_KEY = "pluginCallbackId"

/** FlutterLocationListenerPlugin */
class FlutterLocationListenerPlugin: FlutterPlugin, MethodChannel.MethodCallHandler {
  private lateinit var binaryMessenger: BinaryMessenger
  private lateinit var applicationContext: Context
  private lateinit var methodChannel: MethodChannel

  private var location: Location? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    binaryMessenger = flutterPluginBinding.binaryMessenger
    applicationContext = flutterPluginBinding.applicationContext
    methodChannel = MethodChannel(binaryMessenger, "flutter_location_listener")
    methodChannel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
  }

  private val receiver: LocationBroadcastReceiver = LocationBroadcastReceiver()

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "startService" -> {
        val context = applicationContext
        val pluginCallbackId = parseLong(call, PLUGIN_CALLBACK_ID_KEY)
        val userCallbackId = parseLong(call, USER_CALLBACK_ID_KEY)

        context
                .getSharedPreferences(SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE)
                .edit()
                .putLong(PLUGIN_CALLBACK_ID_KEY, pluginCallbackId)
                .putLong(USER_CALLBACK_ID_KEY, userCallbackId)
                .apply()

        context.registerReceiver(receiver, IntentFilter(BackgroundService::class.java.name))
        context.startService(Intent(context, BackgroundService::class.java))
        result.success(null)
      }
      "currentLocation" -> {
        result.success(location?.toMap())
      }
      "stopService" -> {
        val context = applicationContext
        context.stopService(Intent(context, BackgroundService::class.java))
        result.success(null)
      }
    }
  }

  private var backgroundMethodChannel: MethodChannel? = null

  private inner class LocationBroadcastReceiver: BroadcastReceiver() {
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

      val paramsMap = hashMapOf(
        "location" to location!!.toMap(),
        USER_CALLBACK_ID_KEY to userCallbackId,
      )
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
    return hashMapOf("latitude" to latitude, "longitude" to longitude)
  }
}
