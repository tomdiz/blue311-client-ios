//
//  B311GeneralMapAnnotation.h
//  blue311
//
//  Created by Thomas DiZoglio on 4/7/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MKAnnotation.h>
#import "B311MapDataLocation.h"

@interface B311MapDataAnnotation : NSObject <MKAnnotation>

@property (nonatomic) B311MapDataLocationType ltype;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;

@end
