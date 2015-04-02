//
//  B311Comments.h
//  blue311
//
//  Created by Thomas DiZoglio on 4/01/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import "B311Comment.h"
#import "B311User.h"


@interface B311Comments : NSObject

@property (strong, nonatomic) NSArray *userMessages;

+ (B311Comments *)instance;

// Get all comments for a location by Id
- (void)getComments:(void (^)(BOOL success, NSArray *location_comments, NSString *error))completion forLocationId:(NSString *)location_id andWithHUD:(MBProgressHUD *)hud;

// Post a new comment
- (void)postComment:(void (^)(NSString *error))completion withComment:(B311Comment *)comment forUser:(B311User *)user forLocationId:(NSString *)location_id andWithHUD:(MBProgressHUD *)hud;

// Comment ratings
- (void)postCommentRatingUp:(void (^)(NSString *error))completion withCommentId:(NSString *)commentId forUser:(B311User *)user andWithHUD:(MBProgressHUD *)hud;
- (void)postCommentRatingDown:(void (^)(NSString *error))completion withCommentId:(NSString *)commentId forUser:(B311User *)user andWithHUD:(MBProgressHUD *)hud;

@end
