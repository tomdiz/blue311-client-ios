//
//  B311MapData.m
//  blue311
//
//  Created by Thomas DiZoglio on 03/30/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import "B311MapDataLocation.h"

@implementation B311MapDataLocation

+ (NSString *)stringB311MapDataLocationType:(B311MapDataLocationType)type {
    
    NSString *typeString = nil;
    if (type == B311MapDataLocationTypeGeneral) {
        
        typeString = @"GENERAL";
    } else if (type == B311MapDataLocationTypeEntrance) {
        
        typeString = @"ENTRANCE";
    } else if (type == B311MapDataLocationTypeParkingRampNone) {
        
        typeString = @"PARKING_NONE";
    } else if (type == B311MapDataLocationTypeParkingRampLeft) {
        
        typeString = @"PARKING_LEFT";
    } else if (type == B311MapDataLocationTypeParkingRampRight) {
        
        typeString = @"PARKING_RIGHT";
    } 
 
    return typeString;
}

+ (B311MapDataLocationType) b311MapDataLocationTypeFromString:(NSString *)strType {
    
    B311MapDataLocationType type = B311MapDataLocationTypeGeneral;
    if ([strType isEqualToString:@"ENTRANCE"]) {
        
        type = B311MapDataLocationTypeEntrance;
    } else if ([strType isEqualToString:@"PARKING_NONE"]) {
        
        type = B311MapDataLocationTypeParkingRampNone;
    } else if ([strType isEqualToString:@"PARKING_LEFT"]) {
        
        type = B311MapDataLocationTypeParkingRampLeft;
    } else if ([strType isEqualToString:@"PARKING_RIGHT"]) {
        
        type = B311MapDataLocationTypeParkingRampRight;
    }

    return type;
}

+ (instancetype) parse:(NSDictionary *)fields {

    NSLog(@"fields = %@", fields);
    B311MapDataLocation *location = [B311MapDataLocation new];
    
    location.id = fields[@"_id"];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    location.created = [dateFormat dateFromString:fields[@"created"]];
    location.title = fields[@"title"];
    location.address = fields[@"address"];
    location.city = fields[@"city"];
    location.state = fields[@"state"];
    location.zip = fields[@"zip"];
    location.mtype = [self b311MapDataLocationTypeFromString:fields[@"mtype"]];
    location.latitude = [fields[@"latitude"] doubleValue];
    location.longitude = [fields[@"longitude"] doubleValue];
    location.inUse = [fields[@"inUse"] intValue];

    return location;
}

@end
