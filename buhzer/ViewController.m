//
//  ViewController.m
//  buhzer
//
//  Created by Caleb on 9/30/14.
//  Copyright (c) 2014 cs98. All rights reserved.
//

#import "ViewController.h"
#import "HomeViewController.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>

@interface ViewController ()

@end

static NSString * const kClientId = @"742034285387-e2trl98cq24vm07equecdd3o29ff3r4v.apps.googleusercontent.com";
static NSString *const kClientSecret = @"tU5WIgFqhaVtsSZxJ8nptaIC";
static NSString *const kKeychainItemName = @"Buhzer";

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    //signIn.shouldFetchGoogleUserEmail = YES;  // Uncomment to get the user's email
    
    // You previously set kClientId in the "Initialize the Google+ client" step
    signIn.clientID = kClientId;
    
    // Uncomment one of these two statements for the scope you chose in the previous step
    //signIn.scopes = @[ kGTLAuthScopePlusLogin ];  // "https://www.googleapis.com/auth/plus.login" scope
    signIn.scopes = @[ @"profile" ];            // "profile" scope
    
    // Get email. 
    signIn.shouldFetchGoogleUserEmail = YES;
    // Optional: declare signIn.actions, see "app activities"
    signIn.delegate = self;
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    
    HomeViewController *obj;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"restaurant_mode"]) {
           obj = [storyboard instantiateViewControllerWithIdentifier:@"provider"];
    } else {
        obj = [storyboard instantiateViewControllerWithIdentifier:@"home"];
    }

    
    
    obj.auth = auth;
    self.navigationController.navigationBarHidden=YES;
    [self.navigationController pushViewController:obj animated:YES];
}

- (void)presentSignInViewController:(UIViewController *)viewController {
    // This is an example of how you can implement it if your app is navigation-based.
    [[self navigationController] pushViewController:viewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
