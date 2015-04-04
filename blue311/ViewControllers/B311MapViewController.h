//
//  O311MapViewController.h
//  blue311
//
//  Created by Thomas DiZoglio on 3/23/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDSideBarController.h"

@interface B311MapViewController : UIViewController <CDSideBarControllerDelegate, CLLocationManagerDelegate> {
    
    CDSideBarController *sideBar;
}

@property (strong, nonatomic) CLLocationManager *locationManager;

@end
