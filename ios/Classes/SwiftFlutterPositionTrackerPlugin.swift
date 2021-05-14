import Flutter
import UIKit

public class SwiftFlutterPositionTrackerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterEventChannel(name: "flutter_position_tracker", binaryMessenger: registrar.messenger())
    channel.setStreamHandler(SwiftStreamHandler())
    
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}

class SwiftStreamHandler: NSObject, FlutterStreamHandler {
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        var locationDictionary:[String:Double] = ["latitude":75.8, "longitude":8.2]
        events(locationDictionary) // any generic type or more compex dictionary of [String:Any]
//        events(FlutterError(code: "ERROR_CODE",
//                             message: "Detailed message",
//                             details: nil)) // in case of errors
//        events(FlutterEndOfEventStream) // when stream is over

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            var locationDictionary2:[String:Double] = ["latitude":33.3, "longitude":84.244]
            events(locationDictionary2)
        }
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
}
