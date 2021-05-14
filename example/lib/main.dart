import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_location_listener/flutter_location_listener.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PermissionStatus? _permissionStatus;
  dynamic _location = 'Unknown';

  @override
  Widget build(BuildContext context) {
    // initPlatformState();
    return MaterialApp(
      home: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final permissionStatus = await Permission.locationAlways.request();
                  setState(() {
                    _permissionStatus = permissionStatus;
                  });
                },
                child: Text('Require Permission'),
              ),
              Text('Permission: $_permissionStatus'),
              ElevatedButton(
                onPressed: () async {
                  await FlutterLocationListener().startService();
                  setState(() {
                    _location = 'Online';
                  });
                },
                child: Text('Launch Service'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final lastLocation = await FlutterLocationListener().currentLocation;

                    print("Last location $lastLocation");

                    setState(() {
                      _location = lastLocation;
                    });
                  } on PlatformException {
                    _location = 'Failed to get platform version.';
                  }
                },
                child: Text('Read Location'),
              ),
              Text('Location: $_location\n'),
            ],
          ),
        ),
      ),
    );
  }
}
