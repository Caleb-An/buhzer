//
//  ProviderViewController.h
//  buhzer
//
//  Created by joe student on 10/5/14.
//  Copyright (c) 2014 cs98. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>
#import "SWTableViewCell.h"
#import "User.h"

@interface ProviderViewController : UIViewController <SWTableViewCellDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) GTMOAuth2Authentication *auth;
@property (strong, nonatomic) User *user;

@property (strong, nonatomic) NSMutableArray *queueData;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UITextField *inputField;

@end
