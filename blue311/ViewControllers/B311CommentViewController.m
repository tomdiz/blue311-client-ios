//
//  B311CommentViewController.m
//  blue311
//
//  Created by Thomas DiZoglio on 4/24/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import "B311CommentViewController.h"

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
    
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
