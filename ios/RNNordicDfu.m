#import "RNNordicDfu.h"
#import "iOSDFULibrary-Swift.h"
#import <CoreBluetooth/CoreBluetooth.h>

@implementation RNNordicDfu

RCT_EXPORT_MODULE();

@synthesize centralManager;

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"DFUProgress",
           @"DFUStateChanged"];
}

- (void)dfuStateDidChangeTo:(enum DFUState)state
{
  NSLog(@"dfuStateDidChangeTo: %lu", (long)state);
}

- (void)   dfuError:(enum DFUError)error
didOccurWithMessage:(NSString * _Nonnull)message
{
  NSLog(@"dfuError: %lu didOccurWithMessage: %@", error, message);
}

- (void)dfuProgressDidChangeFor:(NSInteger)part
                          outOf:(NSInteger)totalParts
                             to:(NSInteger)progress
     currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond
         avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond
{
  NSLog(@"dfuProgressDidChangeFor: %ld "
        "outOf: %ld "
        "to: %ld "
        "currentSpeedBytesPerSecond: %f "
        "avgSpeedBytedPerSecond: %f",
        (long)part,
        (long)totalParts,
        (long)progress,
        currentSpeedBytesPerSecond,
        avgSpeedBytesPerSecond);
}

- (void)logWith:(enum LogLevel)level message:(NSString * _Nonnull)message
{
  NSLog(@"logWith: %ld message: '%@'", (long)level, message);
}

RCT_EXPORT_METHOD(setCentralManager:(NSString *)address
                           resolver:(RCTPromiseResolveBlock)resolve
                           rejecter:(RCTPromiseRejectBlock)reject)
{
  NSLog(@"setCentralManager: '%@'", address);

  sscanf([address cStringUsingEncoding:NSUTF8StringEncoding], "%p", &centralManager);

  resolve(@[]);
}

RCT_EXPORT_METHOD(startDFU:(NSString *)deviceAddress
                deviceName:(NSString *)deviceName
                  filePath:(NSString *)filePath
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSLog(@"startDFU: '%@' deviceName: '%@' filePath: '%@'",
        deviceAddress, deviceName, filePath);

  if (!centralManager) {
    reject(@"not_initialized", @"centralManager must be set before starting DFU", nil);
  } else {
    NSURL * url = [[NSURL alloc] initWithString:@"abc"];
    DFUFirmware * selectedFirmware = [[DFUFirmware alloc] initWithUrlToZipFile:url];
    CBPeripheral * selectedPeripheral = NULL;
    DFUServiceInitiator *initiator = [[DFUServiceInitiator alloc] initWithCentralManager: centralManager target:selectedPeripheral];
    [initiator withFirmware:selectedFirmware];
    initiator.logger = self; // - to get log info
    initiator.delegate = self; // - to be informed about current state and errors
    initiator.progressDelegate = self; // - to show progress bar

    DFUServiceController *controller = [initiator start];

    resolve(@[]);
  }
}

@end
