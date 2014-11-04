//
//  ProviderViewController.m
//  buhzer
//
//  Created by joe student on 10/13/14.
//  Copyright (c) 2014 cs98. All rights reserved.
//

#import "ProviderViewController.h"
#import <Foundation/Foundation.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>
#import "RestKit.h"
#import "AFNetworking.h"
#import "SWTableViewCell.h"
#import "Entry.h"

@implementation ProviderViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"refresh"
                                               object:nil];
    
    self.inputField.delegate = self;
    
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
                    
                    GTLPlusPersonEmailsItem *emailItem = [person.emails firstObject];
                    
                    NSMutableDictionary *dict= [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                               @"provider": @"GOOGLE",
                                                                                               @"uid": person.identifier,
                                                                                               @"name": person.displayName,
                                                                                               @"firstName": person.name.givenName,
                                                                                               @"lastName": person.name.familyName,
                                                                                               @"email": emailItem.value
                                                                                               }];
                    NSLog(@"%@", dict);
                    
                    NSURL *URL = [NSURL URLWithString:@"http://ec2-54-69-24-7.us-west-2.compute.amazonaws.com"];
                    
                    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:URL];
                    
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
                         self.user = [result firstObject];
                         
                         NSMutableDictionary *dict= [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                    @"userId": self.user.id,
                                                                                                    @"registrationId": [[NSUserDefaults standardUserDefaults] dataForKey:@"deviceToken"],
                                                                                                    @"platform":@"IOS"}];
                         NSLog(@"%@", dict);
                         NSURL *URL = [NSURL URLWithString:@"http://ec2-54-69-24-7.us-west-2.compute.amazonaws.com"];
                         
                         AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:URL];
                         
                         [httpClient postPath:@"/api/push/register" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
                             
                             NSLog(@"api/push/register Successful, response '%@'", responseObject);
                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                             NSLog(@"api push register failed: %@", error.localizedDescription);
                         }];
                         
                         NSLog(@"The id is : %@", self.user.id);
            
                     } failure:^(RKObjectRequestOperation *operation, NSError *failure) {
                         NSLog(@"Shit just exploded: %@", failure);
                     } ];
                }
            }];

    
    self.queueData = [[NSMutableArray alloc] init];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addToQueueButtonPressed:(id)sender {
    [self queueNext];
}

- (void) queueNext {
    
    [self.inputField resignFirstResponder];
    
    if([self.inputField hasText]){
        NSString *inputHash = self.inputField.text;
        [self.inputField setText:@""];
        
        
        NSMutableDictionary *dict= [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                   @"uniqueHash": inputHash,
                                                                                   @"waitlistId": @"1",
                                                                                   @"providerUserId":self.user.id
                                                                                   }];
        
        NSURL *URL = [NSURL URLWithString:@"http://ec2-54-69-24-7.us-west-2.compute.amazonaws.com"];
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:URL];
        
        [httpClient postPath:@"/api/waitlists/queue" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self refreshTable];
            NSLog(@"Queue Req Successful");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        }];
    }
}

- (void) refreshTable {
    
    NSMutableDictionary *dict= [NSMutableDictionary dictionaryWithDictionary:@{@"userId": self.user.id}];
    
    // Create our new entry mapping
    RKObjectMapping* entryMapping = [RKObjectMapping mappingForClass:[Entry class] ];
    // NOTE: When your source and destination key paths are symmetrical, you can use addAttributesFromArray: as a shortcut instead of addAttributesFromDictionary:
    [entryMapping addAttributeMappingsFromArray:@[ @"id",
                                                   @"waitlistId",
                                                   @"providerUserId",
                                                   @"clientUserId",
                                                   @"createdAt",
                                                   @"isActive",
                                                   @"isBuzzed"]];
    
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful); // Anything in 2xx
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:entryMapping method:RKRequestMethodAny pathPattern:@"/api/waitlists/user" keyPath:nil statusCodes:statusCodes];
    
    NSURL *URL = [NSURL URLWithString:@"http://ec2-54-69-24-7.us-west-2.compute.amazonaws.com"];
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:URL];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    
    [objectManager getObject:nil path:@"/api/waitlists/user" parameters:dict success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
         NSLog(@"gottem!");
         self.queueData = [[result array] mutableCopy];
         [self.table reloadData];
         
     } failure:^(RKObjectRequestOperation *operation, NSError *failure) {
         NSLog(@"Shit just exploded: %@", failure);
     } ];

}

// table functions
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.queueData count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        //cell.leftUtilityButtons = [self leftButtons];
        cell.rightUtilityButtons = [self rightButtons];
        cell.delegate = self;
    }
    
    Entry *entry = self.queueData[indexPath.row];
    cell.textLabel.text = [@"Mister " stringByAppendingString:entry.waitlistId];
    cell.detailTextLabel.text = entry.clientUserId;
    
    return cell;
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                title:@"Buhz"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];
    
    return rightUtilityButtons;
}

// temp not used
- (NSArray *)leftButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0]
                                                icon:[UIImage imageNamed:@"check.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:1.0]
                                                icon:[UIImage imageNamed:@"clock.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0]
                                                icon:[UIImage imageNamed:@"cross.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.55f green:0.27f blue:0.07f alpha:1.0]
                                                icon:[UIImage imageNamed:@"list.png"]];
    
    return leftUtilityButtons;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // true to be able to remove users
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //remove the deleted object from your data source.
        //If your data source is an NSMutableArray, do this
        [self.queueData removeObjectAtIndex:indexPath.row];
        [tableView reloadData]; // tell table to refresh now
    }
    NSLog(@"delete!");
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
            NSLog(@"Buhz button was pressed");
            break;
        case 1:
        {
            
//            NSMutableDictionary *dict= [NSMutableDictionary dictionaryWithDictionary:@{
//                                                                                       @"uniqueHash": inputHash,
//                                                                                       @"waitlistId": @"1"
//                                                                                       }];
//            
//            NSURL *URL = [NSURL URLWithString:@"http://ec2-54-69-24-7.us-west-2.compute.amazonaws.com"];
//            
//            AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:URL];
//            
//            [httpClient postPath:@"/api/waitlists/queue" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                
//                NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//                UserInfo *user = [[UserInfo alloc] initWithName:responseStr withHashID:inputHash];
//                [self.queueData addObject:user];
//                
//                [self.table reloadData];
//                NSLog(@"Request Successful, response '%@'", responseStr);
//            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
//            }];
            
            // Delete button was pressed
            NSIndexPath *cellIndexPath = [self.table indexPathForCell:cell];
            
            [self.queueData removeObjectAtIndex:cellIndexPath.row];
            [self.table deleteRowsAtIndexPaths:@[cellIndexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        default:
            break;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.inputField) {
        [self queueNext];
        return NO;
    }
    return YES;
}

- (void) receiveNotification:(NSNotification *) notification
{
    NSLog(@"refresh notif received.");
    [self refreshTable];
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    if ([[notification name] isEqualToString:@"refresh"]){
        
    }
    
}

@end