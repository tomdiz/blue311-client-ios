//
//  B311CommentTableViewCell.h
//  blue311
//
//  Created by Thomas DiZoglio on 4/1/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "B311Comments.h"

@interface B311CommentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblUserHandle;
@property (weak, nonatomic) IBOutlet UILabel *lblCommentSubject;
@property (weak, nonatomic) IBOutlet UITextView *txtCommentBody;
@property (weak, nonatomic) IBOutlet UILabel *lblCommentRating;

@property (strong, nonatomic) B311Comment *comment;
@property (weak, nonatomic) UIView *mainView;

- (IBAction)ratingArrowUpButtonPressed:(id)sender;
- (IBAction)ratingArrowDownButtonPressed:(id)sender;

@end
