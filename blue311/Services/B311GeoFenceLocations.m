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

- (void)getGeofenceLocations:(void (^)(BOOL success, NSArray *geFenceLocations, NSString *error))completion atLatitude:(double)lat atLongitude:(double)lng forRadius:(float)radius andWithHUD:(MBProgressHUD *)hud {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [hud setProgress:45.00/360.00];
        
        NSString *path = [NSString stringWithFormat:@"%@://%@%@geofences/", B311Data.kapi_protocol, B311Data.kapi_domain, B311Data.kAPIVersion];
        
        NSLog(@"Path: %@", path);
        
        NSMutableDictionary *params  = [NSMutableDictionary new];
        [params setValue:[NSNumber numberWithDouble:lat] forKey:@"latitude"];
        [params setValue:[NSNumber numberWithDouble:lng] forKey:@"longitude"];
        [params setValue:[NSNumber numberWithFloat:radius] forKey:@"radius"];
        
        NSDictionary *result;
        @try {
            
            result = [B311Data dictionaryWithContentsOfURL:[NSURL URLWithString:path] methodName:@"GET" stringParameters:params];
        }
        @catch (NSException *exception) {
            
            NSLog(@"Downloading map locations failed with error = %@", exception.description);
            // Complete
            dispatch_async(dispatch_get_main_queue(), ^{
                
                completion(NO, nil, @"Downloading Map Locations Failed");
            });
            return;
        }
        
        NSLog(@"results: %@", result);
        
        [hud setProgress:180.00/360.00];
        
        // Check for error first
        NSString *err = [result objectForKey:@"error"];
        if (err != nil) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                completion(NO, nil, err);
            });
            return;
        }
        
        int msgCount = [[result objectForKey:@"count"] intValue];
        int offsetMsgsToSync = msgCount;
        
        NSMutableArray *newGeoFenceLocations = [NSMutableArray new];
        NSArray *geoFences = [result objectForKey:@"geoFences"];
        for (NSDictionary *geoFencesJson in geoFences) {
            
            NSLog(@"geoFencesJson = %@", geoFencesJson);
            
            B311GeoFence *geoFence = [B311GeoFence parse:geoFencesJson];
            [newGeoFenceLocations addObject:geoFence];
            
            offsetMsgsToSync--;
            [hud setProgress:((msgCount - offsetMsgsToSync) / (float) msgCount)];
        }
        
        _geoFenceLocations = [newGeoFenceLocations copy];
        
        // Complete
        dispatch_async(dispatch_get_main_queue(), ^{
            
            completion(YES, [newGeoFenceLocations copy], nil);
        });
    });
}

- (void)newGeofenceLocation:(void (^)(NSString *error))completion withGeoFence:(B311GeoFence *)geo_fence andWithHUD:(MBProgressHUD *)hud {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *path = [NSString stringWithFormat:@"%@://%@%@geofence_new", B311Data.kapi_protocol, B311Data.kapi_domain, B311Data.kAPIVersion];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{ @"latitude": [NSNumber numberWithDouble:geo_fence.latitude], @"longitude": [NSNumber numberWithDouble:geo_fence.longitude], @"information":geo_fence.information, @"radius": [NSNumber numberWithDouble:geo_fence.radius], @"ltype":[B311GeoFence stringB311MapDataLocationType:geo_fence.ltype], @"location_id":geo_fence.location_id }];
        
        @try {
            
            NSData *data = [B311Data dataWithContentsOfURL:[NSURL URLWithString:path] methodName:@"POST" stringParameters:params];
            
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
                
                // return nil on successful POST
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

- (void)enteredGeoFenceLocation:(void (^)(NSString *error))completion atLocationId:(NSString *)location_id andWithHUD:(MBProgressHUD *)hud {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *path = [NSString stringWithFormat:@"%@://%@%@geofence_enter", B311Data.kapi_protocol, B311Data.kapi_domain, B311Data.kAPIVersion];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{ @"location_id": location_id }];
        
        @try {
            
            NSData *data = [B311Data dataWithContentsOfURL:[NSURL URLWithString:path] methodName:@"POST" stringParameters:params];
            
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
                
                // return nil on successful POST
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
        
        NSString *path = [NSString stringWithFormat:@"%@://%@%@geofence_exit", B311Data.kapi_protocol, B311Data.kapi_domain, B311Data.kAPIVersion];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{ @"location_id": location_id }];
        
        @try {
            
            NSData *data = [B311Data dataWithContentsOfURL:[NSURL URLWithString:path] methodName:@"POST" stringParameters:params];
            
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
                
                // return nil on successful POST
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

#pragma mark - Support selectors

- (B311GeoFence *)findGeoFenceForLocation:(NSString *)location_id {
    
    NSArray *results = [_geoFenceLocations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(id == %@)", location_id]];
    return results.count > 0 ? (B311GeoFence *)[results objectAtIndex:0] : nil;
}

@end
