#import "AppDelegate.h"

#import <React/RCTBundleURLProvider.h>
#import "RNNordicDfu.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.moduleName = @"newExample";
  // You can add your custom initial props in the dictionary below.
  // They will be passed down to the ViewController used by React Native.
  self.initialProps = @{};
  
  [RNNordicDfu setCentralManagerGetter:^() {
          return [[CBCentralManager alloc] initWithDelegate:nil queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
      }];

        // Reset manager delegate since the Nordic DFU lib "steals" control over it
            [RNNordicDfu setOnDFUComplete:^() {
                NSLog(@"onDFUComplete");
            }];
            [RNNordicDfu setOnDFUError:^() {
                NSLog(@"onDFUError");
            }];

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

@end
