//
//  ViewController.h
//  buhzer
//
//  Created by Caleb on 9/30/14.
//  Copyright (c) 2014 cs98. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>

@class GPPSignInButton;

@interface ViewController : UIViewController <GPPSignInDelegate>

@property (retain, nonatomic) IBOutlet GPPSignInButton *signInButton;

@end
