//
//  B311User.m
//  blue311
//
//  Created by Thomas DiZoglio on 4/1/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import "B311User.h"
#import "B311Data.h"

@implementation B311User

+ (B311User *) parse:(NSDictionary *)fields {
    
    B311User *user = [B311User new];
    user.firstName = [fields valueForKey:@"first_name"];
    user.lastName = [fields valueForKey:@"lasst_name"];
    user.email = [fields valueForKey:@"email"];
    user.handle = [fields valueForKey:@"handle"];
    user.signUpLatitude = [[fields valueForKey:@"latitude"] doubleValue];
    user.signUpLongitude = [[fields valueForKey:@"longitude"] doubleValue];

    return user;
}

+ (NSString *)stringB311UserType:(B311UserType)type {

    NSString *typeString = nil;
    if (type == B311UserTypeBlue) {
        
        typeString = @"BLUE";
    } else {
        
        typeString = @"GREEN";
    }
    return typeString;
}

+ (B311UserType) b311UserTypeFromString:(NSString *)strType {

    B311UserType type = B311UserTypeBlue;
    if ([strType isEqualToString:@"GREEN"]) {

        type = B311UserTypeGreen;
    }
    return type;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super init];
    if (!self) {
        
        return nil;
    }
    
    self.id = [decoder decodeObjectForKey:@"user_id"];
    self.firstName = [decoder decodeObjectForKey:@"firstName"];
    self.lastName = [decoder decodeObjectForKey:@"lastName"];
    self.email = [decoder decodeObjectForKey:@"email"];
    self.handle = [decoder decodeObjectForKey:@"handle"];
    self.signUpLatitude = [decoder decodeDoubleForKey:@"latitude"];
    self.signUpLongitude = [decoder decodeDoubleForKey:@"longitude"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:self.id forKey:@"user_id"];
    [encoder encodeObject:self.firstName forKey:@"firstName"];
    [encoder encodeObject:self.lastName forKey:@"lastName"];
    [encoder encodeObject:self.email forKey:@"email"];
    [encoder encodeObject:self.handle forKey:@"handle"];
    [encoder encodeDouble:self.signUpLatitude forKey:@"latitude"];
    [encoder encodeDouble:self.signUpLongitude forKey:@"longitude"];
}

+ (B311User *)loadB311User {
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"b311User"];
    B311User *user = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return user;
}

+ (void)saveB311User:(B311User *)user {
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:user];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"b311User"];
}

#pragma mark - Networking with Backend

+ (void)userCreateAccount:(NSString *)firstName withLastName:(NSString *)lastName withEmail:(NSString *)email withHandle:(NSString *)handle withUserType:(B311UserType)type withLat:(double)lat withLong:(double)lng completion:(void (^)(BOOL success, NSString *errorMessage))completion {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *path = [NSString stringWithFormat:@"%@://%@%@profile", B311Data.kapi_protocol, B311Data.kapi_domain, B311Data.kAPIVersion];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{ @"first_name": firstName, @"last_name": lastName, @"email": email, @"handle":handle }];
        
        if (type == B311UserTypeBlue) {
            
            [params setObject:@"BLUE" forKey:@"user_type"];
        }
        else {
            
            [params setObject:@"GREEN" forKey:@"user_type"];
        }
        if (lat != 0) {
            [params setObject:@(lat) forKey:@"latitude"];
        }
        if (lng != 0) {
            [params setObject:@(lng) forKey:@"longitude"];
        }
        
        @try {
            
            NSData *data = [B311Data dataWithContentsOfURL:[NSURL URLWithString:path] methodName:@"POST" stringParameters:params];
            
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:nil];
            
            NSLog(@"results = %@", results);
            
            NSString *errorMessage = [results objectForKey:@"error"];
            if (errorMessage != nil) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSString *errorDescription = [results objectForKey:@"error_description"];
                    completion(NO, errorDescription);
                });
                
                return;
            }
            else {
                
                // Success - store of user info
                B311User *user = [B311User new];
                user.id = [results objectForKey:@"user_id"];
                user.firstName = firstName;
                user.lastName = lastName;
                user.email = email;
                user.handle = handle;
                user.signUpLongitude = lng;
                user.signUpLatitude = lat;
                [self saveB311User:user];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    completion(YES, nil);
                });
            }
        }
        @catch (NSException *exception) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                completion(NO, @"Could not create account at this time.  Please check your internet connection and try again.");
            });
        }
    });
}

@end
