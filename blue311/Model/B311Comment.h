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
@property (strong, nonatomic) NSDate *created;
@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSString *body;

@end
