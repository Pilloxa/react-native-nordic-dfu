import React, {useEffect, useState} from 'react';
import {
  PermissionsAndroid,
  Platform,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import {BleManagerService} from './src/BleService';
import {Peripheral} from 'react-native-ble-manager';
import {NordicDFU, DFUEmitter} from 'react-native-nordic-dfu';
import ReactNativeBlobUtil from 'react-native-blob-util';
import RNFS from 'react-native-fs';

const styles = StyleSheet.create({
  container: {
    backgroundColor: 'white',
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  buttonContainer: {
    height: 40,
    width: 200,
    borderWidth: 1,
    borderRadius: 10,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 100,
    backgroundColor: '#F98234',
  },
  deviceContainer: {
    alignItems: 'center',
    justifyContent: 'space-evenly',
    height: 100,
    width: 200,
    borderWidth: 1,
    borderRadius: 10,
    marginTop: 200,
  },
  text: {
    color: 'black',
  },
});

const App: React.FC = () => {
  const [device, setDevice] = useState<Peripheral>();
  const [percentage, setPercentage] = useState(0);
  const filePath = '';

  useEffect(() => {
    PermissionsAndroid.requestMultiple([
      PermissionsAndroid.PERMISSIONS.BLUETOOTH_CONNECT,
      PermissionsAndroid.PERMISSIONS.BLUETOOTH_SCAN,
      PermissionsAndroid.PERMISSIONS.BLUETOOTH_ADVERTISE,
    ]);
    BleManagerService.init('', '');
  }, []);

  const onPressConnectDevice = async () => {
    try {
      const connectedDevice = await BleManagerService.scanAndConnectToDevice();
      console.log('Connected -->', connectedDevice);
      setDevice(connectedDevice as Peripheral);
    } catch (error) {
      return console.log(error);
    }
  };

  const uploadToDevice = async (filePath: string) => {
    if (!device) {
      return console.log('No Device');
    }

    const destination = `${RNFS.DocumentDirectoryPath}/installationFile.zip`;
    const exists = await RNFS.exists(destination);
    exists && (await RNFS.unlink(destination));
    const response = await ReactNativeBlobUtil.config({
      fileCache: true,
      appendExt: 'zip',
    }).fetch('GET', filePath);

    const downloadPath = response.path();
    await RNFS.copyFile(downloadPath, destination);
    response?.flush();

    DFUEmitter.addListener('DFUProgress', ({percent}) => {
      percent && setPercentage(percent);
    });
    return NordicDFU.startDFU({
      deviceAddress: device.id,
      deviceName: device.name,
      filePath: Platform.OS === 'ios' ? `file://${destination}` : destination,
    })
      .then(() => {
        console.log('Done');
      })
      .catch(err => {
        console.log('DFU', err);
        DFUEmitter.removeAllListeners('DFUProgress');
        return Promise.reject(err);
      });
  };

  return (
    <View style={styles.container}>
      <Text style={styles.text}>{'New Example Nordic DFU'}</Text>
      <View style={styles.deviceContainer}>
        <Text style={styles.text}>{device?.name}</Text>
        <Text style={styles.text}>{device?.id}</Text>
        <Text style={styles.text}>{percentage}</Text>
      </View>
      <TouchableOpacity
        style={styles.buttonContainer}
        onPress={onPressConnectDevice}>
        <Text>{'Connect to Device in Area'}</Text>
      </TouchableOpacity>
      <TouchableOpacity
        style={styles.buttonContainer}
        onPress={() => {
          uploadToDevice(filePath);
        }}>
        <Text>{'Start Update'}</Text>
      </TouchableOpacity>
    </View>
  );
};

export default App;
