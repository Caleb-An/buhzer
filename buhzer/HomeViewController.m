//
//  HomeViewController.m
//  buhzer
//
//  Created by Caleb on 10/5/14.
//  Copyright (c) 2014 cs98. All rights reserved.
//

#import "HomeViewController.h"
#import "User.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>
#import "RestKit.h"

@interface HomeViewController ()

@end

static NSString * const kClientId = @"742034285387-e2trl98cq24vm07equecdd3o29ff3r4v.apps.googleusercontent.com";
static NSString *const kClientSecret = @"tU5WIgFqhaVtsSZxJ8nptaIC";
static NSString *const kKeychainItemName = @"Buhzer";

@implementation HomeViewController


// http://ec2-54-69-24-7.us-west-2.compute.amazonaws.com/api/auth/login
// User.AccountProvider.GOOGLE.name(),
// user.getId(),
// user.getDisplayName(),
// user.getName().getGivenName(),
// user.getName().getFamilyName(),
// Plus.AccountApi.getAccountName(getPlusClient())

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSLog(@"Here we go Mario!");
    self.hashLabel.text = @"Test";
    
    GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
    plusService.retryEnabled = YES;
    
    [plusService setAuthorizer:self.auth];
    
    GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
    
    [plusService executeQuery:query
            completionHandler:^(GTLServiceTicket *ticket,
                                GTLPlusPerson *person,
                                NSError *error) {
                if (error) {
                    GTMLoggerError(@"Error: %@", error);
                } else {
                    // Retrieve the display name and "about me" text
                    
                    
                    NSString *description = [NSString stringWithFormat:
                                             @"%@\n%@", person.displayName,
                                             person.aboutMe];
                    NSLog(@"%@", description);
                    
                    GTLPlusPersonEmailsItem *emailItem = [person.emails firstObject];
                    NSLog(@"email:%@", emailItem.value);
                    RKObjectMapping* userMapping = [RKObjectMapping mappingForClass:[User class]];
                    [userMapping addAttributeMappingsFromDictionary:@{
                                                                      @"provider": @"GOOGLE",
                                                                      @"uid": person.identifier,
                                                                      @"name": person.displayName,
                                                                      @"firstName": person.name.givenName,
                                                                      @"lastName": person.name.familyName,
                                                                      @"email": emailItem.value
                                                                      }];
                    
                    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping method:RKRequestMethodPOST pathPattern:nil keyPath:@"articles" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
                    
                    NSURL *URL = [NSURL URLWithString:@"http://ec2-54-69-24-7.us-west-2.compute.amazonaws.com/api/auth/login"];
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
                    request.HTTPMethod = @"POST";
                    
                    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor ]];
                    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                        
                        NSLog(@"Much success."); 
                        
                        
                    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                        NSLog(@"Operation failed with error: %@", error);
                    }];
                    
                    [objectRequestOperation start];                }
            }];
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
