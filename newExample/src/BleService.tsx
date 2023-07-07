import {
  EmitterSubscription,
  NativeEventEmitter,
  NativeModules,
} from 'react-native';
import BleManager, {Peripheral} from 'react-native-ble-manager';

const BleManagerModule = NativeModules.BleManager;
const bleManagerEmitter = new NativeEventEmitter(BleManagerModule);
let DFU_MODE_SERVICE = '',
  name = '';

const init = (deviceId: string, deviceName: string) => {
  BleManager.start({showAlert: true});
  DFU_MODE_SERVICE = deviceId;
  name = deviceName;
};

const scanAndConnectToDevice = () =>
  new Promise(async (resolve, reject) => {
    let scanEventListener: EmitterSubscription | undefined;

    scanEventListener = bleManagerEmitter.addListener(
      'BleManagerDiscoverPeripheral',
      async (peripheral: Peripheral) => {
        console.log('Scan -->', peripheral);
        if (peripheral.name === name) {
          BleManager.stopScan();
          const deviceConnected: Peripheral = await connectToDeviceId(
            peripheral,
          );
          resolve(deviceConnected);
        }
      },
    );
    try {
      await BleManager.scan([DFU_MODE_SERVICE], 15, false, {
        numberOfMatches: 1,
      });
    } catch (error) {
      scanEventListener?.remove();
      BleManager.stopScan();
      console.log(error);
      return reject(error);
    }
  });

const connectToDeviceId = async (device: Peripheral) => {
  try {
    // Connect to device
    await BleManager.connect(device.id);
    return device;
  } catch (error) {
    console.log(error);
    return Promise.reject(new Error('Connection Fail'));
  }
};

export const BleManagerService = {
  init,
  scanAndConnectToDevice,
  connectToDeviceId,
};
