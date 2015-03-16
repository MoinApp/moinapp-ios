//
//  MainTableViewController.h
//  MoinApp
//
//  Created by Sören Gade on 14/12/14.
//  Copyright (c) 2014 Sören Gade. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>
#import <UIKit+AFNetworking.h>
#import <QuartzCore/CALayer.h>
#import <HTProgressHUD/HTProgressHUD.h>
#import <HTProgressHUD/HTProgressHUDFadeZoomAnimation.h>
#import <HTProgressHUD/HTProgressHUDRingIndicatorView.h>
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>
#import <NSDate+DateTools.h>
#import "Constants.h"
#import "APIClient.h"
#import "APIErrorHandler.h"
#import "LoginViewController.h"
#import "User.h"
#import "PushController.h"

@interface MainTableViewController : UITableViewController <UISearchBarDelegate>

- (IBAction)buttonLogout:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@end
