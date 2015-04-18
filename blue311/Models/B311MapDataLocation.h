//
//  B311MapData.h
//  blue311
//
//  Created by Thomas DiZoglio on 03/30/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, B311MapDataLocationType) {
    
    B311MapDataLocationTypeParkingRampNone,
    B311MapDataLocationTypeParkingRampLeft,
    B311MapDataLocationTypeParkingRampRight,
    B311MapDataLocationTypeEntrance,
    B311MapDataLocationTypeGeneral
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
@property (nonatomic) int inUse;                    // 1 == full, 0 == empty

// NOTE: Here is data get from Google reverve address lookup - Should put this in our object
/*
 @property (nonatomic, readonly, copy) NSDictionary *addressDictionary;
 
 // address dictionary properties
 @property (nonatomic, readonly, copy) NSString *name; // eg. Apple Inc.
 @property (nonatomic, readonly, copy) NSString *thoroughfare; // street address, eg. 1 Infinite Loop
 @property (nonatomic, readonly, copy) NSString *subThoroughfare; // eg. 1
 @property (nonatomic, readonly, copy) NSString *locality; // city, eg. Cupertino
 @property (nonatomic, readonly, copy) NSString *subLocality; // neighborhood, common name, eg. Mission District
 @property (nonatomic, readonly, copy) NSString *administrativeArea; // state, eg. CA
 @property (nonatomic, readonly, copy) NSString *subAdministrativeArea; // county, eg. Santa Clara
 @property (nonatomic, readonly, copy) NSString *postalCode; // zip code, eg. 95014
 @property (nonatomic, readonly, copy) NSString *ISOcountryCode; // eg. US
 @property (nonatomic, readonly, copy) NSString *country; // eg. United States
 @property (nonatomic, readonly, copy) NSString *inlandWater; // eg. Lake Tahoe
 @property (nonatomic, readonly, copy) NSString *ocean; // eg. Pacific Ocean
 @property (nonatomic, readonly, copy) NSArray *areasOfInterest; // eg. Golden Gate Park
*/

+ (B311MapDataLocationType) b311MapDataLocationTypeFromString:(NSString *)strType;
+ (NSString *)stringB311MapDataLocationType:(B311MapDataLocationType)type;
+ (instancetype) parse:(NSDictionary *)fields;

@end
