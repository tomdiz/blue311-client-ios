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

@interface B311MapViewController () <UIPageViewControllerDataSource> {
    
    NSArray *geoFences;
    NSMutableArray *currentGeoFences;
    NSArray *mapLocationAnnotations;
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

    currentGeoFences = [NSMutableArray new];

    // Initialize Location Manager
    _locationManager = [[CLLocationManager alloc] init];
    
    // Configure Location Manager
    [_locationManager setDelegate:self];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];

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
                                                                                       
                                                                                       // UPDATE THE MAP ANNOTATIONS WITH ARRAY RETURNED FOR BACK-END
                                                                                       mapLocationAnnotations = mapLocations;
                                                                                       
                                                                                       [_mkMapView addAnnotations:mapLocationAnnotations];
                                                                                       [_mkMapView setCenterCoordinate:_mkMapView.region.center animated:NO];
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
        
        MKMapCamera *newCamera = [[_mkMapView camera] copy];
        [newCamera setPitch:45.0];
        [newCamera setHeading:90.0];
        [newCamera setAltitude:800.0];
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
    
    // NOTE: Create a new B311GeoFenceLocations - getGeofenceLocations
    // Get current location to add icon to the map
    // - (void)newGeofenceLocation:(void (^)(NSString *error))completion withGeoFence:(B311GeoFence *)geo_fence andWithHUD:(MBProgressHUD *)hud;
    // ***** Create the location first, because need "location_id" for geo_fence *****
    
    // NOTE: See notepad notes
    
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

                                                     CLPlacemark *placemark = placemarks[0];
                                                     NSLog(@"Found %@", placemark.name);

                                                    /*
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
                                                     B311MapDataLocation *location = [B311MapDataLocation new];

                                                     location.title = placemark.name;
                                                     location.address = [placemark.addressDictionary objectForKey:(NSString*) kABPersonAddressStreetKey];
                                                     location.city = placemark.locality;
                                                     location.state = placemark.administrativeArea;
                                                     location.zip = placemark.postalCode;
                                                     location.mtype = index;
                                                     location.latitude = placemark.location.coordinate.latitude;
                                                     location.longitude = placemark.location.coordinate.longitude;

                                                     [[B311MapDataLocations instance] newMapLocation:^(NSString *error) {

                                                         if (!error) {
                                                             
                                                             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New Location Data API Error"
                                                                                                                 message:error
                                                                                                                delegate:nil
                                                                                                       cancelButtonTitle:@"OK"
                                                                                                       otherButtonTitles:nil];
                                                             [alertView show];
                                                         } else {
                                                             
                                                             // Added new location to back-end, now update all of them to get new one
                                                             [[B311MapDataLocations instance] getMapLocations:^(BOOL success, NSArray *mapLocations, NSString *error) {
                                                                 
                                                                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                                 
                                                                 if (!error) {
                                                                     
                                                                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Get Locations (New) Data API Error"
                                                                                                                         message:error
                                                                                                                        delegate:nil
                                                                                                               cancelButtonTitle:@"OK"
                                                                                                               otherButtonTitles:nil];
                                                                     [alertView show];
                                                                 } else {
                                                                     
                                                                     // Update using data from back-end
                                                                     mapLocationAnnotations = mapLocations;

                                                                     [_mkMapView addAnnotations:mapLocationAnnotations];
                                                                     [_mkMapView setCenterCoordinate:_mkMapView.region.center animated:NO];
                                                                 }
                                                                 
                                                             } atLatitude:currentLocation.coordinate.latitude atLongitude:currentLocation.coordinate.longitude forRadius:[[B311AppProperties getInstance] getMapRadius] andWithHUD:nil];
                                                         }
                                                         
                                                     } atLatitude:currentLocation.coordinate.latitude atLongitude:currentLocation.coordinate.longitude withData:nil andWithHUD:nil];

                                                 }];
                                                 

                                             }
                                             else if (status == INTULocationStatusTimedOut) {
                                                 
                                                 // Wasn't able to locate the user with the requested accuracy within the timeout interval.
                                                 // However, currentLocation contains the best location available (if any) as of right now,
                                                 // and achievedAccuracy has info on the accuracy/recency of the location in currentLocation.
                                             }
                                             else {
                                                 
                                                 // An error occurred, more info is available by looking at the specific status returned.
                                             }
                                         }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    // Fetch Current Location
    CLLocation *location = [locations objectAtIndex:0];

    [[B311GeoFenceLocations instance] getGeofenceLocations:^(BOOL success, NSArray *geFenceLocations, NSString *error) {

        if (!success) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"GeoFence API Error"
                                                                message:error
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];

        } else {
            
            geoFences = [B311GeoFenceLocations instance].geoFenceLocations;

            if (geoFences && [geoFences count]) {
                
                // Clear old regions by passing in same UUID region identifier
                for (B311GeoFence *geoFence in currentGeoFences) {
                    
                    [currentGeoFences removeObject:geoFence];
                    [_locationManager startMonitoringForRegion:geoFence.region];
                }

                for (B311GeoFence *geoFence in geoFences) {
                    
                    [currentGeoFences addObject:geoFence];
                    [_locationManager startMonitoringForRegion:geoFence.region];
                }
                
                // Start Monitoring geofence regions
                [_locationManager stopUpdatingLocation];
            }
        }
        
    } atLatitude:location.coordinate.latitude atLongitude:location.coordinate.longitude forRadius:[[B311AppProperties getInstance] getMapRadius] andWithHUD:nil];
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

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)lMapView didAddAnnotationViews:(NSArray *)views
{
    //[mapView selectAnnotation:currentSeller animated:YES];
    //[mapView selectAnnotation:[[mapView annotations] lastObject] animated:YES];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)uLocation {
    
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(uLocation.coordinate, 800, 800);
//    [_mkMapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

-(MKAnnotationView *) mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        
        return nil;
    }
    
    static NSString *b311ParkingRampNoneAnnotationIdentifier = @"com.b311.parking.ramp.none.pin";
    static NSString *b311ParkingRampLeftAnnotationIdentifier = @"com.b311.parking.ramp.left.pin";
    static NSString *b311ParkingRamprightAnnotationIdentifier = @"com.b311.parking.ramp.right.pin";
    static NSString *b311GeneralAnnotationIdentifier = @"com.b311.general.pin";
    static NSString *b311EntranceAnnotationIdentifier = @"com.b311.entrance.pin";

    // NOTE: Use the map data type to figure out what type of annotation to load
    
    if ([annotation isKindOfClass:[B311MapDataAnnotation class]]) {
        MKAnnotationView *annotationView = [_mkMapView dequeueReusableAnnotationViewWithIdentifier:b311GeneralAnnotationIdentifier];
        if (!annotationView)
        {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:b311GeneralAnnotationIdentifier];
            annotationView.canShowCallout = YES;
            //UIImageView *generalView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"deal_pin-a.png"]];
            //[generalView setFrame:CGRectMake(0, 0, 30, 30)];
            //annotationView.leftCalloutAccessoryView = generalView;
            annotationView.image = [UIImage imageNamed:@"map_annotation_general"];
        }
        return annotationView;
    }
/*
    if (annotation != mapView.userLocation)
    {
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:waitTimeAnnotationIdentifier];
        if (!annotationView)
        {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:waitTimeAnnotationIdentifier];
            annotationView.canShowCallout = YES;
            UIImageView *houseIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Wait_Pin-a.png"]];
            [houseIconView setFrame:CGRectMake(0, 0, 30, 30)];
            annotationView.leftCalloutAccessoryView = houseIconView;
            annotationView.image = [UIImage imageNamed:@"Wait_Pin-b.png"];
            //UIButton * disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            //[disclosureButton addTarget:self action:@selector(presentMoreInfo:) forControlEvents:UIControlEventTouchUpInside];
            //annotationView.rightCalloutAccessoryView = disclosureButton;
        }
        return annotationView;
    }
*/
    return nil;
}

@end
