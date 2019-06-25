#import "DsBridgePlugin.h"
#import <ds_bridge/ds_bridge-Swift.h>

@implementation DsBridgePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDsBridgePlugin registerWithRegistrar:registrar];
}
@end
