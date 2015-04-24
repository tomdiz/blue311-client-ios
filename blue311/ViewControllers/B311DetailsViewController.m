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
#import "B311CommentViewController.h"

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
@property (weak, nonatomic) IBOutlet UILabel *lblUserCommentCount;

- (IBAction)addCommentButtonPressed:(id)sender;
- (IBAction)editButtonPressed:(id)sender;
- (IBAction)closeButtonPressed:(id)sender;

@end

@implementation B311DetailsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    locationEdited = NO;
    
    // NOTE(tsd): Need to load the corrcet icon for location type - Parking, General, Entrace, ramp, etc....
    // imgLocationIconType
    
    _txtTitle.text = _location_data.title == nil ? @"Name" : _location_data.title;
    _txtCity.text = _location_data.city == nil ? @"City" : _location_data.city;
    _txtAddress.text = _location_data.address == nil ? @"Address" : _location_data.address;
    _txtState.text = _location_data.state == nil ? @"State" : _location_data.state;
    _txtZip.text = _location_data.zip == nil ? @"Zip" : _location_data.zip;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

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
                
                _lblUserCommentCount.text = @"User Comments: None";
            }
            else {
                
                _lblUserCommentCount.text = [NSString stringWithFormat:@"User Comments: %lu", (unsigned long)commentsArray.count];
                [_tblComments reloadData];
            }
        }
        
    } forLocationId:_location_data.id andWithHUD:hud];
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

    // Add a new comment to the array
    // Then sync aray value if new
    
    // shit

    B311CommentViewController *commentViewController = (B311CommentViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"B311CommentViewController"];
    commentViewController.location_id = _location_data.id;
    [self presentViewController:commentViewController animated:YES completion:nil];

    /*
     @property (strong, nonatomic) NSString *id;
     @property (strong, nonatomic) NSString *user_handle;
     @property (strong, nonatomic) NSString *location_id;
     @property (strong, nonatomic) NSDate *created;
     @property (strong, nonatomic) NSString *subject;
     @property (strong, nonatomic) NSString *body;
     @property (nonatomic) int rating_down;
     @property (nonatomic) int rating_up;
    */
    
    // Need a subject and body - get handle from user - Do a rating of "1" (up not down)
    
    //*********
    // id and created come from server. I should input on another screen and then resynch
    //*********
    
    
    locationEdited = NO;
}

- (IBAction)editButtonPressed:(id)sender {
    
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
    else {
        
        [self dismissViewControllerAnimated:YES completion:nil];
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
