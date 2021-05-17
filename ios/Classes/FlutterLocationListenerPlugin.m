#import "FlutterLocationListenerPlugin.h"
#if __has_include(<flutter_location_listener/flutter_location_listener-Swift.h>)
#import <flutter_location_listener/flutter_location_listener-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_location_listener-Swift.h"
#endif

@implementation FlutterLocationListenerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterLocationListenerPlugin registerWithRegistrar:registrar];
}
@end
