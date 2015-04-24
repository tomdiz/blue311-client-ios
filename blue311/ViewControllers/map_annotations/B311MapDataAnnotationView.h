//
//  B311MapDataAnnotationView.h
//  blue311
//
//  Created by Thomas DiZoglio on 4/18/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "B311MapDataAnnotation.h"

@interface B311MapDataAnnotationView : MKAnnotationView

@property (strong, nonatomic) B311MapDataAnnotation *annotation_data;

@end
