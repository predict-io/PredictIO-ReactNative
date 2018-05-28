//
//  RNPredictIO.h
//  RNPredictIO
//
//  Created by Kieran Graham on 22/04/2018.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "RCTBridgeModule.h"
#import "RCTEventEmitter.h"

@import PredictIO;

@interface RNPredictIO : RCTEventEmitter

- (NSDictionary *) constantsToExport;

@end
