//
//  B311DetailsViewController.m
//  blue311
//
//  Created by Thomas DiZoglio on 3/30/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import "B311DetailsViewController.h"
#import "B311CommentTableViewCell.h"
#import "B311Comments.h"

@interface B311DetailsViewController () {
    
    NSArray *commentsArray;
    BOOL locationEdited;
}

@property (weak, nonatomic) IBOutlet UITableView *tblComments;
@property (weak, nonatomic) IBOutlet UIImageView *imgLocationIconType;
@property (weak, nonatomic) IBOutlet UITextField *txtTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtCity;
@property (weak, nonatomic) IBOutlet UITextField *txtState;
@property (weak, nonatomic) IBOutlet UITextField *txtZip;

- (IBAction)addCommentButtonPressed:(id)sender;
- (IBAction)titleEditButtonPressed:(id)sender;
- (IBAction)streetEditButtonPressed:(id)sender;
- (IBAction)cityEditButtonPressed:(id)sender;
- (IBAction)stateEditButtonPressed:(id)sender;
- (IBAction)zipEditButtonPressed:(id)sender;
- (IBAction)closeButtonPressed:(id)sender;

@end

@implementation B311DetailsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    locationEdited = NO;
    
    _txtTitle.text = _location_data.title;
    _txtCity.text = _location_data.city;
    _txtAddress.text = _location_data.address;
    _txtState.text = _location_data.state;
    _txtZip.text = _location_data.zip;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Getting Comments for Location...";
    hud.dimBackground = YES;

    [[B311Comments instance] getComments:^(BOOL success, NSArray *location_comments, NSString *error) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (!success) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Comments API Error"
                                                                message:error
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            
            [_tblComments reloadData];
            
        } else {
            
            commentsArray = [[B311Comments instance].userComments copy];
            if (commentsArray.count == 0) {
                
                //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Comments"
                //                                                    message:@"You have no comments for this location."
                //                                                   delegate:nil
                //                                          cancelButtonTitle:@"OK"
                //                                          otherButtonTitles:nil];
                //[alertView show];
            }
            else {
                
                [_tblComments reloadData];
            }
        }
        
    } forLocationId:_location_id andWithHUD:hud];
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

- (IBAction)addCommentButtonPressed:(id)sender {

    B311User *user = [B311User loadB311User];
    if (user == nil) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Adding Comments"
                                                            message:@"You need to create a Profile before you can add comments"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }

    locationEdited = NO;
}

- (IBAction)titleEditButtonPressed:(id)sender {
    
    B311User *user = [B311User loadB311User];
    if (user == nil) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Editing Details"
                                                            message:@"You need to create a Profile before you can change location details"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    locationEdited = NO;
}

- (IBAction)streetEditButtonPressed:(id)sender {
    
    B311User *user = [B311User loadB311User];
    if (user == nil) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Editing Details"
                                                            message:@"You need to create a Profile before you can change location details"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    locationEdited = NO;
}

- (IBAction)cityEditButtonPressed:(id)sender {
    
    B311User *user = [B311User loadB311User];
    if (user == nil) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Editing Details"
                                                            message:@"You need to create a Profile before you can change location details"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    locationEdited = NO;
}

- (IBAction)stateEditButtonPressed:(id)sender {
    
    locationEdited = NO;
}

- (IBAction)zipEditButtonPressed:(id)sender {
    
    B311User *user = [B311User loadB311User];
    if (user == nil) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Editing Details"
                                                            message:@"You need to create a Profile before you can change location details"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    locationEdited = NO;
}

- (IBAction)closeButtonPressed:(id)sender {
    
    if (locationEdited == YES) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Updating Location Details...";
        hud.dimBackground = YES;
        
        B311MapDataLocation *location = [B311MapDataLocation new];
        location.title = _txtTitle.text;
        location.address = _txtAddress.text;
        location.city = _txtCity.text;
        location.state = _txtState.text;
        location.zip = _txtZip.text;

        [[B311MapDataLocations instance] updateMapLocation:^(NSString *error) {
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            if (!error) {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Update Location API Error"
                                                                    message:error
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];

            } else {
                
                //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Update Location"
                //                                                    message:@"Location data has been updated."
                //                                                   delegate:nil
                //                                          cancelButtonTitle:@"OK"
                //                                          otherButtonTitles:nil];
                //[alertView show];

                [self dismissViewControllerAnimated:YES completion:nil];
            }
            
        } withData:location andWithHUD:hud];
    }
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [commentsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *MyIdentifier = @"B311CommentIdentifier";
    
    B311CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil) {
        
        cell = [[B311CommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    
    B311Comment *comment = [commentsArray objectAtIndex:[indexPath row]];
    cell.comment = comment;
    cell.mainView = self.view;
    
    cell.lblUserHandle.text = comment.user_handle;
    cell.lblCommentSubject.text = comment.subject;
    cell.txtCommentBody.text = comment.body;
    cell.lblCommentRating.text = [NSString stringWithFormat:@"%d", comment.rating_up - comment.rating_down];

    return cell;
}

@end
