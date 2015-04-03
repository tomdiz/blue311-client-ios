//
//  O311ProfileViewController.m
//  blue311
//
//  Created by Thomas DiZoglio on 3/23/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import "B311ProfileViewController.h"
#import <INTULocationManager/INTULocationManager.h>
#import "JVFloatingDrawerSpringAnimator.h"
#import "AppDelegate.h"
#import "B311User.h"
#import "MBProgressHUD.h"

@interface B311ProfileViewController ()

@property (nonatomic, strong, readonly) JVFloatingDrawerSpringAnimator *drawerAnimator;
@property (weak, nonatomic) IBOutlet UITextField *txtFirstName;
@property (weak, nonatomic) IBOutlet UITextField *txtLastName;
@property (weak, nonatomic) IBOutlet UITextField *txtEmailAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtHandle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segUserType;

- (IBAction)menuBurgerButtonPressed:(id)sender;
- (IBAction)createProfileButtonPressed:(id)sender;

@end

@implementation B311ProfileViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    B311User *user = [B311User loadB311User];
    if (user != nil) {
        
        _txtFirstName.text = user.firstName;
        _txtLastName.text = user.lastName;
        _txtEmailAddress.text = user.email;
        _txtHandle.text = user.handle;
        
        if (user.userType == B311UserTypeBlue) {
            
            _segUserType.selectedSegmentIndex = 0;
        }
        else {
            
            _segUserType.selectedSegmentIndex = 1;
        }
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
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

- (IBAction)createProfileButtonPressed:(id)sender {

    if (_txtFirstName.text == nil || [_txtFirstName.text isEqualToString:@""]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Profile Error"
                                                        message:@"Please provide a first name"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (_txtLastName.text == nil || [_txtLastName.text isEqualToString:@""]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Profile Error"
                                                        message:@"Please provide a last name"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (_txtEmailAddress.text == nil || [_txtEmailAddress.text isEqualToString:@""]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Profile Error"
                                                        message:@"Please provide a email address"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    if (_txtHandle.text == nil || [_txtHandle.text isEqualToString:@""]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Profile Error"
                                                        message:@"Please provide a handle"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Creating Profile For Blue311...";
    hud.dimBackground = YES;

    [[INTULocationManager sharedInstance] requestLocationWithDesiredAccuracy:INTULocationAccuracyHouse
                                       timeout:5.0
                          delayUntilAuthorized:YES  // This parameter is optional, defaults to NO if omitted
                                         block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                             
                                             if (status == INTULocationStatusSuccess) {
 
                                                 // Request succeeded, meaning achievedAccuracy is at least the requested accuracy, and
                                                 // currentLocation contains the device's current location.
                                                 [B311User userCreateAccount:_txtFirstName.text
                                                              withLastName:_txtLastName.text
                                                              withEmail:_txtEmailAddress.text
                                                                withHandle:_txtHandle.text
                                                                withUserType:_segUserType.selectedSegmentIndex
                                                                   withLat:currentLocation.coordinate.latitude
                                                                  withLong:currentLocation.coordinate.longitude
                                                                completion:^(BOOL success, NSString *errorMessage) {
                                                                    
                                                                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                                    
                                                                    if (success) {
                                                                        
                                                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Profile Successful"
                                                                                                                        message:@"You can post new data to Blue311"
                                                                                                                       delegate:nil
                                                                                                              cancelButtonTitle:@"OK"
                                                                                                              otherButtonTitles:nil];
                                                                        [alert show];
                                                                    } else {
                                                                        
                                                                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Profile Failed"
                                                                                                                            message:errorMessage
                                                                                                                           delegate:self
                                                                                                                  cancelButtonTitle:@"OK"
                                                                                                                  otherButtonTitles:nil];
                                                                        
                                                                        [alertView show];
                                                                    }
                                                                }];
                                             }
                                             else if (status == INTULocationStatusTimedOut) {

                                                 // Wasn't able to locate the user with the requested accuracy within the timeout interval.
                                                 // However, currentLocation contains the best location available (if any) as of right now,
                                                 // and achievedAccuracy has info on the accuracy/recency of the location in currentLocation.
                                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Profile Failed"
                                                                                                 message:@"INTULocationStatusTimedOut"
                                                                                                delegate:nil
                                                                                       cancelButtonTitle:@"OK"
                                                                                       otherButtonTitles:nil];
                                                 [alert show];
                                             }
                                             else {

                                                 // An error occurred, more info is available by looking at the specific status returned.
                                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Profile Failed"
                                                                                                 message:@"INTULocationStatus ERROR"
                                                                                                delegate:nil
                                                                                       cancelButtonTitle:@"OK"
                                                                                       otherButtonTitles:nil];
                                                 [alert show];
                                             }
                                         }];
}

#pragma mark - Helpers

- (JVFloatingDrawerSpringAnimator *)drawerAnimator {
    
    return [[AppDelegate globalDelegate] drawerAnimator];
}

@end
