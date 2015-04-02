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
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *zip;
@property (assign, nonatomic) B311MapDataLocationType mtype;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

+ (B311MapDataLocationType) b311MapDataLocationTypeFromString:(NSString *)strType;
+ (NSString *)stringB311MapDataLocationType:(B311MapDataLocationType)type;
+ (instancetype) parse:(NSDictionary *)fields;

@end
