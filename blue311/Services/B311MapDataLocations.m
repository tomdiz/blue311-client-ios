//
//  B311MapDataLocations.m
//  blue311
//
//  Created by Thomas DiZoglio on 4/1/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import "B311MapDataLocations.h"
#import "B311Data.h"

@implementation B311MapDataLocations

+ (B311MapDataLocations *)instance {
    
    static B311MapDataLocations *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedClient = [B311MapDataLocations alloc];
    });
    
    return _sharedClient;
}

- (void)getMapLocations:(void (^)(BOOL success, NSArray *mapLocations, NSString *error))completion atLatitude:(double)lat atLongitude:(double)lng forRadius:(float)radius andWithHUD:(MBProgressHUD *)hud {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [hud setProgress:45.00/360.00];
        
        NSString *path = [NSString stringWithFormat:@"%@://%@%@maplocations/around", B311Data.kapi_protocol, B311Data.kapi_domain, B311Data.kAPIVersion];
        
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
        NSString *err = [result objectForKey:@"error_msg"];
        int status = [[result objectForKey:@"http_status"] intValue];
        if (err != nil) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSString *errorMessage = [NSString stringWithFormat:@"%@, http code = %d", err, status];
                completion(NO, nil, errorMessage);
            });
            return;
        }
        
        int msgCount = [[result objectForKey:@"count"] intValue];
        int offsetMsgsToSync = msgCount;
        
        NSMutableArray *newLocations = [NSMutableArray new];
        NSArray *locations = [result objectForKey:@"locations"];
        for (NSDictionary *locationJson in locations) {
            
            NSLog(@"locationJson = %@", locationJson);
            
            B311MapDataLocation *location = [B311MapDataLocation parse:locationJson];
            [newLocations addObject:location];
            
            offsetMsgsToSync--;
            [hud setProgress:((msgCount - offsetMsgsToSync) / (float) msgCount)];
        }
        
        _mapLocations = [newLocations copy];
        
        // Complete
        dispatch_async(dispatch_get_main_queue(), ^{
            
            completion(YES, [newLocations copy], nil);
        });
    });
}

- (void)newMapLocation:(void (^)(NSString *error))completion atLatitude:(double)lat atLongitude:(double)lng withData:(B311MapDataLocation *)data andWithHUD:(MBProgressHUD *)hud {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *path = [NSString stringWithFormat:@"%@://%@%@maplocations", B311Data.kapi_protocol, B311Data.kapi_domain, B311Data.kAPIVersion];

        if (data == nil) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                completion(@"B311MapDataLocation (withData:) is nil");
            });
            
            return;
        }
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{ @"title": data.title == nil ? @"" : data.title,
                                                                                       @"address": data.address == nil ? @"" : data.address,
                                                                                       @"city": data.city == nil ? @"" : data.city,
                                                                                       @"state":data.state == nil ? @"" : data.state,
                                                                                       @"zip":data.zip == nil ? @"" : data.zip,
                                                                                       @"location_type":[B311MapDataLocation stringB311MapDataLocationType:data.mtype],
                                                                                       @"loc": @[ [NSNumber numberWithDouble:lat], [NSNumber numberWithDouble:lng] ],
                                                                                       @"inUse": [NSNumber numberWithInt:1]
                                                                                       }];
//        @"latitude":[NSNumber numberWithDouble:lat],
//        @"longitude":[NSNumber numberWithDouble:lng]

        @try {
            
            NSData *data = [B311Data dataWithContentsOfURL:[NSURL URLWithString:path] methodName:@"POST" stringParameters:params];
            
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:nil];
            
            NSLog(@"results = %@", results);
            
            NSString *errorMessage = [results objectForKey:@"error"];
            if (errorMessage != nil && results != nil) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSString *errorDescription = [results objectForKey:@"error_description"];
                    completion(errorDescription);
                });
                
                return;
            }
            else {
                
                if (results == nil) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        completion(@"No results returned from server");
                    });
                    
                    return;
                }

                // return nil on successful POST
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    completion(nil);
                });
            }
        }
        @catch (NSException *exception) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                completion(@"Could not create map location data at this time.  Please check your internet connection and try again.");
            });
        }
    });
}

- (void)updateMapLocation:(void (^)(NSString *error))completion withData:(B311MapDataLocation *)data andWithHUD:(MBProgressHUD *)hud {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *path = [NSString stringWithFormat:@"%@://%@%@maplocations/update/%@", B311Data.kapi_protocol, B311Data.kapi_domain, B311Data.kAPIVersion, data.id];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{ @"title": data.title, @"address": data.address, @"city": data.city, @"state":data.state, @"zip":data.zip }];
        
        @try {
            
            NSData *data = [B311Data dataWithContentsOfURL:[NSURL URLWithString:path] methodName:@"PUT" stringParameters:params];
            
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
                
                completion(@"Could not update map location data at this time.  Please check your internet connection and try again.");
            });
        }
    });
}

@end
