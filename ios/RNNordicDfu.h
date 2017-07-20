#import <CoreBluetooth/CoreBluetooth.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RNNordicDfu : RCTEventEmitter<RCTBridgeModule>

@property (strong, nonatomic) CBCentralManager * centralManager;

@end
