//
//  O311MapViewController.m
//  blue311
//
//  Created by Thomas DiZoglio on 3/23/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <INTULocationManager/INTULocationManager.h>
#import <AddressBook/AddressBook.h>
#import "B311MapViewController.h"
#import "JVFloatingDrawerSpringAnimator.h"
#import "AppDelegate.h"
#import "TutorialPageContentViewController.h"
#import "B311MapDataLocations.h"
#import "B311AppProperties.h"
#import "B311GeoFenceLocations.h"
#import "B311MapDataAnnotation.h"
#import "B311DetailsViewController.h"

@interface B311MapViewController () <UIPageViewControllerDataSource> {
    
    NSArray *geoFences;
    NSMutableArray *currentGeoFences;
    NSArray *mapLocationData;
    NSMutableArray *mapLocationAnnotations;
    CLGeocoder *geocoder;
}

@property (nonatomic, strong, readonly) JVFloatingDrawerSpringAnimator *drawerAnimator;

@property (weak, nonatomic) IBOutlet MKMapView *mkMapView;

// Tutorials
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;

- (IBAction)menuBurgerButtonPressed:(id)sender;

@end

@implementation B311MapViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skipTutorial:) name:@"skipTutorial" object:nil];

    mapLocationAnnotations = [NSMutableArray new];

    currentGeoFences = [NSMutableArray new];

    // Initialize Location Manager
    _locationManager = [[CLLocationManager alloc] init];
    
    // Configure Location Manager
    [_locationManager setDelegate:self];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];

    // Side menu bar - Parking - Parking Ramp, Entrance and General
    NSArray *imageList = @[[UIImage imageNamed:@"handicap-ramp-no.png"], [UIImage imageNamed:@"handicap-ramp-left.png"], [UIImage imageNamed:@"handicap-ramp-right.png"], [UIImage imageNamed:@"entrance.png"], [UIImage imageNamed:@"general.png"]];
    sideBar = [[CDSideBarController alloc] initWithImages:imageList];
    sideBar.delegate = self;
    [sideBar insertMenuButtonOnView:self.view atPosition:CGPointMake(self.view.frame.size.width - 70, 50)];
    
    // Tutorial Setup
    // Create the data model
    _pageTitles = @[@"Annotate handicap parking spots on a map", @"Discover handicap entrances at locations", @"Annotate general handicap tips on a map"];
    _pageImages = @[@"page1.png", @"page2.png", @"page3.png"];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPageViewController"];
    self.pageViewController.dataSource = self;
    
    TutorialPageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    geocoder = [[CLGeocoder alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [sideBar handleMenuState];

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Updating Location Data...";
    hud.dimBackground = YES;
    
    // Get current location to add icon to the map
    [[INTULocationManager sharedInstance] requestLocationWithDesiredAccuracy:INTULocationAccuracyCity
                                                                     timeout:10.0
                                                        delayUntilAuthorized:YES
                                                                       block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                                                           
                                                                           if (status == INTULocationStatusSuccess) {
                                                                               
                                                                               // Request succeeded, meaning achievedAccuracy is at least the requested accuracy, and
                                                                               // currentLocation contains the device's current location.
                                                                               
                                                                               [self setUpMapKitCameraViewLocation:currentLocation];
                                                                               
                                                                               [[B311MapDataLocations instance] getMapLocations:^(BOOL success, NSArray *mapLocations, NSString *error) {
                                                                                   
                                                                                   [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                                                   
                                                                                   if (!error) {
                                                                                       
                                                                                       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Get Locations Data API Error"
                                                                                                                                           message:error
                                                                                                                                          delegate:nil
                                                                                                                                 cancelButtonTitle:@"OK"
                                                                                                                                 otherButtonTitles:nil];
                                                                                       [alertView show];
                                                                                   } else {
                                                                                       
                                                                                       // Add map annotations from map data returned from server
                                                                                       [mapLocationAnnotations removeAllObjects];
                                                                                       
                                                                                       mapLocationData = mapLocations;
                                                                                       
                                                                                       for (B311MapDataLocation *location in mapLocations) {
                                                                                           
                                                                                           B311MapDataAnnotation *annotation = [B311MapDataAnnotation new];
                                                                                           annotation.ltype = location.mtype;
                                                                                           annotation.title = location.address;
                                                                                           annotation.coordinate = CLLocationCoordinate2DMake(location.latitude , location.longitude);
                                                                                           [mapLocationAnnotations addObject:annotation];
                                                                                       }
                                                                                       
                                                                                       [_mkMapView addAnnotations:mapLocationAnnotations];
                                                                                       //[_mkMapView setCenterCoordinate:_mkMapView.region.center animated:NO];
                                                                                       [_mkMapView setCenterCoordinate:currentLocation.coordinate animated:NO];
                                                                                   }
                                                                                   
                                                                               } atLatitude:currentLocation.coordinate.latitude atLongitude:currentLocation.coordinate.longitude forRadius:[[B311AppProperties getInstance] getMapRadius] andWithHUD:hud];
                                                                           }
                                                                           else if (status == INTULocationStatusTimedOut) {
                                                                               
                                                                               CLLocation *currentDeviceLocation = [[CLLocation alloc] initWithLatitude:37.773972 longitude:-122.431297];
                                                                               [self setUpMapKitCameraViewLocation:currentDeviceLocation];
                                                                               
                                                                               // Wasn't able to locate the user with the requested accuracy within the timeout interval.
                                                                               // However, currentLocation contains the best location available (if any) as of right now,
                                                                               // and achievedAccuracy has info on the accuracy/recency of the location in currentLocation.
                                                                           }
                                                                           else {
                                                                               
                                                                               // An error occurred, more info is available by looking at the specific status returned.
                                                                               CLLocation *currentDeviceLocation = [[CLLocation alloc] initWithLatitude:37.773972 longitude:-122.431297];
                                                                               [self setUpMapKitCameraViewLocation:currentDeviceLocation];
                                                                           }
                                                                       }];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setUpMapKitCameraViewLocation:(CLLocation *)coords {
    
    // 3D Camera for cool 3D mapview
    if ([_mkMapView respondsToSelector:@selector(camera)]) {
        
        _mkMapView.mapType = MKMapTypeStandard;
        _mkMapView.zoomEnabled = YES;
        _mkMapView.scrollEnabled = YES;
        _mkMapView.region = MKCoordinateRegionMakeWithDistance(coords.coordinate, 1000, 500);
        [_mkMapView setShowsBuildings:YES];
        [_mkMapView setShowsUserLocation:YES];
        
        MKMapCamera *newCamera = [[_mkMapView camera] copy];
        [newCamera setPitch:45.0];
        [newCamera setHeading:90.0];
        [newCamera setAltitude:200.0];
        [_mkMapView setCamera:newCamera animated:NO];
    }
}

- (void)skipTutorial:(NSNotification *)note {
    
    [self.pageViewController.view removeFromSuperview];
    [self.pageViewController removeFromParentViewController];
    
    _pageTitles = nil;
    _pageImages = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (TutorialPageContentViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    TutorialPageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPageContentViewController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

- (IBAction)menuBurgerButtonPressed:(id)sender {
    
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

#pragma mark - Helpers

- (JVFloatingDrawerSpringAnimator *)drawerAnimator {
    
    return [[AppDelegate globalDelegate] drawerAnimator];
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = ((TutorialPageContentViewController *) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = ((TutorialPageContentViewController *) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {

    return 0;
}

#pragma mark - CDSideBarController delegate

- (void)menuButtonClicked:(long)index {

    // NOTE: index values
    //      0 -> handicap-ramp-no
    //      1 -> handicap-ramp-left
    //      2 -> handicap-ramp-right
    //      3 -> entrance
    //      4 -> general

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Creating a New Location...";
    hud.dimBackground = YES;

    [[INTULocationManager sharedInstance] requestLocationWithDesiredAccuracy:INTULocationAccuracyRoom
                                       timeout:10.0
                          delayUntilAuthorized:YES
                                         block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {

                                             if (status == INTULocationStatusSuccess) {
                                                 
                                                 // Request succeeded, meaning achievedAccuracy is at least the requested accuracy, and
                                                 // currentLocation contains the device's current location.
                                                 
                                                 // Get the address information for this lat/long doing a reverse lookup
                                                 [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {

                                                     B311MapDataLocation *location = [B311MapDataLocation new];
                                                     if (placemarks.count == 0) {
                                                         
                                                         location.title = @"";
                                                         location.address = @"";
                                                         location.city = @"";
                                                         location.state = @"";
                                                         location.zip = @"";
                                                         location.mtype = index;
                                                     }
                                                     else {
                                                         
                                                         CLPlacemark *placemark = placemarks[0];
                                                         NSLog(@"Found %@", placemark.name);
                                                         
                                                         /*
                                                          Data returned from CLPlacemark we can use in details view
                                                          
                                                          @property (nonatomic, readonly, copy) NSDictionary *addressDictionary;
                                                          
                                                          // address dictionary properties
                                                          @property (nonatomic, readonly, copy) NSString *name; // eg. Apple Inc.
                                                          @property (nonatomic, readonly, copy) NSString *thoroughfare; // street address, eg. 1 Infinite Loop
                                                          @property (nonatomic, readonly, copy) NSString *subThoroughfare; // eg. 1
                                                          @property (nonatomic, readonly, copy) NSString *locality; // city, eg. Cupertino
                                                          @property (nonatomic, readonly, copy) NSString *subLocality; // neighborhood, common name, eg. Mission District
                                                          @property (nonatomic, readonly, copy) NSString *administrativeArea; // state, eg. CA
                                                          @property (nonatomic, readonly, copy) NSString *subAdministrativeArea; // county, eg. Santa Clara
                                                          @property (nonatomic, readonly, copy) NSString *postalCode; // zip code, eg. 95014
                                                          @property (nonatomic, readonly, copy) NSString *ISOcountryCode; // eg. US
                                                          @property (nonatomic, readonly, copy) NSString *country; // eg. United States
                                                          @property (nonatomic, readonly, copy) NSString *inlandWater; // eg. Lake Tahoe
                                                          @property (nonatomic, readonly, copy) NSString *ocean; // eg. Pacific Ocean
                                                          @property (nonatomic, readonly, copy) NSArray *areasOfInterest; // eg. Golden Gate Park
                                                          */
                                                         
                                                         location.title = placemark.name;
                                                         location.address = [placemark.addressDictionary objectForKey:(NSString*) kABPersonAddressStreetKey];
                                                         location.city = placemark.locality;
                                                         location.state = placemark.administrativeArea;
                                                         location.zip = placemark.postalCode;
                                                         location.mtype = index;
                                                     }

                                                     [[B311MapDataLocations instance] newMapLocation:^(NSString *error) {

                                                         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

                                                         if (error != nil) {
                                                             
#define TESTING 1
#ifdef TESTING
                                                             // NOTE: For debugging create a new placement object using the type the user pressed (add to array for testing as move around)
                                                             B311MapDataAnnotation *annotation = [B311MapDataAnnotation new];
                                                             annotation.ltype = location.mtype;
                                                             annotation.title = location.title;
                                                             //annotation.coordinate = CLLocationCoordinate2DMake(location.latitude , location.longitude);
                                                             annotation.coordinate = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude , currentLocation.coordinate.longitude);
                                                             [mapLocationAnnotations addObject:annotation];
                                                             
                                                             [_mkMapView addAnnotations:mapLocationAnnotations];
                                                             //[_mkMapView setCenterCoordinate:_mkMapView.region.center animated:NO];
                                                             [_mkMapView setCenterCoordinate:currentLocation.coordinate animated:NO];
                                                             
#else
                                                             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New Location Data API Error"
                                                                                                                 message:error
                                                                                                                delegate:nil
                                                                                                       cancelButtonTitle:@"OK"
                                                                                                       otherButtonTitles:nil];
                                                             [alertView show];
#endif
                                                             return;
                                                         } else {

                                                             [self updateMapLocationGeoFences:currentLocation];
                                                         }
                                                         
                                                     } atLatitude:currentLocation.coordinate.latitude atLongitude:currentLocation.coordinate.longitude withData:location andWithHUD:nil];
                                                 }];
                                             }
                                             else if (status == INTULocationStatusTimedOut) {
                                                 
                                                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                 // Wasn't able to locate the user with the requested accuracy within the timeout interval.
                                                 // However, currentLocation contains the best location available (if any) as of right now,
                                                 // and achievedAccuracy has info on the accuracy/recency of the location in currentLocation.
                                             }
                                             else {
                                                 
                                                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                 // An error occurred, more info is available by looking at the specific status returned.
                                             }
                                         }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    // Fetch Current Location
    CLLocation *location = [locations objectAtIndex:0];

    [self updateMapLocationGeoFences:location];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);

    [[B311GeoFenceLocations instance] enteredGeoFenceLocation:^(NSString *error) {
        
        if (error) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"GeoFence API Error - Enter"
                                                                message:error
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            
        } else {
            
            // Pull down geo-fence list again. Upadte icons using that info
            // Get map locations data again too?
        }
        
    } atLocationId:region.identifier andWithHUD:nil];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);

    [[B311GeoFenceLocations instance] exitedGeoFenceLocation:^(NSString *error) {
        
        if (error) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"GeoFence API Error - Exit"
                                                                message:error
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            
        } else {
            
            // Pull down geo-fence list again. Upadte icons using that info
            // Get map locations data again too?
        }
        
    } atLocationId:region.identifier andWithHUD:nil];
}

- (void)updateMapLocationGeoFences:(CLLocation *)currentLocation {
    
    // Added new location to back-end, now update all of them to get new one and update geofencing regions
    
    [[B311MapDataLocations instance] getMapLocations:^(BOOL success, NSArray *mapLocations, NSString *error) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (!success) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Get Locations (New) Data API Error"
                                                                message:error
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            return;
        } else {
            
            // Add map annotations from map data returned from server
            [mapLocationAnnotations removeAllObjects];
            
            mapLocationData = mapLocations;
            
            // Clear old regions by passing in same UUID region identifier
            for (B311GeoFence *geoFence in currentGeoFences) {
                
                [currentGeoFences removeObject:geoFence];
                [_locationManager startMonitoringForRegion:geoFence.region];
            }
            
            for (B311MapDataLocation *location in mapLocations) {
                
                B311MapDataAnnotation *annotation = [B311MapDataAnnotation new];
                annotation.ltype = location.mtype;
                annotation.title = location.address;
                annotation.coordinate = CLLocationCoordinate2DMake(location.latitude , location.longitude);
                [mapLocationAnnotations addObject:annotation];

                // Create a geoFence if it is a parking type
                if (location.mtype == B311MapDataLocationTypeParkingRampNone || location.mtype == B311MapDataLocationTypeParkingRampLeft || location.mtype == B311MapDataLocationTypeParkingRampRight) {
                    
                    B311GeoFence *fence = [B311GeoFence new];
                    fence.location_id = location.id;
                    CLLocationCoordinate2D coordinate;
                    coordinate.latitude = location.latitude;
                    coordinate.longitude = location.longitude;
                    fence.region = [[CLCircularRegion alloc] initWithCenter:coordinate radius:kGeoFenceRadius identifier:location.id];
                }
            }
            
            // Start Monitoring geofence regions
            [_locationManager stopUpdatingLocation];

            [_mkMapView addAnnotations:mapLocationAnnotations];
            //[_mkMapView setCenterCoordinate:_mkMapView.region.center animated:NO];
            [_mkMapView setCenterCoordinate:currentLocation.coordinate animated:NO];
        }
        
    } atLatitude:currentLocation.coordinate.latitude atLongitude:currentLocation.coordinate.longitude forRadius:[[B311AppProperties getInstance] getMapRadius] andWithHUD:nil];
}

#pragma mark - MKMapViewDelegate

// NOTE: No dragging yet. Try and get highest quality read from GPS and see if good enough.
/*
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
 
    if (oldState == MKAnnotationViewDragStateDragging) {
 
        //MapCoordinates *annotation = (MapCoordinates *)annotationView.annotation;
        //reverseDelegate = self;
        //CLLocation *loc = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
        //[findAddress lookupAddress:loc];
        //annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
    }
}
*/
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    
    //[mapView selectAnnotation:currentSeller animated:YES];
    //[mapView selectAnnotation:[[mapView annotations] lastObject] animated:YES];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)uLocation {
    
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(uLocation.coordinate, 800, 800);
//    [_mkMapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    [mapView deselectAnnotation:view.annotation animated:YES];

    B311DetailsViewController *detailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"B311DetailsViewController"];
    detailsViewController.location_data = view.annotation;
    [self presentViewController:detailsViewController animated:YES completion:nil];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
}

-(MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        
        return nil;
    }
    
    static NSString *b311ParkingRampNoneAnnotationIdentifier = @"com.b311.parking.ramp.none.pin";
    static NSString *b311ParkingRampLeftAnnotationIdentifier = @"com.b311.parking.ramp.left.pin";
    static NSString *b311ParkingRampRightAnnotationIdentifier = @"com.b311.parking.ramp.right.pin";
    static NSString *b311GeneralAnnotationIdentifier = @"com.b311.general.pin";
    static NSString *b311EntranceAnnotationIdentifier = @"com.b311.entrance.pin";

    // NOTE: Create a new B311GeoFenceLocations - getGeofenceLocations
    // Get current location to add icon to the map
    // - (void)newGeofenceLocation:(void (^)(NSString *error))completion withGeoFence:(B311GeoFence *)geo_fence andWithHUD:(MBProgressHUD *)hud;
    // ***** Create the location first, because need "location_id" for geo_fence *****
    
// If parking then create a geofence around that area. Create array of geolocations from those values?
    
    if ([annotation isKindOfClass:[B311MapDataAnnotation class]]) {
        
        B311MapDataAnnotation *annotationData = annotation;
        MKAnnotationView *annotationView = nil;

        if (annotationData.ltype == B311MapDataLocationTypeGeneral) {
        
            annotationView = [_mkMapView dequeueReusableAnnotationViewWithIdentifier:b311GeneralAnnotationIdentifier];
            if (!annotationView) {
                
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:b311GeneralAnnotationIdentifier];
                annotationView.canShowCallout = YES;
                //UIImageView *generalView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"deal_pin-a.png"]];
                //[generalView setFrame:CGRectMake(0, 0, 30, 30)];
                //annotationView.leftCalloutAccessoryView = generalView;
                annotationView.image = [UIImage imageNamed:@"map_annotation_general"];
            }
        } else if (annotationData.ltype == B311MapDataLocationTypeEntrance) {
            
            annotationView = [_mkMapView dequeueReusableAnnotationViewWithIdentifier:b311GeneralAnnotationIdentifier];
            if (!annotationView) {
                
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:b311EntranceAnnotationIdentifier];
                annotationView.canShowCallout = YES;
                annotationView.image = [UIImage imageNamed:@"map_annotation_entrance"];
            }
        } else if (annotationData.ltype == B311MapDataLocationTypeParkingRampNone) {
            
            annotationView = [_mkMapView dequeueReusableAnnotationViewWithIdentifier:b311ParkingRampNoneAnnotationIdentifier];
            if (!annotationView) {
                
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:b311ParkingRampNoneAnnotationIdentifier];
                annotationView.canShowCallout = YES;
                annotationView.image = [UIImage imageNamed:@"map_annotation_parking_no_full"];
            }
        } else if (annotationData.ltype == B311MapDataLocationTypeParkingRampLeft) {
            
            annotationView = [_mkMapView dequeueReusableAnnotationViewWithIdentifier:b311ParkingRampLeftAnnotationIdentifier];
            if (!annotationView) {
                
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:b311ParkingRampLeftAnnotationIdentifier];
                annotationView.canShowCallout = YES;
                annotationView.image = [UIImage imageNamed:@"map_annotation_parking_left_full"];
            }
        } else if (annotationData.ltype == B311MapDataLocationTypeParkingRampRight) {
            
            annotationView = [_mkMapView dequeueReusableAnnotationViewWithIdentifier:b311ParkingRampRightAnnotationIdentifier];
            if (!annotationView) {
                
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:b311ParkingRampRightAnnotationIdentifier];
                annotationView.canShowCallout = YES;
                annotationView.image = [UIImage imageNamed:@"map_annotation_parking_right_full"];
            }
        }

        return annotationView;
    }

    return nil;
}

@end
