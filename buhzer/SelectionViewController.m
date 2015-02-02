//
//  SelectionViewController.m
//  buhzer
//
//  Created by joe student on 2/1/15.
//  Copyright (c) 2015 cs98. All rights reserved.
//

#import "SelectionViewController.h"
#import <Foundation/Foundation.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>
#import "RestKit.h"
#import "AFNetworking.h"
#import "SWTableViewCell.h"
#import "Entry.h"

@interface SelectionViewController ()

@end


@implementation SelectionViewController




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
                    
                    NSMutableDictionary *dict= [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                               @"userId": person.identifier
                                                                                               }];
                    
                    NSURL *URL = [NSURL URLWithString:@"http://ec2-54-187-54-128.us-west-2.compute.amazonaws.com"];
                    
                    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:URL];
                    
                    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[Restaurant class]];
                    [responseMapping addAttributeMappingsFromArray:@[@"id",
                                                                     @"name",
                                                                     @"createdAt",
                                                                     @"photo"]];
                    
                    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful); // Anything in 2xx
                    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping method:RKRequestMethodAny pathPattern:@"/api/restaurants" keyPath:nil statusCodes:statusCodes];
                    
                    [objectManager addResponseDescriptor:responseDescriptor];
                    
                    [objectManager postObject:nil path:@"/api/restaurants" parameters:dict success:
                     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                         NSLog(@"RESULT BOYS: %@", result);
                         
                         ///// add restaurants to table 
                         self.queueData = [[result array] mutableCopy];
                         [self.table reloadData];
                         
                         NSMutableDictionary *dict= [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                    @"userId": self.user.id,
                                                                                                    @"registrationId": [[NSUserDefaults standardUserDefaults] dataForKey:@"deviceToken"],
                                                                                                    @"platform":@"IOS"}];
                         NSLog(@"WHERE IS THIS: %@", dict);
                         NSURL *URL = [NSURL URLWithString:@"http://ec2-54-187-54-128.us-west-2.compute.amazonaws.com"];
                         
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
                                                                                   @"waitlistId": @"2",
                                                                                   @"providerUserId":self.user.id
                                                                                   }];
        
        NSURL *URL = [NSURL URLWithString:@"http://ec2-54-187-54-128.us-west-2.compute.amazonaws.com"];
        
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
    
    NSMutableDictionary *dict= [NSMutableDictionary dictionaryWithDictionary:@{@"waitlistId": @"2"}];
    
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
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:entryMapping
                                                                                            method:RKRequestMethodAny
                                                                                       pathPattern:@"/api/entries"
                                                                                           keyPath:nil
                                                                                       statusCodes:statusCodes];
    
    NSURL *URL = [NSURL URLWithString:@"http://ec2-54-187-54-128.us-west-2.compute.amazonaws.com"];
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:URL];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    
    [objectManager getObject:nil path:@"/api/entries" parameters:dict success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
         NSLog(@"table success! %@", [[result array] mutableCopy]);
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
    cell.textLabel.text = [@"Customer " stringByAppendingString:entry.id];
    cell.detailTextLabel.text = entry.clientUserId;
    
    cell.backgroundColor = [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0];
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    //TODO: load ProviderView with the selected waitlist
    
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
