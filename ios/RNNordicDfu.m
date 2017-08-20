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

  if (!deviceAddress) {
    reject(@"nil_device_address", @"Attempted to start DFU with nil deviceAddress", nil);
  } else if (!filePath) {
    reject(@"nil_file_path", @"Attempted to start DFU with nil filePath", nil);
  } else if (!centralManager) {
    reject(@"not_initialized", @"centralManager must be set before starting DFU", nil);
  } else {
    NSUUID * uuid = [[NSUUID alloc] initWithUUIDString:deviceAddress];

    NSArray<CBPeripheral *> * peripherals = [centralManager retrievePeripheralsWithIdentifiers:@[uuid]];

    if ([peripherals count] != 1) {
      reject(@"unable_to_find_device", @"Could not find device with deviceAddress", nil);
    } else {
      CBPeripheral * peripheral = [peripherals objectAtIndex:0];

      NSURL * webUrl = [NSURL URLWithString:filePath];
      NSData * urlData = [NSData dataWithContentsOfURL:webUrl];
      NSURL * dataUrl = [NSURL URLWithDataRepresentation:urlData relativeToURL:NULL];

      DFUFirmware * firmware = [DFUFirmware alloc];
      [firmware initWithUrlToZipFile:dataUrl];

      DFUServiceInitiator * initiator = [[[DFUServiceInitiator alloc]
                                          initWithCentralManager:centralManager
                                          target:peripheral]
                                         withFirmware:firmware];

      initiator.logger = self;
      initiator.delegate = self;
      initiator.progressDelegate = self;

      DFUServiceController * controller = [initiator start];

      resolve(@[]);
    }
  }
}

@end
