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
    B311MapDataLocation *message = [B311MapDataLocation new];
    
    message.id = fields[@"id"];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    message.created = [dateFormat dateFromString:fields[@"created"]];

    message.subject = fields[@"subject"];
    message.body = fields[@"body"];
    message.threadId = fields[@"thread_id"];
    message.mtype = [self b311MapDataLocationTypeFromString:fields[@"mtype"]];
    message.is_read = [fields[@"is_read"] boolValue];
    message.is_archived = [fields[@"is_archived"] boolValue];
    message.listing_id = fields[@"listing_id"];
    message.booking_id = fields[@"booking_id"];
    
    NSDictionary *space_info = fields[@"space"];
    message.space_id = space_info[@"id"];
    NSDictionary *space_loc = space_info[@"loc"];
    message.space_lat = [space_loc[@"lat"] doubleValue];
    message.space_lng = [space_loc[@"lon"] doubleValue];

    return message;
}

@end
