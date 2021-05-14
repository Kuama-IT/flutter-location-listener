#import "FlutterPositionTrackerPlugin.h"
#if __has_include(<flutter_position_tracker/flutter_position_tracker-Swift.h>)
#import <flutter_position_tracker/flutter_position_tracker-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_position_tracker-Swift.h"
#endif

@implementation FlutterPositionTrackerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterPositionTrackerPlugin registerWithRegistrar:registrar];
}
@end
