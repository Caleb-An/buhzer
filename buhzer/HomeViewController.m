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
#import "AFNetworking.h"

@interface HomeViewController ()

@end

static NSString * const kClientId = @"742034285387-e2trl98cq24vm07equecdd3o29ff3r4v.apps.googleusercontent.com";
static NSString *const kClientSecret = @"tU5WIgFqhaVtsSZxJ8nptaIC";
static NSString *const kKeychainItemName = @"Buhzer";

@implementation HomeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.hashLabel.text = @"Test";
    self.hashLabel.textAlignment= NSTextAlignmentCenter;
    
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
                    //NSLog(@"%@", description);
                    
                    GTLPlusPersonEmailsItem *emailItem = [person.emails firstObject];
                    //NSLog(@"email:%@", emailItem.value);
                    
                    
                    NSMutableDictionary *dict= [NSMutableDictionary dictionaryWithDictionary:@{
                                                 @"provider": @"GOOGLE",
                                                 @"uid": person.identifier,
                                                 @"name": person.displayName,
                                                 @"firstName": person.name.givenName,
                                                 @"lastName": person.name.familyName,
                                                 @"email": emailItem.value
                                                 }];
                    
                
                    NSURL *URL = [NSURL URLWithString:@"http://ec2-54-69-24-7.us-west-2.compute.amazonaws.com"];
//                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
//                    request.HTTPMethod = @"POST";
                    
                    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:URL];
//                    [objectManager requestWithObject:nil method:RKRequestMethodPOST path:@"http://ec2-54-69-24-7.us-west-2.compute.amazonaws.com" parameters:dict];
//                    objectManager.requestSerializationMIMEType = RKMIMETypeFormURLEncoded;
                    
                    
                    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[User class]];
                    [responseMapping addAttributeMappingsFromArray:@[@"id",
                                                                     @"provider",
                                                                     @"accountType",
                                                                     @"uniqueHash",
                                                                     @"uid",
                                                                     @"name",
                                                                     @"email",
                                                                     @"firstName",
                                                                     @"lastName",
                                                                     @"createdAt"]];
                    
                    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful); // Anything in 2xx
                    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping method:RKRequestMethodAny pathPattern:@"/api/auth/login" keyPath:nil statusCodes:statusCodes];
                    
                    [objectManager addResponseDescriptor:responseDescriptor];
                    
                    [objectManager postObject:nil path:@"/api/auth/login" parameters:dict success:
                     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                        User *user = [result firstObject];
                        
                        NSLog(@"We object mapped the response with the following result: %@", user);
                        NSLog(@"The hash is : %@", user.uniqueHash);
                        [self.hashLabel setText:user.uniqueHash];
                     } failure:^(RKObjectRequestOperation *operation, NSError *failure) {
                         NSLog(@"Shit just exploded: %@", failure);
                     } ];
                }
            }];
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
