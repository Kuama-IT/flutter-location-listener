import Flutter
import UIKit
import ios_location_listener
import Combine
import CoreLocation
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
    
    let publisher = self.stream.subject
    let flutterengine = FlutterEngine.init()
    
    
    print("handle: \(call.method) \(call.arguments)")
    switch call.method {
      case "startService":
        if let args = call.arguments as? Dictionary<String, Any>,
           let pluginCallbackId = args["pluginCallbackId"] as? Int64,
           let userCallbackId = args["userCallbackId"] as? Int64 {
            let preferences = UserDefaults.standard
            preferences.set(pluginCallbackId, forKey: "pluginCallbackId")
            preferences.set(userCallbackId, forKey: "userCallbackId")
            preferences.synchronize()
            
            result(["latitude": -34.9, "longitude": 343.3])
            stream.startUpdatingLocations()
            DispatchQueue.main.async {
                self.cancellable = publisher?.sink{
                    loc in
                    self.location = loc
                    let map = ["location": ["latitude": loc.coordinate.latitude, "longitude": loc.coordinate.longitude], "userCallbackId": userCallbackId] as [String : Any]
                    
                    result(["latitude": loc.coordinate.latitude, "longitude": loc.coordinate.longitude])
                    let pluginCallbackInformation = FlutterCallbackCache.lookupCallbackInformation(pluginCallbackId)
                    
                    flutterengine.run(withEntrypoint: pluginCallbackInformation?.callbackName, libraryURI: pluginCallbackInformation?.callbackLibraryPath)
                    let backgroundMethodChannel = FlutterMethodChannel(name: "flutter_location_listener#callback", binaryMessenger: flutterengine.binaryMessenger)
                    backgroundMethodChannel.invokeMethod("FlutterLocationListener#onLocation", arguments: map)
                }
            }
        } else {
            result(FlutterError.init(code: "bad args", message: nil, details: nil))
          }
      
        
       
        
            
        break
            case  "currentLocation":
//                self.cancellable = stream.subject?.subscribe(on: DispatchQueue.global())
//                    .sink{s in
//
//                        self.location = s
//                        print("\(s.coordinate.latitude)-\(s.coordinate.longitude)")
//
//                                }
                result(["latitude": location?.coordinate.latitude, "longitude": location?.coordinate.longitude])
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
