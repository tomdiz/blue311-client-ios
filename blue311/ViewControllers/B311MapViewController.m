//
//  O311MapViewController.m
//  blue311
//
//  Created by Thomas DiZoglio on 3/23/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <INTULocationManager/INTULocationManager.h>
#import "B311MapViewController.h"
#import "JVFloatingDrawerSpringAnimator.h"
#import "AppDelegate.h"
#import "TutorialPageContentViewController.h"
#import "B311MapDataLocations.h"
#import "B311AppProperties.h"
#import "B311GeoFenceLocations.h"

@interface B311MapViewController () <UIPageViewControllerDataSource> {
    
    NSArray *geoFences;
    NSMutableArray *currentGeoFences;
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

                                                                           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

                                                                           if (status == INTULocationStatusSuccess) {

                                                                               // Request succeeded, meaning achievedAccuracy is at least the requested accuracy, and
                                                                               // currentLocation contains the device's current location.
                                                                               [[B311MapDataLocations instance] getMapLocations:^(BOOL success, NSArray *mapLocations, NSString *error) {

                                                                                   if (!error) {
                                                                                       
                                                                                       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Get Location Data API Error"
                                                                                                                                           message:error
                                                                                                                                          delegate:nil
                                                                                                                                 cancelButtonTitle:@"OK"
                                                                                                                                 otherButtonTitles:nil];
                                                                                       [alertView show];
                                                                                   } else {
                                                                                       
                                                                                       // UPDATE THE MAP ANNOTATIONS WITH ARRAY RETURNED FOR BACK-END
                                                                                       
                                                                                       //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Update Location"
                                                                                       //                                                     message:@"Location data has been updated."
                                                                                       //                                                    delegate:nil
                                                                                       //                                           cancelButtonTitle:@"OK"
                                                                                       //                                           otherButtonTitles:nil];
                                                                                       //[alertView show];
                                                                                   }
                                                                                   
                                                                               } atLatitude:currentLocation.coordinate.latitude atLongitude:currentLocation.coordinate.longitude forRadius:[[B311AppProperties getInstance] getMapRadius] andWithHUD:hud];
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
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [sideBar handleMenuState];
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
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Creating a New Location...";
    hud.dimBackground = YES;

    [[INTULocationManager sharedInstance] requestLocationWithDesiredAccuracy:INTULocationAccuracyRoom
                                       timeout:10.0
                          delayUntilAuthorized:YES
                                         block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {

                                             [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

                                             if (status == INTULocationStatusSuccess) {
                                                 
                                                 // Request succeeded, meaning achievedAccuracy is at least the requested accuracy, and
                                                 // currentLocation contains the device's current location.
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

@end
