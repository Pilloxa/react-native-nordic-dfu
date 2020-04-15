import { NativeModules, NativeEventEmitter, Platform } from "react-native";
const { RNNordicDfu } = NativeModules;
const NordicDFU = { startDFU };

function rejectPromise(message) {
  return new Promise((resolve, reject) => {
    reject(new Error("NordicDFU.startDFU: " + message));
  });
}

/**
 *
 * Starts the DFU process
 *
 * Observe: The peripheral must have been discovered by the native BLE side so that the
 * bluetooth stack knows about it. This library will not do a scan but only
 * the actual connect and then the transfer. See the example project to see how it can be
 * done in React Native.
 *
 * For `alternativeAdvertisingNameEnabled` option below, see:
 * https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/blob/master/iOSDFULibrary/Classes/Implementation/DFUServiceInitiator.swift#L191
 *
 * @param {Object} obj
 * @param {string} obj.deviceAddress The MAC address for the device that should be updated
 * @param {string} [obj.deviceName = null] The name of the device in the update notification
 * @param {string} obj.filePath The file system path to the zip-file used for updating
 * @param {Boolean} obj.alternativeAdvertisingNameEnabled Send unique name to device before it is switched into bootloader mode (iOS only)
 * @returns {Promise} A promise that resolves or rejects with the `deviceAddress` in the return value
 *
 * @example
 * import { NordicDFU, DFUEmitter } from "react-native-nordic-dfu";
 *
 * NordicDFU.startDFU({
 *   deviceAddress: "C3:53:C0:39:2F:99",
 *   deviceName: "Pilloxa Pillbox",
 *   filePath: "/data/user/0/com.nordicdfuexample/files/RNFetchBlobTmp4of.zip"
 * })
 *   .then(res => console.log("Transfer done:", res))
 *   .catch(console.log);
 */
function startDFU({
  deviceAddress,
  deviceName = null,
  filePath,
  alternativeAdvertisingNameEnabled = true
}) {
  if (deviceAddress == undefined) {
    return rejectPromise("No deviceAddress defined");
  }
  if (filePath == undefined) {
    return rejectPromise("No filePath defined");
  }
  const upperDeviceAddress = deviceAddress.toUpperCase();
  if (Platform.OS === 'ios') {
    return RNNordicDfu.startDFU(upperDeviceAddress, deviceName, filePath, alternativeAdvertisingNameEnabled);
  }
  return RNNordicDfu.startDFU(upperDeviceAddress, deviceName, filePath);
}

/**
 * Event emitter for DFU state and progress events
 *
 * @const DFUEmitter
 *
 * @example
 * import { NordicDFU, DFUEmitter } from "react-native-nordic-dfu";
 *
 * DFUEmitter.addlistener("DFUProgress",({percent, currentPart, partsTotal, avgSpeed, speed}) => {
 *   console.log("DFU progress: " + percent +"%");
 * });
 *
 * DFUEmitter.addListener("DFUStateChanged", ({state}) => {
 *   console.log("DFU State:", state);
 * })
 */
const DFUEmitter = new NativeEventEmitter(RNNordicDfu);

export { NordicDFU, DFUEmitter };
