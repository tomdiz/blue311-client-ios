//
//  B311DetailsViewController.h
//  blue311
//
//  Created by Thomas DiZoglio on 3/30/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "B311MapDataLocations.h"

@interface B311DetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) B311MapDataLocation *location_data;

@end
