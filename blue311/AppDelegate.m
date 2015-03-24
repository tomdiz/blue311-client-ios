//
//  AppDelegate.m
//  blue311
//
//  Created by Thomas DiZoglio on 3/23/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import "AppDelegate.h"
#import "JVFloatingDrawerViewController.h"
#import "JVFloatingDrawerSpringAnimator.h"
#import "B311AppProperties.h"

static NSString * const O311MainStoryboardName = @"Main";

// ViewControllers to open from JVFloating menu
static NSString * const kO311LeftDrawerViewControllerStoryboardID = @"O311LeftDrawerViewControllerStoryboardID";
static NSString * const kO311MapViewControllerStoryboardID = @"O311MapViewController";
static NSString * const kO311ProfileViewControllerStoryboardID = @"O311ProfileViewController";
static NSString * const kO311SettingsViewControllerStoryboardID = @"O311SettingsViewController";
static NSString * const kO311HelpViewControllerStoryboardID = @"O311HelpViewController";

@interface AppDelegate ()

@property (nonatomic, strong, readonly) UIStoryboard *drawersStoryboard;

@end

@implementation AppDelegate

@synthesize drawersStoryboard = _drawersStoryboard;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.drawerViewController;
    [self configureDrawerViewController];
    
    [self.window makeKeyAndVisible];

    // Override point for customization after application launch.
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];

    // Set up application defaults
    [self setAppDefaults];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Drawer View Controllers

- (JVFloatingDrawerViewController *)drawerViewController {
    
    if (!_drawerViewController) {
        
        _drawerViewController = [[JVFloatingDrawerViewController alloc] init];
    }
    
    return _drawerViewController;
}

#pragma mark Sides

- (UITableViewController *)leftDrawerViewController {
    
    if (!_leftDrawerViewController) {
        
        _leftDrawerViewController = [self.drawersStoryboard instantiateViewControllerWithIdentifier:kO311LeftDrawerViewControllerStoryboardID];
    }
    
    return _leftDrawerViewController;
}

#pragma mark Center

- (UIViewController *)drawerSettingsViewController {
    
    if (!_drawerSettingsViewController) {
        
        _drawerSettingsViewController = [self.drawersStoryboard instantiateViewControllerWithIdentifier:kO311SettingsViewControllerStoryboardID];
    }
    
    return _drawerSettingsViewController;
}

- (UIViewController *)drawerHelpViewController {
    
    if (!_drawerHelpViewController) {
        
        _drawerHelpViewController = [self.drawersStoryboard instantiateViewControllerWithIdentifier:kO311HelpViewControllerStoryboardID];
    }
    
    return _drawerHelpViewController;
}

- (UIViewController *)drawerMapViewController {
    
    if (!_drawerMapViewController) {
        
        _drawerMapViewController = [self.drawersStoryboard instantiateViewControllerWithIdentifier:kO311MapViewControllerStoryboardID];
    }
    
    return _drawerMapViewController;
}

- (UIViewController *)drawerProfileViewController {
    
    if (!_drawerProfileViewController) {
        
        _drawerProfileViewController = [self.drawersStoryboard instantiateViewControllerWithIdentifier:kO311ProfileViewControllerStoryboardID];
    }
    
    return _drawerProfileViewController;
}

- (JVFloatingDrawerSpringAnimator *)drawerAnimator {
    
    if (!_drawerAnimator) {
        
        _drawerAnimator = [[JVFloatingDrawerSpringAnimator alloc] init];
    }
    
    return _drawerAnimator;
}

- (UIStoryboard *)drawersStoryboard {
    
    if(!_drawersStoryboard) {
        
        _drawersStoryboard = [UIStoryboard storyboardWithName:O311MainStoryboardName bundle:nil];
    }
    
    return _drawersStoryboard;
}

- (void)configureDrawerViewController {
    
    self.drawerViewController.leftViewController = self.leftDrawerViewController;
    self.drawerViewController.centerViewController = self.drawerMapViewController;
    
    self.drawerViewController.animator = self.drawerAnimator;
    
    self.drawerViewController.backgroundImage = [UIImage imageNamed:@"drawer_image"];
}

- (void) setAppDefaults {

    [[B311AppProperties getInstance] getSideMenuState];
}

#pragma mark - Global Access Helper

+ (AppDelegate *)globalDelegate {
    
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)toggleLeftDrawer:(id)sender animated:(BOOL)animated {
    
    [self.drawerViewController toggleDrawerWithSide:JVFloatingDrawerSideLeft animated:animated completion:nil];
}

- (void)toggleRightDrawer:(id)sender animated:(BOOL)animated {
    
    [self.drawerViewController toggleDrawerWithSide:JVFloatingDrawerSideRight animated:animated completion:nil];
}

@end
