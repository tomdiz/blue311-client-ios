//
//  B311DetailsViewController.m
//  blue311
//
//  Created by Thomas DiZoglio on 3/30/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import "B311DetailsViewController.h"
#import "B311CommentTableViewCell.h"

@interface B311DetailsViewController () {
    
    NSArray *comments;
}

@property (weak, nonatomic) IBOutlet UITableView *tblComments;
@property (weak, nonatomic) IBOutlet UIImageView *imgLocationIconType;
@property (weak, nonatomic) IBOutlet UITextField *txtTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtStreet;
@property (weak, nonatomic) IBOutlet UITextField *txtCity;
@property (weak, nonatomic) IBOutlet UITextField *txtState;
@property (weak, nonatomic) IBOutlet UITextField *txtZip;

- (IBAction)addCommentButtonPressed:(id)sender;
- (IBAction)titleEditButtonPressed:(id)sender;
- (IBAction)streetEditButtonPressed:(id)sender;
- (IBAction)cityEditButtonPressed:(id)sender;
- (IBAction)stateEditButtonPressed:(id)sender;
- (IBAction)zipEditButtonPressed:(id)sender;

@end

@implementation B311DetailsViewController

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

- (IBAction)addCommentButtonPressed:(id)sender {

}

- (IBAction)titleEditButtonPressed:(id)sender {
    
}

- (IBAction)streetEditButtonPressed:(id)sender {
    
}

- (IBAction)cityEditButtonPressed:(id)sender {
    
}

- (IBAction)stateEditButtonPressed:(id)sender {
    
}

- (IBAction)zipEditButtonPressed:(id)sender {
    
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *MyIdentifier = @"B311CommentIdentifier";
    
    B311CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil) {
        
        cell = [[B311CommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    
    cell.textLabel.text = @"My Text";
    return cell;
}

@end
