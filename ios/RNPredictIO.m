//
//  RNPredictIO.m
//  RNPredictIO
//
//  Created by Kieran Graham on 22/04/2018.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "RNPredictIO.h"

#define TRIP_EVENT @"PredictIOTripEvent"

@import CoreLocation;

@implementation RNPredictIO

RCT_EXPORT_MODULE(PredictIO);

+ (BOOL) requiresMainQueueSetup {
  return YES;
}

- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}

- (NSArray<NSString *> *)supportedEvents {
  return @[TRIP_EVENT];
}

RCT_EXPORT_METHOD(start: (NSString *) apiKey
                  powerLevel: (NSString* ) powerLevel
                  callback: (RCTResponseSenderBlock) callback) {

  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    PredictIOPowerLevel _powerLevel = PredictIOPowerLevelLowPower;

    if ([powerLevel isEqualToString:@"highPower"]) {
      _powerLevel = PredictIOPowerLevelHighPower;
    }

    [PredictIO startWithApiKey:apiKey powerLevel:_powerLevel callback:^(PredictIOError error) {
      NSString *jsError = @"unknownError";

      switch (error) {
        case PredictIOErrorSuccess:                          jsError = @"success"; break;
        case PredictIOErrorInvalidKey:                       jsError = @"invalidKey"; break;
        case PredictIOErrorKillSwitch:                       jsError = @"killSwitch"; break;
        case PredictIOErrorWifiDisabled:                     jsError = @"wifiDisabled"; break;
        case PredictIOErrorLocationPermissionNotDetermined:  jsError = @"locationPermissionNotDetermined"; break;
        case PredictIOErrorLocationPermissionRestricted:     jsError = @"locationPermissionRestricted"; break;
        case PredictIOErrorLocationPermissionDenied:         jsError = @"locationPermissionDenied"; break;
        case PredictIOErrorLocationPermissionWhenInUse:      jsError = @"locationPermissionWhenInUse"; break;
      }

      callback(@[ jsError ]);
    }];

    [PredictIO notifyOn:PredictIOTripEventTypeAny callback:^(PredictIOTripEvent* event) {
      NSString *jsType = @"";

      switch (event.type) {
        case PredictIOTripEventTypeAny:         jsType = @"any";        break;
        case PredictIOTripEventTypeArrival:     jsType = @"arrival";    break;
        case PredictIOTripEventTypeDeparture:   jsType = @"departure";  break;
        case PredictIOTripEventTypeStill:       jsType = @"still";      break;
        case PredictIOTripEventTypeEnroute:     jsType = @"enroute";    break;
      }

      NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
      dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";

      NSString *jsTimestamp = [dateFormatter stringFromDate:event.timestamp];

      NSDictionary *jsEvent =
      @{
        @"type": jsType,
        @"timestamp": jsTimestamp,
        @"coordinate": @{
            @"latitude": @(event.coordinate.latitude),
            @"longitude": @(event.coordinate.longitude)
            }
        };

      if (self.bridge != nil) {
        [self sendEventWithName:TRIP_EVENT body:jsEvent];
      }
    }];
  });
}

RCT_EXPORT_METHOD(setWebhookURL: (NSString *) webhookURL) {
  [PredictIO setWebhookURL :webhookURL];
}

RCT_EXPORT_METHOD(setCustomParameter: (NSString *) key
                  value: (id) value) {
  [PredictIO setCustomParameterWithKey:key value:value];
}

- (NSDictionary *) constantsToExport {
  return @{
           @"versionNumber": PredictIO.versionNumber,
           @"buildNumber": @(PredictIO.buildNumber),
           };
}

@end
