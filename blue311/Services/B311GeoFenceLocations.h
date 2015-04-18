//
//  B311ParkingGeoFence.h
//  blue311
//
//  Created by Thomas DiZoglio on 4/3/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "MBProgressHUD.h"
#import "B311GeoFence.h"

@interface B311GeoFenceLocations : NSObject

+ (B311GeoFenceLocations *)instance;

- (void)enteredGeoFenceLocation:(void (^)(NSString *error))completion atLocationId:(NSString *)location_id andWithHUD:(MBProgressHUD *)hud;

- (void)exitedGeoFenceLocation:(void (^)(NSString *error))completion atLocationId:(NSString *)location_id andWithHUD:(MBProgressHUD *)hud;

@end
