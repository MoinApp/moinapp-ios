//
//  MainTableViewController.h
//  MoinApp
//
//  Created by Sören Gade on 14/12/14.
//  Copyright (c) 2014 Sören Gade. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit+AFNetworking.h>
#import <QuartzCore/CALayer.h>
#import <HTProgressHUD/HTProgressHUD.h>
#import <HTProgressHUD/HTProgressHUDFadeZoomAnimation.h>
#import <HTProgressHUD/HTProgressHUDRingIndicatorView.h>
#import <NSDate+DateTools.h>
#import "Constants.h"
#import "APIClient.h"
#import "APIErrorHandler.h"
#import "LoginViewController.h"
#import "User.h"

@interface MainTableViewController : UITableViewController <UISearchBarDelegate, UIAlertViewDelegate>

- (void)applicationDidBecomeActive:(UIApplication *)application;

- (IBAction)buttonLogout:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@end
