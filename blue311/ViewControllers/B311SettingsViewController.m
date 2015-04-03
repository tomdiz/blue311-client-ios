//
//  O311SettingsViewController.m
//  blue311
//
//  Created by Thomas DiZoglio on 3/23/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import "B311SettingsViewController.h"
#import "JVFloatingDrawerSpringAnimator.h"
#import "AppDelegate.h"
#import "B311AppProperties.h"

@interface B311SettingsViewController ()

@property (nonatomic, strong, readonly) JVFloatingDrawerSpringAnimator *drawerAnimator;

@property (weak, nonatomic) IBOutlet UISwitch *swtSideMenu;
@property (weak, nonatomic) IBOutlet UILabel *lblSideMenuOnMap;
@property (weak, nonatomic) IBOutlet UISlider *sldRadiusSearch;
@property (weak, nonatomic) IBOutlet UILabel *lblRadius;

- (IBAction)menuBurgerButtonPressed:(id)sender;
- (IBAction)sideMenuSwitchValueChanged:(id)sender;
- (IBAction)radiusValueChanged:(UISlider *)sender;

@end

@implementation B311SettingsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if ([[B311AppProperties getInstance] getSideMenuState] == NO) {
        
        _lblSideMenuOnMap.text = @"Open Side Menu on Map";
        [_swtSideMenu setOn:YES];
    }
    else {
        
        _lblSideMenuOnMap.text = @"Hide Side Menu on Map";
        [_swtSideMenu setOn:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];

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

- (IBAction)menuBurgerButtonPressed:(id)sender {
    
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

- (IBAction)sideMenuSwitchValueChanged:(id)sender {

    // Save off settings
    if (_swtSideMenu.isOn == YES) {
        
        [[B311AppProperties getInstance] setSideMenuState:NO];
        _lblSideMenuOnMap.text = @"Open Side Menu on Map";
    }
    else {
        
        [[B311AppProperties getInstance] setSideMenuState:YES];
        _lblSideMenuOnMap.text = @"Hide Side Menu on Map";
    }
}

- (IBAction)radiusValueChanged:(UISlider *)sender {
    
    // lblRadius miles
    NSLog(@"slider value = %f", sender.value);
    _lblRadius.text = [NSString stringWithFormat:@"%d miles", (int)sender.value];
}

#pragma mark - Helpers

- (JVFloatingDrawerSpringAnimator *)drawerAnimator {
    
    return [[AppDelegate globalDelegate] drawerAnimator];
}

@end
