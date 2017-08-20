#import <CoreBluetooth/CoreBluetooth.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <iOSDFULibrary/iOSDFULibrary-Swift.h>

@interface RNNordicDfu : RCTEventEmitter<RCTBridgeModule, DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate>

+ (void)setCentralManagerGetter:(CBCentralManager * (^)())getter;

@end
