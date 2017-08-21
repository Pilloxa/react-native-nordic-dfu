#import <CoreBluetooth/CoreBluetooth.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <iOSDFULibrary/iOSDFULibrary-Swift.h>

@interface RNNordicDfu : RCTEventEmitter<RCTBridgeModule, DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate>

@property (strong, nonatomic) NSString * deviceAddress;

+ (void)setCentralManagerGetter:(CBCentralManager * (^)())getter;

@end
