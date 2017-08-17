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
    resolve(@[]);
  }
}

@end
