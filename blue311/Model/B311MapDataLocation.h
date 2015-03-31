//
//  B311MapData.h
//  blue311
//
//  Created by Thomas DiZoglio on 03/30/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, B311MapDataLocationType) {
    
    B311MapDataLocationTypeGeneral,
    B311MapDataLocationTypeEntrance,
    B311MapDataLocationTypeParkingRampNone,
    B311MapDataLocationTypeParkingRampLeft,
    B311MapDataLocationTypeParkingRampRight
};

@interface B311MapDataLocation : NSObject

@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSDate *created;
@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSString *threadId;
@property (assign, nonatomic) B311MapDataLocationType mtype;
@property (assign, nonatomic) BOOL is_read;
@property (assign, nonatomic) BOOL is_archived;
@property (strong, nonatomic) NSString *listing_id;
@property (strong, nonatomic) NSString *booking_id;

@property (strong, nonatomic) NSString *space_id;
@property (nonatomic) double space_lat;
@property (nonatomic) double space_lng;

+ (B311MapDataLocationType) b311MapDataLocationTypeFromString:(NSString *)strType;
+ (NSString *)stringB311MapDataLocationType:(B311MapDataLocationType)type;
+ (instancetype) parse:(NSDictionary *)fields;

@end
