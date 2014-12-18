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
    // Teddy
    /* UIColor *tintColor = [UIColor colorWithRed:255/255 green:40/255 blue:0/255 alpha:1.0];
    UIColor *backColor = [UIColor colorWithRed:2/255 green:88/255 blue:117/255 alpha:1.0]; */
    //
    UIColor *tintColor = [UIColor colorWithRed:159.0f/255 green:0.0f/255 blue:19.0f/255 alpha:1.0];
    
    [self.window setTintColor:tintColor];
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
    //MainTableViewController *view = (MainTableViewController *)self.window.rootViewController;
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    MainTableViewController *view = (MainTableViewController *)navController.topViewController;
    [view applicationDidBecomeActive:application];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
