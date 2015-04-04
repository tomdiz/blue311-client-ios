//
//  geoFence.m
//  blue311
//
//  Created by Thomas DiZoglio on 4/3/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import "B311GeoFence.h"

const float kGeoFenceRadius = 0.03f;

@implementation B311GeoFence

+ (B311GeoFenceLocationType) b311MapDataLocationTypeFromString:(NSString *)strType {
    
    B311GeoFenceLocationType type = B311B311GeoFenceLocationTypeParking;
    if ([strType isEqualToString:@"ENTRANCE"]) {
        
        type = B311B311GeoFenceLocationTypeEntrance;
    } else if ([strType isEqualToString:@"GENERAL"]) {
        
        type = B311B311GeoFenceLocationTypeGeneral;
    }
    
    return type;
}

+ (NSString *)stringB311MapDataLocationType:(B311GeoFenceLocationType)type {
    
    NSString *typeString = nil;
    if (type == B311B311GeoFenceLocationTypeParking) {
        
        typeString = @"PARKING";
    } else if (type == B311B311GeoFenceLocationTypeEntrance) {
        
        typeString = @"ENTRANCE";
    } else if (type == B311B311GeoFenceLocationTypeGeneral) {
        
        typeString = @"GENERAL";
    }
    
    return typeString;
}

+ (instancetype) parse:(NSDictionary *)fields {
    
    NSLog(@"fields = %@", fields);
    B311GeoFence *geoFence = [B311GeoFence new];
    
    geoFence.id = fields[@"id"];
    geoFence.location_id = fields[@"location_id"];
    geoFence.information = fields[@"information"];
    geoFence.radius = [fields[@"radius"] floatValue];
    geoFence.latitude = [fields[@"latitude"] floatValue];
    geoFence.longitude = [fields[@"longitude"] floatValue];
    geoFence.ltype = [self b311MapDataLocationTypeFromString:fields[@"mtype"]];
    geoFence.isOccupied = [fields[@"occupied"] boolValue];

    CLLocationCoordinate2D coordinate;
    coordinate.latitude = geoFence.latitude;
    coordinate.longitude = geoFence.longitude;
    geoFence.region = [[CLCircularRegion alloc] initWithCenter:coordinate radius:geoFence.radius identifier:geoFence.id];

    return geoFence;
}

@end
