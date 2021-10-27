#import "RNNordicDfu.h"
#import <CoreBluetooth/CoreBluetooth.h>
@import iOSDFULibrary;

static CBCentralManager * (^getCentralManager)();
static void (^onDFUComplete)();
static void (^onDFUError)();

@implementation RNNordicDfu

RCT_EXPORT_MODULE();

NSString * const DFUProgressEvent = @"DFUProgress";
NSString * const DFUStateChangedEvent = @"DFUStateChanged";

- (NSArray<NSString *> *)supportedEvents
{
  return @[DFUProgressEvent,
           DFUStateChangedEvent,];
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
    default:
      return @"UNKNOWN_STATE";
  }
}

- (NSString *)errorDescription:(enum DFUError)error
{
  switch(error)
  {
    case DFUErrorCrcError:
      return @"DFUErrorCrcError";
    case DFUErrorBytesLost:
      return @"DFUErrorBytesLost";
    case DFUErrorFileInvalid:
      return @"DFUErrorFileInvalid";
    case DFUErrorFailedToConnect:
      return @"DFUErrorFailedToConnect";
    case DFUErrorFileNotSpecified:
      return @"DFUErrorFileNotSpecified";
    case DFUErrorBluetoothDisabled:
      return @"DFUErrorBluetoothDisabled";
    case DFUErrorDeviceDisconnected:
      return @"DFUErrorDeviceDisconnected";
    case DFUErrorDeviceNotSupported:
      return @"DFUErrorDeviceNotSupported";
    case DFUErrorInitPacketRequired:
      return @"DFUErrorInitPacketRequired";
    case DFUErrorUnsupportedResponse:
      return @"DFUErrorUnsupportedResponse";
    case DFUErrorReadingVersionFailed:
      return @"DFUErrorReadingVersionFailed";
    case DFUErrorRemoteLegacyDFUSuccess:
      return @"DFUErrorRemoteLegacyDFUSuccess";
    case DFUErrorRemoteSecureDFUSuccess:
      return @"DFUErrorRemoteSecureDFUSuccess";
    case DFUErrorServiceDiscoveryFailed:
      return @"DFUErrorServiceDiscoveryFailed";
    case DFUErrorRemoteLegacyDFUCrcError:
      return @"DFUErrorRemoteLegacyDFUCrcError";
    case DFUErrorEnablingControlPointFailed:
      return @"DFUErrorEnablingControlPointFailed";
    case DFUErrorExtendedInitPacketRequired:
      return @"DFUErrorExtendedInitPacketRequired";
    case DFUErrorReceivingNotificationFailed:
      return @"DFUErrorReceivingNotificationFailed";
    case DFUErrorRemoteButtonlessDFUSuccess:
      return @"DFUErrorRemoteButtonlessDFUSuccess";
    case DFUErrorRemoteLegacyDFUInvalidState:
      return @"DFUErrorRemoteLegacyDFUInvalidState";
    case DFUErrorRemoteLegacyDFUNotSupported:
      return @"DFUErrorRemoteLegacyDFUNotSupported";
    case DFUErrorWritingCharacteristicFailed:
      return @"DFUErrorWritingCharacteristicFailed";
    case DFUErrorRemoteSecureDFUExtendedError:
      return @"DFUErrorRemoteSecureDFUExtendedError";
    case DFUErrorRemoteSecureDFUInvalidObject:
      return @"DFUErrorRemoteSecureDFUInvalidObject";
    case DFUErrorRemoteLegacyDFUOperationFailed:
      return @"DFUErrorRemoteLegacyDFUOperationFailed";
    case DFUErrorRemoteSecureDFUOperationFailed:
      return @"DFUErrorRemoteSecureDFUOperationFailed";
    case DFUErrorRemoteSecureDFUUnsupportedType:
      return @"DFUErrorRemoteSecureDFUUnsupportedType";
    case DFUErrorRemoteLegacyDFUDataExceedsLimit:
      return @"DFUErrorRemoteLegacyDFUDataExceedsLimit";
    case DFUErrorRemoteSecureDFUInvalidParameter:
      return @"DFUErrorRemoteSecureDFUInvalidParameter";
    case DFUErrorRemoteSecureDFUSignatureMismatch:
      return @"DFUErrorRemoteSecureDFUSignatureMismatch";
    case DFUErrorRemoteSecureDFUOpCodeNotSupported:
      return @"DFUErrorRemoteSecureDFUOpCodeNotSupported";
    case DFUErrorRemoteButtonlessDFUOperationFailed:
      return @"DFUErrorRemoteButtonlessDFUOperationFailed";
    case DFUErrorRemoteSecureDFUInsufficientResources:
      return @"DFUErrorRemoteSecureDFUInsufficientResources";
    case DFUErrorRemoteSecureDFUOperationNotPermitted:
      return @"DFUErrorRemoteSecureDFUOperationNotPermitted";
    case DFUErrorRemoteButtonlessDFUOpCodeNotSupported:
      return @"DFUErrorRemoteButtonlessDFUOpCodeNotSupported";
    case DFUErrorRemoteExperimentalButtonlessDFUSuccess:
      return @"DFUErrorRemoteExperimentalButtonlessDFUSuccess";
    case DFUErrorRemoteExperimentalButtonlessDFUOperationFailed:
      return @"DFUErrorRemoteExperimentalButtonlessDFUOperationFailed";
    case DFUErrorRemoteExperimentalButtonlessDFUOpCodeNotSupported:
      return @"DFUErrorRemoteExperimentalButtonlessDFUOpCodeNotSupported";
    default:
      return @"UNKNOWN_ERROR";
  }
}

- (void)dfuStateDidChangeTo:(enum DFUState)state
{
  NSDictionary * evtBody = @{@"deviceAddress": self.deviceAddress,
                             @"state": [self stateDescription:state],};

  [self sendEventWithName:DFUStateChangedEvent body:evtBody];

  if (state == DFUStateCompleted) {
    if (onDFUComplete) {
      onDFUComplete();
    }
    NSDictionary * resolveBody = @{@"deviceAddress": self.deviceAddress,};

    self.resolve(resolveBody);
  }
}

- (void)   dfuError:(enum DFUError)error
didOccurWithMessage:(NSString * _Nonnull)message
{
  if (onDFUError) {
    onDFUError();
  }

  NSDictionary * evtBody = @{@"deviceAddress": self.deviceAddress,
                             @"state": @"DFU_FAILED",};

  [self sendEventWithName:DFUStateChangedEvent body:evtBody];

  self.reject([self errorDescription:error], message, nil);
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

  [self sendEventWithName:DFUProgressEvent body:evtBody];
}

- (void)logWith:(enum LogLevel)level message:(NSString * _Nonnull)message
{
  NSLog(@"logWith: %ld message: '%@'", (long)level, message);
}

RCT_EXPORT_METHOD(startDFU:(NSString *)deviceAddress
                  deviceName:(NSString *)deviceName
                  filePath:(NSString *)filePath
                  alternativeAdvertisingNameEnabled:(BOOL *)alternativeAdvertisingNameEnabled
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  self.deviceAddress = deviceAddress;
  self.resolve = resolve;
  self.reject = reject;

  if (!getCentralManager) {
    reject(@"nil_central_manager_getter", @"Attempted to start DFU without central manager getter", nil);
  } else {
    CBCentralManager * centralManager = getCentralManager();

    if (!centralManager) {
      reject(@"nil_central_manager", @"Call to getCentralManager returned nil", nil);
    } else if (!deviceAddress) {
      reject(@"nil_device_address", @"Attempted to start DFU with nil deviceAddress", nil);
    } else if (!filePath) {
      reject(@"nil_file_path", @"Attempted to start DFU with nil filePath", nil);
    } else {
      NSUUID * uuid = [[NSUUID alloc] initWithUUIDString:deviceAddress];

      NSArray<CBPeripheral *> * peripherals = [centralManager retrievePeripheralsWithIdentifiers:@[uuid]];

      if ([peripherals count] != 1) {
        reject(@"unable_to_find_device", @"Could not find device with deviceAddress", nil);
      } else {
        CBPeripheral * peripheral = [peripherals objectAtIndex:0];

        NSURL * url = [NSURL URLWithString:filePath];

        DFUFirmware * firmware = [[DFUFirmware alloc] initWithUrlToZipFile:url];

        DFUServiceInitiator * initiator = [[[DFUServiceInitiator alloc]
                                            initWithCentralManager:centralManager
                                            target:peripheral]
                                           withFirmware:firmware];

        initiator.logger = self;
        initiator.delegate = self;
        initiator.progressDelegate = self;
        initiator.alternativeAdvertisingNameEnabled = alternativeAdvertisingNameEnabled;

        DFUServiceController * controller = [initiator start];
      }
    }
  }
}

+ (void)setCentralManagerGetter:(CBCentralManager * (^)())getter
{
  getCentralManager = getter;
}

+ (void)setOnDFUComplete:(void (^)())onComplete
{
  onDFUComplete = onComplete;
}

+ (void)setOnDFUError:(void (^)())onError
{
  onDFUError = onError;
}

@end
