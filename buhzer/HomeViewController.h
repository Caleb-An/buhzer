//
//  HomeViewController.h
//  buhzer
//
//  Created by Caleb on 10/5/14.
//  Copyright (c) 2014 cs98. All rights reserved.
//


#import "SWTableViewCell.h"
#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>
#import "User.h"

@interface HomeViewController : UIViewController <SWTableViewCellDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *hashLabel;
@property (strong, nonatomic) GTMOAuth2Authentication *auth;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSMutableArray *wQArray; 

@property (strong, nonatomic) NSMutableArray *pendingArray;
@property (strong, nonatomic) NSMutableArray *queueArray;

@property (weak, nonatomic) IBOutlet UITableView *pendingTable;
@property (weak, nonatomic) IBOutlet UITableView *queueTable;

// this will sign up for notifications properly     
- (id) init;

@end
