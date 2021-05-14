import 'dart:async';

import 'package:flutter/services.dart';

class FlutterLocationListener {
  static FlutterLocationListener? _instance;

  FlutterLocationListener._();

  factory FlutterLocationListener() {
    return _instance ??= FlutterLocationListener._();
  }

  final _methodChannel = const MethodChannel('flutter_position_tracker');

  Future<void> startService() async {
    await _methodChannel.invokeMethod('startService');
  }

  Future<LatLng> get currentLocation async {
    final map = await _methodChannel.invokeMethod('currentLocation');
    return LatLng.fromMap(map);
  }

  Future<void> stopService() async {
    await _methodChannel.invokeMethod('stopService');
  }
/*

  Stream<LatLng> get onPositionChanges {
    if (_positionSubject == null) {
      _positionSubject = StreamController.broadcast(
        onListen: () {
          _methodChannel.invokeMethod('startService').asStream().map((event) {
            return LatLng.fromMap(event);
          }).listen(
            _positionSubject!.add,
            onError: _positionSubject!.addError,
          );
        },
        onCancel: () {
          _positionSubject!.close();
          _positionSubject = null;
        },
      );
    }


    return _positionSubject!.stream;
  }*/
}

class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);

  factory LatLng.fromMap(Map<dynamic, dynamic> map) {
    return LatLng(map['latitude'] as double, map['longitude'] as double);
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
      other is LatLng &&
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
