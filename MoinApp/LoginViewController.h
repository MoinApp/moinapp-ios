//
//  LoginViewController.h
//  MoinApp
//
//  Created by Sören Gade on 14/12/14.
//  Copyright (c) 2014 Sören Gade. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

#import "AFNetworking/AFNetworking.h"
#import "APIClient.h"
#import "APIErrorHandler.h"

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UITextField *textfieldLoginUsername;
@property (weak, nonatomic) IBOutlet UITextField *textfieldLoginPassword;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityLogin;
- (IBAction)buttonLoginTouch:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;

@property (weak, nonatomic) IBOutlet UITextField *textfieldSignupUsername;
@property (weak, nonatomic) IBOutlet UITextField *textfieldSignupPassword;
@property (weak, nonatomic) IBOutlet UITextField *textfieldSignupEmail;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activitySignup;
- (IBAction)buttonSignupTouch:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *buttonSignup;
@end
