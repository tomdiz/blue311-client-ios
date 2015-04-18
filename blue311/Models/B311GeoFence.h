//
//  geoFence.h
//  blue311
//
//  Created by Thomas DiZoglio on 4/3/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

extern const float kGeoFenceRadius;

@interface B311GeoFence : NSObject

@property (strong, nonatomic) NSString *location_id;
@property (strong, nonatomic) CLCircularRegion *region;

@end
