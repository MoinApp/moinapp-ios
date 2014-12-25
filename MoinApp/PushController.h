//
//  PushController.h
//  MoinApp
//
//  Created by Sören Gade on 24/12/14.
//  Copyright (c) 2014 Sören Gade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>

#import "APIClient.h"

@interface PushController : NSObject
+ (instancetype)sharedController;

#pragma mark - User Notifications
- (void)registerForUserNotifications;
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;

#pragma mark - Remote Notifications
- (void)registerForRemoteNotifications;
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

#pragma mark - Send Moin
- (void)sendMoinToUser:(User *)user withCompletion:(APIRequestCompletionHandler)completion;
@end
