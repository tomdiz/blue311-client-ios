//
//  B311Comment.m
//  blue311
//
//  Created by Thomas DiZoglio on 3/30/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import "B311Comment.h"

@implementation B311Comment

+ (instancetype) parse:(NSDictionary *)fields {
    
    NSLog(@"fields = %@", fields);
    B311Comment *comment = [B311Comment new];
    
    comment.id = fields[@"_id"];

    comment.user_handle = fields[@"user_handle"];

    comment.location_id = fields[@"location_id"];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    comment.created = [dateFormat dateFromString:fields[@"created"]];
    
    comment.subject = fields[@"subject"];
    comment.body = fields[@"body"];

    comment.rating_down = [fields[@"rating_down"] intValue];
    comment.rating_up = [fields[@"rating_up"] intValue];

    return comment;
}

@end
