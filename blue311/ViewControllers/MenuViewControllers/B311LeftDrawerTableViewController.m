//
//  JVLeftDrawerTableViewController.m
//  JVFloatingDrawer
//
//  Created by Julian Villella on 2015-01-15.
//  Copyright (c) 2015 JVillella. All rights reserved.
//

#import "B311LeftDrawerTableViewController.h"
#import "B311LeftDrawerTableViewCell.h"
#import "AppDelegate.h"
#import "JVFloatingDrawerViewController.h"

enum {

    kJVDrawerMapIndex = 0,
    kJVDrawerProfileIndex = 1,
    kJVSettingsPageIndex = 2,
    kJVHelpPageIndex = 3,
    
    kTotalDrawerItems
};

static const CGFloat kJVTableViewTopInset = 80.0;
static NSString * const kJVDrawerCellReuseIdentifier = @"O311DrawerCellReuseIdentifier";

@interface B311LeftDrawerTableViewController ()

@end

@implementation B311LeftDrawerTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.contentInset = UIEdgeInsetsMake(kJVTableViewTopInset, 0.0, 0.0, 0.0);
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:kJVDrawerMapIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - Table View Data Source
/*
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}
*/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return kTotalDrawerItems;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    B311LeftDrawerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kJVDrawerCellReuseIdentifier forIndexPath:indexPath];
    
    if (indexPath.row == kJVDrawerMapIndex) {
        
        cell.titleText = @"Map";
        cell.iconImage = [UIImage imageNamed:@"map-pin"];
        
    } else if (indexPath.row == kJVDrawerProfileIndex) {
        
        cell.titleText = @"Profile";
        cell.iconImage = [UIImage imageNamed:@"profile"];
    } else if (indexPath.row == kJVSettingsPageIndex) {
        
        cell.titleText = @"Settings";
        cell.iconImage = [UIImage imageNamed:@"665-gear"];
    } else {
        
        cell.titleText = @"Help";
        cell.iconImage = [UIImage imageNamed:@"help"];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIViewController *destinationViewController = nil;

    if (indexPath.row == kJVDrawerMapIndex) {
        
        destinationViewController = [[AppDelegate globalDelegate] drawerMapViewController];
    } else if (indexPath.row == kJVDrawerProfileIndex) {
        
        
        destinationViewController = [[AppDelegate globalDelegate] drawerProfileViewController];
    } else if (indexPath.row == kJVSettingsPageIndex) {
        
        
        destinationViewController = [[AppDelegate globalDelegate] drawerSettingsViewController];
    } else {
        
        destinationViewController = [[AppDelegate globalDelegate] drawerHelpViewController];
    }
    
    [[[AppDelegate globalDelegate] drawerViewController] setCenterViewController:destinationViewController];
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
