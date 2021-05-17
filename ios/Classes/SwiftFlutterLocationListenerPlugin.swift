import Flutter
import UIKit
import ios_location_listener
import Combine
import CoreLocation
public class SwiftFlutterLocationListenerPlugin: NSObject, FlutterPlugin {
    var backgroundMethodChannel : FlutterMethodChannel? = nil
    var binaryMessage : FlutterBinaryMessenger? = nil
  public static func register(with registrar: FlutterPluginRegistrar) {
    self.binaryMessage = registrar.messenger()
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
            self.cancellable = self.stream.subject?.subscribe(on: DispatchQueue.global()).sink {
            s in
              self.location = s
                print("\(s.coordinate.latitude)-\(s.coordinate.longitude)")
                
                if (backgroundMethodChannel == nil) {

//                    val flutterLoader = FlutterLoader()
//                           flutterLoader.startInitialization(context)
//                           flutterLoader.ensureInitializationComplete(context, null)
//
//                           val userCallbackInformation = FlutterCallbackInformation.lookupCallbackInformation(pluginCallbackId)
//
//                           val args = DartExecutor.DartCallback(context.assets, flutterLoader.findAppBundlePath(), userCallbackInformation)
//
//                           val engine = FlutterEngine(context)
//                           engine.dartExecutor.executeDartCallback(args)
//
//                           backgroundMethodChannel = MethodChannel(engine.dartExecutor, "flutter_location_listener#callback")

                    backgroundMethodChannel = FlutterMethodChannel(name: "flutter_location_listener#callback", binaryMessenger: self.binaryMessage)
                      }
                
                }
        
            result(["latitude": location?.coordinate.latitude, "longitude": location?.coordinate.longitude])
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
