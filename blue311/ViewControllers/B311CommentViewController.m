//
//  B311CommentViewController.m
//  blue311
//
//  Created by Thomas DiZoglio on 4/24/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import "B311CommentViewController.h"
#import "MBProgressHUD.h"
#import "B311Comments.h"

@interface B311CommentViewController ()

@property (weak, nonatomic) IBOutlet UITextField *txtSubject;
@property (weak, nonatomic) IBOutlet UITextView *txtBody;

- (IBAction)addbuttonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@end

@implementation B311CommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)addbuttonPressed:(id)sender {

    if (_txtSubject.text == nil || [_txtSubject.text isEqualToString:@""]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Comment Error"
                                                        message:@"Please provide a comment subject"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (_txtBody.text == nil || [_txtBody.text isEqualToString:@""]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Comment Error"
                                                        message:@"Please provide a comment body"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Adding Comment to Location...";
    hud.dimBackground = YES;

    B311User *user = [B311User loadB311User];

    B311Comment *newComment = [B311Comment new];

    [[B311Comments instance] postComment:^(NSString *error) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (!error) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Comments API Error"
                                                                message:error
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            
        } else {
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    } withComment:newComment forUser:user forLocationId:_location_id andWithHUD:hud];
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
