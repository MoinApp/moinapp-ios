//
//  AppDelegate.m
//  MoinApp
//
//  Created by Sören Gade on 14/12/14.
//  Copyright (c) 2014 Sören Gade. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self setUIColors];
    
    // Override point for customization after application launch.
    return YES;
}

- (void)setUIColors
{
    // corresponding to the Android App
    [self.window setTintColor:[Constants styleColor]];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initializeGoogleAnalytics];
    
    NSDictionary *remoteNotificationInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if ( remoteNotificationInfo ) {
        NSLog(@"Remote Notification: %@", remoteNotificationInfo);
        [[PushController sharedController] application:application didReceiveRemoteNotification:remoteNotificationInfo];
    }
    
    return YES;
}
- (void)initializeGoogleAnalytics
{
    // track all uncaught exceptions
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // set dispatch interval to x seconds
    [GAI sharedInstance].dispatchInterval = 5.0;
    
    // set tracking ID
    [[GAI sharedInstance] trackerWithTrackingId:[Constants googleAnalyticsTrackingID]];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // reset badge number
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication*)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}
- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

#pragma mark - APN (Push)
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [[PushController sharedController] application:application didRegisterUserNotificationSettings:notificationSettings];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[PushController sharedController] application:application didFailToRegisterForRemoteNotificationsWithError:error];
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[PushController sharedController] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[PushController sharedController] application:application didReceiveRemoteNotification:userInfo];
}

@end
