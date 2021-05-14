import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

void pluginCallback() {
  WidgetsFlutterBinding.ensureInitialized();

  final methodChannel = MethodChannel('flutter_location_listener#callback');

  methodChannel.setMethodCallHandler((call) async {
    if (call.method == 'FlutterLocationListener#onLocation') {
      print("FlutterLocationListener#onLocation");

      final userCallbackId = call.arguments['userCallbackId'] as int;
      final location = Location.fromMap(call.arguments['location'] as Map<dynamic, dynamic>);

      final userCallbackHandle = CallbackHandle.fromRawHandle(userCallbackId);

      final userCallback =
          PluginUtilities.getCallbackFromHandle(userCallbackHandle) as void Function(Location);

      userCallback(location);
    } else {
      throw UnimplementedError('${call.method} has not been implemented');
    }
  });
}

class FlutterLocationListener {
  static FlutterLocationListener? _instance;

  factory FlutterLocationListener() {
    return _instance ??= FlutterLocationListener._();
  }

  FlutterLocationListener._();

  final _methodChannel = const MethodChannel('flutter_location_listener');

  Future<void> startService(Future<void> Function(Location location) userCallback) async {
    final pluginCallbackId = PluginUtilities.getCallbackHandle(pluginCallback)!.toRawHandle();
    final userCallbackId = PluginUtilities.getCallbackHandle(userCallback)!.toRawHandle();

    await _methodChannel.invokeMapMethod('startService', {
      'pluginCallbackId': pluginCallbackId.toUnsigned(64),
      'userCallbackId': userCallbackId,
    });
  }

  Future<Location> get currentLocation async {
    final map = await _methodChannel.invokeMethod('currentLocation');
    if (map == null) {
      throw 'Please start a service';
    }
    return Location.fromMap(map);
  }

  Future<void> stopService() async {
    await _methodChannel.invokeMethod('stopService');
  }
}

class Location {
  final double latitude;
  final double longitude;

  Location(this.latitude, this.longitude);

  factory Location.fromMap(Map<dynamic, dynamic> map) {
    return Location(map['latitude'] as double, map['longitude'] as double);
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'latitude': this.latitude,
      'longitude': this.longitude,
    } as Map<String, dynamic>;
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() {
    return 'LatLng{latitude: $latitude, longitude: $longitude}';
  }
}
