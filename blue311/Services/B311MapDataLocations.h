//
//  B311MapDataLocations.h
//  blue311
//
//  Created by Thomas DiZoglio on 4/1/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import "B311MapDataLocation.h"

@interface B311MapDataLocations : NSObject

@property (strong, nonatomic) NSArray *mapLocations;

+ (B311MapDataLocations *)instance;

// Get all map locations at lat/long and radius
- (void)getMapLocations:(void (^)(BOOL success, NSArray *mapLocations, NSString *error))completion atLatitude:(double)lat atLongitude:(double)lng forRadius:(float)radius andWithHUD:(MBProgressHUD *)hud;

// NOTE: This will work by the user pressing button, get current location, call google and get info about site and populate the data. Call this new
// and then re-download form back-end to get new annoation

- (void)newMapLocation:(void (^)(NSString *error))completion atLatitude:(double)lat atLongitude:(double)lng withData:(B311MapDataLocation *)data andWithHUD:(MBProgressHUD *)hud;

- (void)updateMapLocation:(void (^)(NSString *error))completion withData:(B311MapDataLocation *)data andWithHUD:(MBProgressHUD *)hud;

@end
