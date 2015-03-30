//
//  O311MapViewController.m
//  blue311
//
//  Created by Thomas DiZoglio on 3/23/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "B311MapViewController.h"
#import "JVFloatingDrawerSpringAnimator.h"
#import "AppDelegate.h"
#import "TutorialPageContentViewController.h"

@interface B311MapViewController () <UIPageViewControllerDataSource>

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

    // Side menu bar - Parking - Parking Ramp, Entrance and General
    NSArray *imageList = @[[UIImage imageNamed:@"menuChat.png"], [UIImage imageNamed:@"menuUsers.png"], [UIImage imageNamed:@"menuMap.png"], [UIImage imageNamed:@"menuClose.png"]];
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
    
    // Execute what ever you want
}

@end
