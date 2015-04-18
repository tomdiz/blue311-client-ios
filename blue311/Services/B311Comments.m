//
//  B311Comments.h
//  blue311
//
//  Created by Thomas DiZoglio on 4/01/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import "B311Comments.h"
#import "B311Data.h"

@implementation B311Comments

+ (B311Comments *)instance {
    
    static B311Comments *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedClient = [B311Comments alloc];
    });
    
    return _sharedClient;
}

- (void)getComments:(void (^)(BOOL success, NSArray *location_comments, NSString *error))completion forLocationId:(NSString *)location_id andWithHUD:(MBProgressHUD *)hud {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [hud setProgress:45.00/360.00];
        
        NSString *path = [NSString stringWithFormat:@"%@://%@%@comments", B311Data.kapi_protocol, B311Data.kapi_domain, B311Data.kAPIVersion];
        
        NSLog(@"Path: %@", path);

        NSMutableDictionary *params  = [NSMutableDictionary new];
        [params setValue:location_id forKey:@"location_id"];

        NSDictionary *result;
        @try {
            
            result = [B311Data dictionaryWithContentsOfURL:[NSURL URLWithString:path] methodName:@"GET" stringParameters:params];
        }
        @catch (NSException *exception) {
            
            NSLog(@"Downloading comments failed with error = %@", exception.description);
            // Complete
            dispatch_async(dispatch_get_main_queue(), ^{
                
                completion(NO, nil, @"Downloading Comments Failed");
            });
            return;
        }
        
        NSLog(@"Comments: %@", result);

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
        
        NSMutableArray *newComments = [NSMutableArray new];
        NSArray *comments = [result objectForKey:@"Comments"];
        for (NSDictionary *commentJson in comments) {
            
            NSLog(@"msgJson = %@", commentJson);
            
            B311Comment *comment = [B311Comment parse:commentJson];
            [newComments addObject:comment];
            
            offsetMsgsToSync--;
            [hud setProgress:((msgCount - offsetMsgsToSync) / (float) msgCount)];
        }
        
        _userComments = [newComments copy];
        
        // Complete
        dispatch_async(dispatch_get_main_queue(), ^{
            
            completion(YES, [newComments copy], nil);
        });
    });
}

- (void)postComment:(void (^)(NSString *error))completion withComment:(B311Comment *)comment forUser:(B311User *)user forLocationId:(NSString *)location_id andWithHUD:(MBProgressHUD *)hud {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *path = [NSString stringWithFormat:@"%@://%@%@comments", B311Data.kapi_protocol, B311Data.kapi_domain, B311Data.kAPIVersion];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{ @"user_id": user.id, @"user_handle": user.handle, @"location_id": location_id, @"comment_subject":comment.subject, @"comment_body":comment.body }];

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

- (void)postCommentRatingUp:(void (^)(NSString *error))completion withCommentId:(NSString *)commentId forUser:(B311User *)user andWithHUD:(MBProgressHUD *)hud {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *path = [NSString stringWithFormat:@"%@://%@%@comments/%@", B311Data.kapi_protocol, B311Data.kapi_domain, B311Data.kAPIVersion, commentId];

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
                
                completion(@"Could not change comment rating at this time.  Please check your internet connection and try again.");
            });
        }
    });
}

- (void)postCommentRatingDown:(void (^)(NSString *error))completion withCommentId:(NSString *)commentId forUser:(B311User *)user andWithHUD:(MBProgressHUD *)hud {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *path = [NSString stringWithFormat:@"%@://%@%@comments/%@", B311Data.kapi_protocol, B311Data.kapi_domain, B311Data.kAPIVersion, commentId];
        
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
                
                completion(@"Could not change comment rating at this time.  Please check your internet connection and try again.");
            });
        }
    });
}

@end
