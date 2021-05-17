# flutter_location_listener

A new Flutter project.

## Getting Started


1. 
 - Android: Update Manifest
```xml
<manifest>

    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    
    <application android:enabled="true">
        <!-- ... -->

        <receiver
                android:name="net.kuama.android.backgroundLocation.broadcasters.BroadcastServiceStopper"
                android:enabled="true"
                android:exported="true">
            <intent-filter>
                <action android:name="BackgroundService" />
            </intent-filter>
        </receiver>

        <service
                android:name="net.kuama.android.backgroundLocation.service.BackgroundService"
                android:foregroundServiceType="location" />
    </application>
    
</manifest>
```
  - Ios: Select your project, select the "Signing & Capabilities" tab, click on the "+" button and add "Background Modes". Check and activate "Location updates", "Backgroud Fetch" and "Background Processing".

2. Require permission

3. Start service and register location callback