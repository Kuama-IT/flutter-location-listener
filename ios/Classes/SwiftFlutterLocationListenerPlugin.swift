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
    var publisher = StreamLocation().subject
    let flutterengine = FlutterEngine.init()
    let backgroundMethodChannel = FlutterMethodChannel(name: "flutter_location_listener#callback", binaryMessenger: flutterengine.binaryMessenger)
    
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
   
    flutterengine.run(withEntrypoint: pluginCallbackInformation?.callbackName, libraryURI: pluginCallbackInformation?.callbackLibraryPath)
    let pluginCallbackInformation = FlutterCallbackCache.lookupCallbackInformation(pluginCallbackId)
    print("handle: \(call.method) \(call.arguments)")
    
    if let args = call.arguments as? Dictionary<String, Any>,
       let pluginCallbackId = args["pluginCallbackId"] as? Int64,
       let userCallbackId = args["userCallbackId"] as? Int64 {
        let preferences = UserDefaults.standard
        preferences.set(pluginCallbackId, forKey: "pluginCallbackId")
        preferences.set(userCallbackId, forKey: "userCallbackId")
        preferences.synchronize()
        
      
        
        
    } else {
        result(FlutterError.init(code: "bad args", message: nil, details: nil))
      }
    
    switch call.method {
      case "startService":
       
        stream.startUpdatingLocations()
        DispatchQueue.main.async {
            self.cancellable = publisher?.sink{
                loc in
                self.location = loc
                let map = ["location": ["latitude": self.location.coordinate.latitude, "longitude": self.location.coordinate.longitude], "userCallbackId": userCallbackId] as [String : Any]
            
                backgroundMethodChannel.invokeMethod("FlutterLocationListener#onLocation", arguments: map)
            }
        }
            
        break
            case  "currentLocation":
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
