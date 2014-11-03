//
//  AppDelegate.m
//  buhzer
//
//  Created by Caleb on 9/30/14.
//  Copyright (c) 2014 cs98. All rights reserved.
//

#import "AppDelegate.h"
#import <GooglePlus/GooglePlus.h>


static NSString * const kClientId = @"742034285387-e2trl98cq24vm07equecdd3o29ff3r4v.apps.googleusercontent.com";
static NSString *const kClientSecret = @"tU5WIgFqhaVtsSZxJ8nptaIC";
static NSString *const kKeychainItemName = @"Buhzer";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self registerNotificationSettingsForApp:application];
    // Override point for customization after application launch.
    return YES;
}

- (void)registerNotificationSettingsForApp:application {

    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        // iOS 8 method
        UIUserNotificationType types = UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *mySettings =
        [UIUserNotificationSettings settingsForTypes:types categories:nil];
        
        [application registerUserNotificationSettings:mySettings];
        [application registerForRemoteNotifications];
        
    } else {
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationType)
         (UIRemoteNotificationTypeBadge |
          UIRemoteNotificationTypeSound |
          UIRemoteNotificationTypeAlert)];
        
    }
    
    
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:@"deviceToken"];
    NSLog(@"deviceToken registered.");
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application: (UIApplication *)application
            openURL: (NSURL *)url
  sourceApplication: (NSString *)sourceApplication
         annotation: (id)annotation {
    return [GPPURLHandler handleURL:url
                  sourceApplication:sourceApplication
                         annotation:annotation];
}

@end
