//
//  ProviderViewController.m
//  buhzer
//
//  Created by joe student on 10/13/14.
//  Copyright (c) 2014 cs98. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProviderViewController.h"
#import "User.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>
#import "RestKit.h"
#import "AFNetworking.h"

@implementation ProviderViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.queueData = [NSMutableArray arrayWithObjects:@"Xinran", @"Caleb", @"Hongyu", nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// table functions
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.queueData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
    
    cell.textLabel.text = [self.queueData objectAtIndex:indexPath.row];
    return cell;
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

@end