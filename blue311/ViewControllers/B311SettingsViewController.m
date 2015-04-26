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
@property (weak, nonatomic) IBOutlet UISlider *sldMapUpdateTimer;
@property (weak, nonatomic) IBOutlet UILabel *lblMapTimer;
@property (weak, nonatomic) IBOutlet UISwitch *swtTutorialSwitch;
@property (weak, nonatomic) IBOutlet UILabel *lblTutorialState;

- (IBAction)menuBurgerButtonPressed:(id)sender;
- (IBAction)sideMenuSwitchValueChanged:(id)sender;
- (IBAction)radiusValueChanged:(UISlider *)sender;
- (IBAction)mapTimerValueChanged:(UISlider *)sender;

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

    if ([[B311AppProperties getInstance] getTutorialState] == NO) {
        
        _lblTutorialState.text = @"Turn Tutorial On";
        [_swtTutorialSwitch setOn:YES];
    }
    else {
        
        _lblSideMenuOnMap.text = @"Turn Tutorial Off";
        [_swtTutorialSwitch setOn:NO];
    }

    _lblRadius.text = [NSString stringWithFormat:@"%d miles", (int)[[B311AppProperties getInstance] getMapRadius]];
    _lblMapTimer.text = [NSString stringWithFormat:@"%d secs", (int)[[B311AppProperties getInstance] getMapUpdateTimer]];
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

    if (_swtTutorialSwitch.isOn == YES) {
        
        [[B311AppProperties getInstance] setTutorialState:NO];
        _lblTutorialState.text = @"Turn Tutorial Off";
    }
    else {
        
        [[B311AppProperties getInstance] setTutorialState:YES];
        _lblTutorialState.text = @"Turn Tutorial On";
    }
}

- (IBAction)radiusValueChanged:(UISlider *)sender {
    
    //NSLog(@"slider value = %f", sender.value);
    _lblRadius.text = [NSString stringWithFormat:@"%d miles", (int)sender.value];
    [[B311AppProperties getInstance] setMapRadius:(float)sender.value];
}

- (IBAction)mapTimerValueChanged:(UISlider *)sender {

    //NSLog(@"slider value = %f", sender.value);
    _lblMapTimer.text = [NSString stringWithFormat:@"%d secs", (int)sender.value];
    [[B311AppProperties getInstance] setMapUpdateTimer:(double)sender.value];
}

#pragma mark - Helpers

- (JVFloatingDrawerSpringAnimator *)drawerAnimator {
    
    return [[AppDelegate globalDelegate] drawerAnimator];
}

@end
