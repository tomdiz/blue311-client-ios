//
//  B311ParkingGeoFence.m
//  blue311
//
//  Created by Thomas DiZoglio on 4/3/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import "B311GeoFenceLocations.h"
#import "B311Data.h"
#import "B311GeoFence.h"

@implementation B311GeoFenceLocations

+ (B311GeoFenceLocations *)instance {
    
    static B311GeoFenceLocations *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedClient = [B311GeoFenceLocations alloc];
    });
    
    return _sharedClient;
}

#pragma mark - GeoFencing Network calls

- (void)enteredGeoFenceLocation:(void (^)(NSString *error))completion atLocationId:(NSString *)location_id andWithHUD:(MBProgressHUD *)hud {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *path = [NSString stringWithFormat:@"%@://%@%@maplocations/%@", B311Data.kapi_protocol, B311Data.kapi_domain, B311Data.kAPIVersion, location_id];
        
        @try {
            
            NSData *data = [B311Data dataWithContentsOfURL:[NSURL URLWithString:path] methodName:@"PUT" stringParameters:nil];
            
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:nil];
            
            NSLog(@"results = %@", results);
            
            NSString *errorMessage = [results objectForKey:@"error"];
            if (errorMessage != nil) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSString *errorDescription = [results objectForKey:@"error_description"];
                    completion(errorDescription);
                });
                
                return;
            }
            else {
                
                // return nil on successful PUT
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    completion(nil);
                });
            }
        }
        @catch (NSException *exception) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                completion(@"Could not post comment at this time.  Please check your internet connection and try again.");
            });
        }
    });
}


- (void)exitedGeoFenceLocation:(void (^)(NSString *error))completion atLocationId:(NSString *)location_id andWithHUD:(MBProgressHUD *)hud {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *path = [NSString stringWithFormat:@"%@://%@%@maplocations/%@", B311Data.kapi_protocol, B311Data.kapi_domain, B311Data.kAPIVersion, location_id];
        
        @try {
            
            NSData *data = [B311Data dataWithContentsOfURL:[NSURL URLWithString:path] methodName:@"DELETE" stringParameters:nil];
            
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:nil];
            
            NSLog(@"results = %@", results);
            
            NSString *errorMessage = [results objectForKey:@"error"];
            if (errorMessage != nil) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSString *errorDescription = [results objectForKey:@"error_description"];
                    completion(errorDescription);
                });
                
                return;
            }
            else {
                
                // return nil on successful DELETE
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    completion(nil);
                });
            }
        }
        @catch (NSException *exception) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                completion(@"Could not post comment at this time.  Please check your internet connection and try again.");
            });
        }
    });
}

@end
