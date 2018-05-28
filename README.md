## Getting started

### Prerequisites

* React Native **0.49.5**
* Xcode 9.3 / Swift 4.1
* Android Studio 3.0+

### Installation

`npm install react-native-predict-io --save`


#### iOS

##### 1. Install Cocoapods

* Follow official [Cocoapods installation instructions](https://guides.cocoapods.org/using/getting-started.html)
* Run `pod init` inside the `ios` directory to initialize Cocoapods

##### 2. Add predict.io SDK dependency

* In `ios/Podfile`, add the following line above `# Add new pods below this line`:

  ```ruby
  eval(File.read('../node_modules/react-native-predict-io/ios/Podfile.template'))
  ```

* Run `pod install` in the `ios` directory to install

##### 3. Configure your app's permissions for location

* Follow the ['Configure Your Project' section of the iOS documentation](https://github.com/predict-io/PredictIO-iOS#configure-your-project) to make sure your app is setup correctly to be able to receive background location updates

##### 4. Fix iOS Project Settings (after `react-native link`)

React Native doesn't correctly install the native predict.io SDK so we need to fix some minor issues with the iOS project.

1. Open your `.xcworkspace` from the `ios` directory of your app, e.g. _Example.xcworkspace_
2. Inside the `Libraries` group in the project explorer, select and remove `RNPredictIO`

##### 5. Run your app normally with `react-native run-ios`

#### Android

##### 1. Open up `android/app/src/main/java/[...]/MainActivity.java`

- Add `import io.predict.android.sdk.react.RNPredictIOPackage;` to the imports at the top of the file
- Add `new RNPredictIOPackage()` to the list returned by the `getPackages()` method

##### 2. Append the following lines to `android/settings.gradle`:

 ```kotlin
 include ':react-native-predict-io'
 project(':react-native-predict-io').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-predict-io/android')
 ```

##### 3. Insert the following lines inside the dependencies block in `android/app/build.gradle`

```kotlin
compile project(':react-native-predict-io')
```

##### 4. Configure your app's permissions for location

* In `android/app/src/main/AndroidManifest.xml` add the following permissions tags inside `<application>`:

  ```xml
  <uses-permission android:name="android.permission.INTERNET" />
  <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
  <uses-permission android:name="com.google.android.gms.permission.ACTIVITY_RECOGNITION" />
  <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
  ```

##### 5. Add Kotlin support to `android/app/build.gradle`

* Add the followiing to the top of the file:

  ```kotlin
  buildscript {
      ext.kotlin_version = '1.2.40'
      repositories {
          jcenter()
      }
  
      dependencies {
          classpath 'com.android.tools.build:gradle:2.2.2'
          classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
      }
  }
  apply plugin: 'kotlin-android'
  ```


##### 6. Initialize the predict.io SDK

* Inside your `MainApplication.java` file inside the `android` directory of your app:

  * Find the `onCreate` method and add the following line to it:

    ```
    PredictIo.init(this)
    ```

    

### Usage

```javascript
import PredictIO from 'react-native-predict-io';

import {
    NativeEventEmitter,
    DeviceEventEmitter,
}

const PREDICT_IO_API_KEY = "<YOUR API KEY>";

async function startPredictIOSDK() {
  if (Platform.OS === "android") {
    const PermissionsAndroid = require('PermissionsAndroid');
    const status = await PermissionsAndroid.request(
      PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
    );

    console.log("Android Location Permission => " + status)
  }
  else if (Platform.OS === "ios") {
    const status = await navigator.geolocation.requestAuthorization()
    console.log("iOS Location Permission => " + status)
  }

  PredictIO.start(PREDICT_IO_API_KEY, "highPower", (status) => {
    console.log("PredictIO Error => " + status);

    switch (status) {
        case "success":
            console.log("SUCCESS => PredictIO SDK started successfully!");
        break;

        case "invalidKey":
            console.error("ERROR => PredictIO SDK API key is not valid!");
        break;

        case "killSwitch":
            console.error("ERROR => PredictIO SDK kill switch has been activated!");
        break;

        case "wifiDisabled":
            console.warn("WARNING => Wifi is disabled, negatively impacting location quality.");
        break;

        case "locationPermission":
            console.error("ERROR => Location permission has not been granted (Android)");
        break;

        case "locationPermissionNotDetermined":
            console.error("ERROR => Location permission: not yet determined (iOS)");
        break;

        case "locationPermissionWhenInUse":
            console.error("ERROR => Location permission: when in use (iOS)");
        break;

        case "locationPermissionRestricted":
            console.error("ERROR => Location permission: restricted (iOS)");
        break;

        case "locationPermissionDenied":
            console.error("ERROR => Location permission: denied (iOS)");
        break;
    }
  });
}

startPredictIOSDK();

// Listen for events

function handlePredictIOEvent(event) {
    	alert(`${event.type}\n${event.timestamp}\n${event.coordinate.latitude},${event.coordinate.longitude}`);
}

// Android Subscription
DeviceEventEmitter.addListener('PredictIOTripEvent', handlePredictIOEvent);

// iOS Subscription
const predictIOEventEmitter = new NativeEventEmitter(PredictIO);
const predictIOEventSubscription = predictIOEventEmitter.addListener('PredictIOTripEvent', handlePredictIOEvent);
```
