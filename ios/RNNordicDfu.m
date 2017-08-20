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

- (NSString *)stateDescription:(enum DFUState)state
{
  switch (state)
  {
    case DFUStateAborted:
      return @"DFU_ABORTED";
    case DFUStateStarting:
      return @"DFU_PROCESS_STARTING";
    case DFUStateCompleted:
      return @"DFU_COMPLETED";
    case DFUStateUploading:
      return @"DFU_STATE_UPLOADING";
    case DFUStateConnecting:
      return @"CONNECTING";
    case DFUStateValidating:
      return @"FIRMWARE_VALIDATING";
    case DFUStateDisconnecting:
      return @"DEVICE_DISCONNECTING";
    case DFUStateEnablingDfuMode:
      return @"ENABLING_DFU_MODE";
  }

  return @"UNKNOWN_STATE";
}

- (void)dfuStateDidChangeTo:(enum DFUState)state
{
  NSDictionary * evtBody = @{@"deviceAddress": self.deviceAddress,
                             @"state": [self stateDescription:state],};

  [self sendEventWithName:@"DFUStateChanged" body:evtBody];
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
  NSDictionary * evtBody = @{@"deviceAddress": self.deviceAddress,
                             @"currentPart": [NSNumber numberWithInteger:part],
                             @"partsTotal": [NSNumber numberWithInteger:totalParts],
                             @"percent": [NSNumber numberWithInteger:progress],
                             @"speed": [NSNumber numberWithDouble:currentSpeedBytesPerSecond],
                             @"avgSpeed": [NSNumber numberWithDouble:avgSpeedBytesPerSecond],};

  [self sendEventWithName:@"DFUProgress" body:evtBody];
}

- (void)logWith:(enum LogLevel)level message:(NSString * _Nonnull)message
{
  NSLog(@"logWith: %ld message: '%@'", (long)level, message);
}

RCT_EXPORT_METHOD(setCentralManager:(NSString *)address
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  sscanf([address cStringUsingEncoding:NSUTF8StringEncoding], "%p", &centralManager);

  resolve(@[]);
}

RCT_EXPORT_METHOD(startDFU:(NSString *)deviceAddress
                  deviceName:(NSString *)deviceName
                  filePath:(NSString *)filePath
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  self.deviceAddress = deviceAddress;

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

      NSURL * url = [NSURL URLWithString:filePath];

      DFUFirmware * firmware = [DFUFirmware alloc];
      [firmware initWithUrlToZipFile:url];

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
