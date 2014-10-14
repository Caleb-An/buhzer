//
//  ProviderViewController.h
//  buhzer
//
//  Created by joe student on 10/5/14.
//  Copyright (c) 2014 cs98. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>

@interface ProviderViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *queueData;
@property (strong, nonatomic) GTMOAuth2Authentication *auth;

@end
