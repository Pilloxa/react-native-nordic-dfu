/**
 * An example project that downloads a zip file, connects to a device and then flashes
 * it.
 */

import React, { Component } from "react";
import {
  AppRegistry,
  TouchableHighlight,
  NativeModules,
  NativeEventEmitter,
  Platform,
  StyleSheet,
  Text,
  View,
  Image
} from "react-native";
import { NordicDFU, DFUEmitter } from "react-native-nordic-dfu";
import RNFetchBlob from "rn-fetch-blob";
import BleManager from "react-native-ble-manager";

const BleManagerModule = NativeModules.BleManager;
const bleManagerEmitter = new NativeEventEmitter(BleManagerModule);
const DEVICE_ID = "C3:53:A0:31:2F:14";

const FB = RNFetchBlob.config({
  fileCache: true,
  appendExt: "zip"
});

export default class NordicDFUExample extends Component {
  constructor(props) {
    super(props);
    this.handleDeviceDiscovered = this.handleDeviceDiscovered.bind(this);
    this.startScan = this.startScan.bind(this);
    this.handleStopScan = this.handleStopScan.bind(this);
    this.state = {
      imagefile: false,
      scanning: false,
      deviceFound: false,
      dfuState: "Not started",
      progress: 0
    };
  }

  componentDidMount() {
    DFUEmitter.addListener("DFUProgress", ({ percent }) => {
      console.log("DFU progress:", percent);
      this.setState({ progress: percent });
    });
    DFUEmitter.addListener("DFUStateChanged", ({ state }) => {
      console.log("DFU state:", state);
      this.setState({ dfuState: state });
    });

    FB.fetch("GET", "http://localhost:1234/app.zip").then(res => {
      console.log("file saved to", res.path());
      this.setState({ imagefile: res.path() });
    });

    BleManager.start({ showAlert: false, allowDuplicates: false });
    bleManagerEmitter.addListener("BleManagerStopScan", this.handleStopScan);
    bleManagerEmitter.addListener(
      "BleManagerDiscoverPeripheral",
      this.handleDeviceDiscovered
    );
    this.startScan();
  }

  // #### DFU #######################################################

  startDFU() {
    console.log("Starting DFU");
    NordicDFU.startDFU({
      deviceAddress: DEVICE_ID,
      name: "Pilloxa Board",
      filePath: this.state.imagefile
    })
      .then(res => console.log("Transfer done: ", res))
      .catch(console.log);
  }

  // #### BLUETOOTH #################################################

  handleDeviceDiscovered({ id }) {
    if (id == DEVICE_ID) {
      this.setState({
        deviceFound: true,
        scanning: false
      });
    }
  }

  handleStopScan() {
    console.log("Scan is stopped");
    if (this.state.scanning) {
      this.startScan();
    }
  }

  startScan() {
    BleManager.scan([], 3, true).then(results => {
      console.log("Scanning...");
      this.setState({ scanning: true });
    });
  }

  // #### RENDER #########################################################

  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          {this.state.dfuState}
        </Text>
        <Text style={styles.welcome}>
          {"DFU progress: " + this.state.progress + " %"}
        </Text>
        <Text>
          {this.state.scanning ? "Scanning for: " + DEVICE_ID : "Not scanning"}
        </Text>
        <Text>
          {this.state.deviceFound
            ? "Found device: " + DEVICE_ID
            : "Device not found"}
        </Text>
        <Text />
        {this.state.deviceFound
          ? <TouchableHighlight
              style={{ padding: 10, backgroundColor: "grey" }}
              onPress={this.startDFU.bind(this)}
            >
              <Text style={{ color: "white" }}>Start DFU</Text>
            </TouchableHighlight>
          : null}
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "#F5FCFF"
  },
  welcome: {
    fontSize: 20,
    textAlign: "center",
    margin: 10
  },
  instructions: {
    textAlign: "center",
    color: "#333333",
    marginBottom: 5
  }
});

AppRegistry.registerComponent("NordicDFUExample", () => NordicDFUExample);
