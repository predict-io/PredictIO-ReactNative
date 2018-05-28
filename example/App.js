/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */
'use strict';

const PREDICT_IO_API_KEY = require('./predict-io-api-key.json').api_key;

import React, { Component } from 'react';
import {
  Platform,
  StyleSheet,
  Text,
  View,
  NativeEventEmitter,
  DeviceEventEmitter,
} from 'react-native';

const ReactNativeVersion = require('react-native/package.json').version;

import PredictIO from 'react-native-predict-io';

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

const instructions = Platform.select({
  ios: 'Press Cmd+R to reload,\n' +
    'Cmd+D or shake for dev menu',
  android: 'Double tap R on your keyboard to reload,\n' +
    'Shake or press menu button for dev menu',
});

type Props = {};
export default class App extends Component<Props> {
  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          Welcome to React Native!
        </Text>
        <Text style={styles.instructions}>
          To get started, edit App.js
        </Text>
        <Text style={styles.instructions}>
          {instructions}
        </Text>
        <Text>React: {React.version}</Text>
        <Text>React Native: {ReactNativeVersion}</Text>

        <Text>PredictIO: {PredictIO.versionNumber} ({PredictIO.buildNumber})</Text>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});
