//
//  SelectionViewController.h
//  buhzer
//
//  Created by joe student on 2/1/15.
//  Copyright (c) 2015 cs98. All rights reserved.
//

#import "SWTableViewCell.h"
#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>
#import "User.h"
#import "Restaurant.h"

@interface SelectionViewController : UIViewController <SWTableViewCellDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) GTMOAuth2Authentication *auth;
@property (strong, nonatomic) User *user;

@property (strong, nonatomic) NSMutableArray *queueData;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UITextField *inputField;

@end

