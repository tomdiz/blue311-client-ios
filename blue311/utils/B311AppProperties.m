//
//  B311AppProperties.m
//  blue311
//
//  Created by Thomas DiZoglio on 3/23/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import "B311AppProperties.h"

@implementation B311AppProperties

static B311AppProperties * shared = nil;

+(B311AppProperties *) getInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (shared == nil) {
            
            shared = [B311AppProperties new];
        }
    });
    
    return shared;
}

-(id)init {
    
    self = [super init];
    if (self) {
        
        NSString *menuBarState = [[NSUserDefaults standardUserDefaults] objectForKey:@"sideMenuBarState"];
        if (menuBarState == nil) {
            
            [self initAppProperties];
        }
    }
    
    return self;
}

- (void) initAppProperties {
    
    [[NSUserDefaults standardUserDefaults] setObject:@"hide" forKey:@"sideMenuBarState"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) getSideMenuState {

    NSString *menuBarState = [[NSUserDefaults standardUserDefaults] objectForKey:@"sideMenuBarState"];
    if ([menuBarState isEqualToString:@"hide"]) {
        
        return NO;
    }
    else {
        
        return YES;
    }
}

- (void) setSideMenuState:(BOOL)state {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (state == NO) {
        
        [defaults setObject:@"hide" forKey:@"sideMenuBarState"];
    }
    else {
        
        [defaults setObject:@"show" forKey:@"sideMenuBarState"];
    }
    
    [defaults synchronize];
}

@end
