
# react-native-nordic-dfu

## Getting started

`$ npm install react-native-nordic-dfu --save`

### Mostly automatic installation

`$ react-native link react-native-nordic-dfu`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-nordic-dfu` and add `RNNordicDfu.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNNordicDfu.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.pilloxa.RNNordicDfuPackage;` to the imports at the top of the file
  - Add `new RNNordicDfuPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-nordic-dfu'
  	project(':react-native-nordic-dfu').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-nordic-dfu/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-nordic-dfu')
  	```


## Usage
```javascript
import RNNordicDfu from 'react-native-nordic-dfu';

// TODO: What to do with the module?
RNNordicDfu;
```
  