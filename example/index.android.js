import React, { Component } from "react";
import {
  AppRegistry,
  TouchableHighlight,
  StyleSheet,
  Text,
  View,
  Image
} from "react-native";
import { NordicDFU, DFUEmitter } from "react-native-nordic-dfu";
import RNFetchBlob from "react-native-fetch-blob";
const FB = RNFetchBlob.config({
  fileCache: true,
  appendExt: "zip"
});

export default class NordicDFUExample extends Component {
  constructor(props) {
    super(props);
    this.state = {
      imagefile: false,
      dfuState: "Not started",
      progress: 0
    };
  }

  componentDidMount() {
    DFUEmitter.addListener("DFUProgress", progress => {
      console.log("DFU progress:", progress);
      this.setState({ progress: progress.percent });
    });
    DFUEmitter.addListener("DFUStateChanged", state => {
      console.log("DFU STATE:", state);
      this.setState({ dfuState: state.state });
    });
    FB.fetch("GET", "http://localhost:1234/app.zip").then(res => {
      console.log("file saved to", res.path());
      this.setState({ imagefile: res.path() });
    });
  }

  startDFU() {
    console.log("STarting DFU");
    NordicDFU.startDFU({
      deviceAddress: "C3:53:A0:31:2F:14",
      name: "Pilloxa Board",
      filePath: this.state.imagefile
    })
      .then(res => console.log("TRANSFERDONE:", res))
      .catch(console.log);
  }

  render() {
    console.log("FILE:" + this.state.imagefile);
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          {this.state.dfuState}
        </Text>
        <Text style={styles.welcome}>
          {this.state.progress + " %"}
        </Text>
        <TouchableHighlight
          style={{ padding: 10, backgroundColor: "grey" }}
          onPress={this.startDFU.bind(this)}
        >
          <Text style={{ color: "white" }}>Start DFU</Text>
        </TouchableHighlight>
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
