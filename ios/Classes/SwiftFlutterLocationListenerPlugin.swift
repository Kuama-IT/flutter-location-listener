import Flutter
import UIKit
import ios_location_listener
import Combine

public class SwiftFlutterLocationListenerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_location_listener", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterLocationListenerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  let stream = StreamLocation()
  var cancellable: AnyCancellable? = nil
  var location: CLLocation? = nil
    
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    print("handle: \(call.method) \(call.arguments)")
    switch call.method {
      case "startService":
        let args = call.arguments as! Dictionary<String, Any>
        let pluginCallbackId = args["pluginCallbackId"] as! Int
        let userCallbackId = args["userCallbackId"] as! Int
            
        let preferences = UserDefaults.standard
        preferences.set(pluginCallbackId, forKey: "pluginCallbackId")
        preferences.set(userCallbackId, forKey: "userCallbackId")
        preferences.synchronize()
        
        stream.startUpdatingLocations()
        DispatchQueue.main.async{
            self.cancellable = self.stream.subject?.sink {
            s in
              self.location = s
              print("\(s.coordinate.latitude)-\(s.coordinate.longitude)")
          }
        }

        result(nil)
        break
      case "currentLocation":
        let l = location
        result(l == nil
                ? nil
                : ["latitude": l.coordinate.latitude, "longitude": l.coordinate?.longitude])
        break
      case "stopService":
        stream.stopUpdates()
        DispatchQueue.main.async {
          self.cancellable?.cancel()
        }
        default:
            break
    }
  }
}
