//
//  PushController.m
//  MoinApp
//
//  Created by Sören Gade on 24/12/14.
//  Copyright (c) 2014 Sören Gade. All rights reserved.
//

#import "PushController.h"

@interface PushController ()
{
    UIUserNotificationSettings *_userNotificationSettings;
}
@end

@implementation PushController

#pragma mark - Instance

+ (instancetype)sharedController
{
    static PushController *controller;
    
    static dispatch_once_t dispatch_token;
    dispatch_once(&dispatch_token, ^{
        controller = [[PushController alloc] init];
    });
    
    return controller;
}

- (instancetype)init
{
    if ( self = [super init] ) {
        // setup user notification settings
        UIUserNotificationType notificationType = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        _userNotificationSettings = [UIUserNotificationSettings settingsForTypes:notificationType categories:nil];
    }
    
    return self;
}

#pragma mark - User Notifications
- (void)registerForUserNotifications
{
    [[UIApplication sharedApplication] registerUserNotificationSettings:_userNotificationSettings];
}
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    if ( notificationSettings.types == _userNotificationSettings.types ) {
        NSLog(@"Successfully got user notification rights.");
    } else {
        NSLog(@"Only have these user notification rights: %ld", (long)_userNotificationSettings.types);
    }
    
    [self registerForRemoteNotifications];
}

#pragma mark - Remote Notifications
- (void)registerForRemoteNotifications
{
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to register for Push: %@", error);
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"Device token: %@", deviceToken);
    
    [[APIClient client] registerForRemoteNotificationsWithDeviceToken:deviceToken withCompletion:^(APIError *error, id response) {
        NSLog(@"Registration for Push: %@, %@", error.error, response);
    }];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Received Remote Notification. Info: %@", userInfo);
    
    if ( application.applicationState == UIApplicationStateActive ) {
        [[[UIAlertView alloc] initWithTitle:@"Moin"
                                    message:@"Received moin."
                                   delegate:nil
                          cancelButtonTitle:@"Close"
                          otherButtonTitles:nil]
         show];
    }
}

@end
