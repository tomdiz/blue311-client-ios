//
//  B311CommentTableViewCell.m
//  blue311
//
//  Created by Thomas DiZoglio on 4/1/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import "B311CommentTableViewCell.h"
#import "B311Comments.h"

@implementation B311CommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)ratingArrowUpButtonPressed:(id)sender {
 
    B311User *user = [B311User loadB311User];
    if (user == nil) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Rating Comments"
                                                            message:@"You need to create a Profile before you can rate comments"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_mainView animated:YES];
    hud.labelText = @"Rating Up Comments...";
    hud.dimBackground = YES;
    
    [[B311Comments instance] postCommentRatingUp:^(NSString *error) {
        
        [MBProgressHUD hideAllHUDsForView:_mainView animated:YES];
        
        if (!error) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Comments API Error"
                                                                message:error
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            
        } else {
            
        }
        
    } withCommentId:_comment.id forUser:user andWithHUD:hud];
}

- (IBAction)ratingArrowDownButtonPressed:(id)sender {
    
    B311User *user = [B311User loadB311User];
    if (user == nil) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Rating Comments"
                                                            message:@"You need to create a Profile before you can rate comments"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_mainView animated:YES];
    hud.labelText = @"Rating Down Comments...";
    hud.dimBackground = YES;
    
    [[B311Comments instance] postCommentRatingDown:^(NSString *error) {
        
        [MBProgressHUD hideAllHUDsForView:_mainView animated:YES];
        
        if (!error) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Comments API Error"
                                                                message:error
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            
        } else {
            
        }
        
    } withCommentId:_comment.id forUser:user andWithHUD:hud];
}

@end
