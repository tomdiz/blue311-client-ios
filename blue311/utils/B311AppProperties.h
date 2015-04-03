//
//  B311AppProperties.h
//  blue311
//
//  Created by Thomas DiZoglio on 3/23/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface B311AppProperties : NSObject

+(B311AppProperties *) getInstance;

- (BOOL)getSideMenuState;
- (void)setSideMenuState:(BOOL)state;

- (float)getMapRadius;
- (void)setMapRadius:(float)radius;

@end
