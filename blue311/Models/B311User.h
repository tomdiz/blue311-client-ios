//
//  B311User.h
//  blue311
//
//  Created by Thomas DiZoglio on 4/1/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, B311UserType) {
    
    B311UserTypeBlue,
    B311UserTypeGreen
};

@interface B311User : NSObject <NSCoding>

@property (strong, nonatomic) NSString *id;         // (UDID) Sent back from the server - user already exists then get same ID back
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *handle;
@property (assign, nonatomic) B311UserType userType;
@property (assign, nonatomic) double signUpLatitude;
@property (assign, nonatomic) double signUpLongitude;

+ (B311User *) parse:(NSDictionary*)fields;

+ (NSString *)stringB311UserType:(B311UserType)type;
+ (B311UserType) b311UserTypeFromString:(NSString *)strType;

// NSCoding support
+ (B311User *)loadB311User;
+ (void)saveB311User:(B311User *)user;

+ (void)userCreateAccount:(NSString *)firstName withLastName:(NSString *)lastName withEmail:(NSString *)email withHandle:(NSString *)handle withUserType:(B311UserType)type withLat:(double)lat withLong:(double)lng completion:(void (^)(BOOL success, NSString *errorMessage))completion;

@end
