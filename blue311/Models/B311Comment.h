//
//  B311Comment.h
//  blue311
//
//  Created by Thomas DiZoglio on 3/30/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface B311Comment : NSObject

@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *user_handle;
@property (strong, nonatomic) NSString *b311MapDataLocationId;
@property (strong, nonatomic) NSDate *created;
@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSString *body;
@property (nonatomic) int rating_down;
@property (nonatomic) int rating_up;

+ (instancetype) parse:(NSDictionary *)fields;

@end
