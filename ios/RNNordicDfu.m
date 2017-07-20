#import "RNNordicDfu.h"

@implementation RNNordicDfu

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"DFUProgress",
           @"DFUStateChanged"];
}

RCT_EXPORT_METHOD(startDFU:(NSString *)deviceAddress
                deviceName:(NSString *)deviceName
                  filePath:(NSString *)filePath
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSLog(@"startDFU: '%@' deviceName: '%@' filePath: '%@'",
        deviceAddress, deviceName, filePath);

  resolve(@[]);
}

@end
