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

@property (strong, nonatomic) NSMutableArray *geoFenceLocations;

+ (B311GeoFenceLocations *)instance;

- (void)getGeofenceLocations:(void (^)(BOOL success, NSArray *geFenceLocations, NSString *error))completion atLatitude:(double)lat atLongitude:(double)lng forRadius:(float)radius andWithHUD:(MBProgressHUD *)hud;

- (void)newGeofenceLocation:(void (^)(NSString *error))completion withGeoFence:(B311GeoFence *)geo_fence andWithHUD:(MBProgressHUD *)hud;

- (void)enteredGeoFenceLocation:(void (^)(NSString *error))completion atLocationId:(NSString *)location_id andWithHUD:(MBProgressHUD *)hud;

- (void)exitedGeoFenceLocation:(void (^)(NSString *error))completion atLocationId:(NSString *)location_id andWithHUD:(MBProgressHUD *)hud;

// Support selectors

- (B311GeoFence *)findGeoFenceForLocation:(NSString *)location_id;

@end
