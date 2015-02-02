//
//  HomeViewController.m
//  buhzer
//
//  Created by Caleb on 10/5/14.
//  Copyright (c) 2014 cs98. All rights reserved.
//

#import "HomeViewController.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>
#import "RestKit.h"
#import "AFNetworking.h"

#import "WaitlistQueue.h"

#define TYPE_PENDING 1
#define TYPE_QUEUE 2


@interface HomeViewController ()

@end


@implementation HomeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"refresh"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveBuhz:)
                                                 name:@"buzz"
                                               object:nil];
    
    self.hashLabel.textAlignment= NSTextAlignmentCenter;
    
    if (self.pendingArray == NULL){
        self.pendingArray = [[NSMutableArray alloc] init];
    }
    
    if (self.queueArray == NULL){
        self.queueArray = [[NSMutableArray alloc] init];
    }

    [self login];
}

- (void)login {
    
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
                    NSMutableDictionary *dict= [NSMutableDictionary dictionaryWithDictionary:@{@"provider": @"GOOGLE",
                                                                                               @"uid": person.identifier,
                                                                                               @"name": person.displayName,
                                                                                               @"firstName": person.name.givenName,
                                                                                               @"lastName": person.name.familyName,
                                                                                               @"email": emailItem.value
                                                                                               }];
                    NSURL *URL = [NSURL URLWithString:@"http://ec2-54-187-54-128.us-west-2.compute.amazonaws.com"];
                    
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
                         [self.hashLabel setText:self.user.uniqueHash];
                         
                         [self registerToken];
                         
                         [self refreshTables];
                      
                     } failure:^(RKObjectRequestOperation *operation, NSError *failure) {
                         NSLog(@"Shit just exploded: %@", failure);
                     } ];
                }
            }];
}

- (void)registerToken {
    NSMutableDictionary *dict= [NSMutableDictionary dictionaryWithDictionary:@{@"userId": self.user.id,
                                                                               @"registrationId": [[NSUserDefaults standardUserDefaults] dataForKey:@"deviceToken"],
                                                                               @"platform":@"IOS"
                                                                               }];
    NSURL *URL = [NSURL URLWithString:@"http://ec2-54-187-54-128.us-west-2.compute.amazonaws.com"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:URL];
    
    [httpClient postPath:@"/api/push/register" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"api/push/register Successful");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"api push register failed: %@", error.localizedDescription);
    }];
}

// table functions
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.queueTable){
        return [self.queueArray count];
    }
    return [self.pendingArray count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
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
        cell.delegate = self;
    }
    
    if (tableView == self.pendingTable){
        WaitlistQueue *item = self.pendingArray[indexPath.row];
        cell.textLabel.text = item.waitlist.name;
        cell.detailTextLabel.text = @"so tasty. do accept";
        cell.rightUtilityButtons = [self pendingRightButtons];
        cell.tag = TYPE_PENDING;
    } else {
        WaitlistQueue *item = self.queueArray[indexPath.row];
        cell.textLabel.text = item.waitlist.name;
        cell.detailTextLabel.text = @"est: 10 min";
        cell.tag = TYPE_QUEUE;
    }
    
    return cell;
}

- (NSArray *)pendingRightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                title:@"Accept"];
//    [rightUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
//                                                title:@"Decline"];
    
    return rightUtilityButtons;
}

// For now not used
- (NSArray *)queueRightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                title:@"Remove Me"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Decline"];
    
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
        
        if (tableView == self.queueTable){
            [self.queueArray removeObjectAtIndex:indexPath.row];
        } else {
            [self.pendingArray removeObjectAtIndex:indexPath.row];
        }
        //remove the deleted object from your data source.
        //If your data source is an NSMutableArray, do this
        
        [tableView reloadData]; // tell table to refresh now
    }
    NSLog(@"delete!");
}

- (void)refreshTables {
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
    
    // Create our new waitlist mapping
    RKObjectMapping* waitlistMapping = [RKObjectMapping mappingForClass:[Waitlist class] ];
    // NOTE: When your source and destination key paths are symmetrical, you can use addAttributesFromArray: as a shortcut instead of addAttributesFromDictionary:
    [waitlistMapping addAttributeMappingsFromArray:@[ @"id",
                                                      @"restaurantId",
                                                      @"name"]];
    
    // Create our new waitlist Queue mapping
    RKObjectMapping *waitlistQueueMapping = [RKObjectMapping mappingForClass:[WaitlistQueue class]];
    [waitlistQueueMapping addAttributeMappingsFromArray:@[@"userId"]];
    
    // add property mappings
    [waitlistQueueMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"waitlist"
                                                                                         toKeyPath:@"waitlist"
                                                                                       withMapping:waitlistMapping]];
    [waitlistQueueMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"entry"
                                                                                         toKeyPath:@"entry"
                                                                                       withMapping:entryMapping]];
    
    
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful); // Anything in 2xx
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:waitlistQueueMapping method:RKRequestMethodAny pathPattern:@"/api/waitlists/user" keyPath:nil statusCodes:statusCodes];
    
    NSURL *URL = [NSURL URLWithString:@"http://ec2-54-187-54-128.us-west-2.compute.amazonaws.com"];
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:URL];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    
    [objectManager getObject:nil path:@"/api/waitlists/user" parameters:dict success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
         NSLog(@"gottem!");
         self.wQArray = [[result array] mutableCopy];
         [self refreshTableViews];
         
     } failure:^(RKObjectRequestOperation *operation, NSError *failure) {
         NSLog(@"Shit just exploded: %@", failure);
     } ];
}

- (void)refreshTableViews {
    
    [self.pendingArray removeAllObjects];
    [self.queueArray removeAllObjects];
    
    for ( int i = 0; i < self.wQArray.count;i++ ){
        WaitlistQueue *item = [self.wQArray objectAtIndex:i];
        if (item.entry.isActive == YES){
            [self.queueArray addObject:item];
        } else {
            [self.pendingArray addObject:item];
        }
    }

    [self.pendingTable reloadData];
    [self.queueTable reloadData];
   
}

- (void)dequeueWithWaitlistId: (NSString *) waitlistId {
    NSMutableDictionary *dict= [NSMutableDictionary dictionaryWithDictionary:@{
                                                                               @"userId": self.user.id,
                                                                               @"waitlistId": waitlistId }];
  
    NSURL *URL = [NSURL URLWithString:@"http://ec2-54-187-54-128.us-west-2.compute.amazonaws.com"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:URL];
    
    [httpClient postPath:@"/api/waitlists/queue/confirm" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"dequeue successful");
        [self refreshTables];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"dequeue failed: %@", error.localizedDescription);
    }];
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    
    NSMutableArray *currArray;
    UITableView *currTable;
    
    if (cell.tag == TYPE_PENDING){
        currArray = self.pendingArray;
        currTable = self.pendingTable;
    } else {
        currArray = self.queueArray;
        currTable = self.queueTable;
    }
    
    switch (index) {
        case 0:
            if(cell.tag == TYPE_PENDING){
                NSIndexPath *cellIndexPath = [currTable indexPathForCell:cell];
                WaitlistQueue *item = [currArray objectAtIndex:cellIndexPath.row];
                [self dequeueWithWaitlistId: item.entry.waitlistId];
            }
            break;
        case 1:
        {
            // Delete button was pressed
            NSIndexPath *cellIndexPath = [currTable indexPathForCell:cell];
            
            [currArray removeObjectAtIndex:cellIndexPath.row];
            [currTable deleteRowsAtIndexPaths:@[cellIndexPath]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        default:
            break;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    // If you don't remove yourself as an observer, the Notification Center
    // will continue to try and send notification objects to the deallocated
    // object.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// This isn't getting called right now for some reason
- (id) init
{
    self = [super init];
    NSLog(@"before gets called\n\n\n\n");
    if (!self) return nil;
    
    // Add this instance of TestClass as an observer of the TestNotification.
    // We tell the notification center to inform us of "TestNotification"
    // notifications using the receiveTestNotification: selector. By
    // specifying object:nil, we tell the notification center that we are not
    // interested in who posted the notification. If you provided an actual
    // object rather than nil, the notification center will only notify you
    // when the notification was posted by that particular object.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"refresh"
                                               object:nil];
    NSLog(@"got added to notif\n\n\n\n");
    return self;
}

- (void) receiveNotification:(NSNotification *) notification
{
    NSLog(@"refresh notif received.");
    [self refreshTables];
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    if ([[notification name] isEqualToString:@"refresh"]){
 
    }
        
}

- (void) receiveBuhz:(NSNotification *) notification {
    NSLog(@"buzz received");
    [self displayBuhz];
}
- (void) displayBuhz {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You got Buhzed!"
                                                    message:nil
                                                   delegate:nil
                                          cancelButtonTitle:@"Cool!"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
