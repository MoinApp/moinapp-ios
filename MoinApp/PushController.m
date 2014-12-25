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
    
    AVAudioPlayer *audioPlayer;
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
    
    NSDictionary *apsDict = [userInfo objectForKey:@"aps"];
    NSString *soundName = [apsDict objectForKey:@"sound"];
    
    NSDictionary *senderDict = [userInfo objectForKey:@"sender"];
    User *sender = [[User alloc] initWithDictionary:senderDict];
    
    [self application:application didReceiveMoinFromUser:sender withSoundfile:soundName];
}
- (void)application:(UIApplication *)application didReceiveMoinFromUser:(User *)user withSoundfile:(NSString *)soundfileName
{
    if ( application.applicationState == UIApplicationStateActive || application.applicationState == UIApplicationStateInactive ) {
        [self displayMoin:user soundName:soundfileName];
    }
}

- (void)displayMoin:(User *)sender soundName:(NSString *)soundName
{
    NSString *body = [NSString stringWithFormat:NSLocalizedString(@"from %@", @"Description text when having received a Moin. %@ is the user."), sender.username];
    __block NSString *buttonTitleSendMoin = NSLocalizedString(@"ReMoin", @"Verb to send back a Moin.");
    
    [self playSound:soundName];
    [UIAlertView showWithTitle:NSLocalizedString(@"Moin", @"Moin")
                       message:body
             cancelButtonTitle:NSLocalizedString(@"Dismiss", @"Close a notification dialog.")
             otherButtonTitles:@[buttonTitleSendMoin]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if ( [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:buttonTitleSendMoin] ) {
                              [self sendMoinToUser:sender withCompletion:nil];
                          }
                      }];
}
- (void)playSound:(NSString *)filename
{
    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
    
    if ( [[NSFileManager defaultManager] fileExistsAtPath:filePath] ) {
        NSURL *fileURL = [NSURL URLWithString:filePath];
        NSError *error = nil;
        
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
        
        if ( error ) {
            NSLog(@"Error loading sound file \"%@\": %@", filePath, error);
        } else {
            [audioPlayer play];
        }
    } else {
        NSLog(@"Notification sound not found.");
    }
}

#pragma mark - Send Moin

- (void)sendMoinToUser:(User *)user withCompletion:(APIRequestCompletionHandler)completion;
{
    [[APIClient client] moinUser:user completion:completion];
}

@end
