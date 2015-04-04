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

typedef NS_ENUM(NSInteger, B311GeoFenceLocationType) {
    
    B311B311GeoFenceLocationTypeParking,
    B311B311GeoFenceLocationTypeEntrance,
    B311B311GeoFenceLocationTypeGeneral
};

@interface B311GeoFence : NSObject

@property (strong, nonatomic) NSString *id;                 // UUID generated on backend
@property (strong, nonatomic) NSString *location_id;
@property (strong, nonatomic) CLCircularRegion *region;
@property (strong, nonatomic) NSString *information;        // Show this string when entering the geoFence region
@property (nonatomic) float radius;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (assign, nonatomic) B311GeoFenceLocationType ltype;
@property (nonatomic) BOOL isOccupied;

// CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:[location coordinate] radius:250.0 identifier:[[NSUUID UUID] UUIDString]];

+ (B311GeoFenceLocationType) b311MapDataLocationTypeFromString:(NSString *)strType;
+ (NSString *)stringB311MapDataLocationType:(B311GeoFenceLocationType)type;

+ (instancetype) parse:(NSDictionary *)fields;

@end
