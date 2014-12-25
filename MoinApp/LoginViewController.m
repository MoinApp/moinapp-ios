//
//  LoginViewController.m
//  MoinApp
//
//  Created by Sören Gade on 14/12/14.
//  Copyright (c) 2014 Sören Gade. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
- (void)textfieldDidBeginEditing:(UITextField *)textfield;
- (void)textfieldDidEndEditing:(UITextField *)textfield;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupTextfields];
    [self setButtonStates];
}
- (void)setupTextfields
{
    // add button state setters
    [self.textfieldLoginUsername addTarget:self
                                    action:@selector(textfieldDidChange:)
                          forControlEvents:UIControlEventEditingChanged];
    [self.textfieldLoginPassword addTarget:self
                                    action:@selector(textfieldDidChange:)
                          forControlEvents:UIControlEventEditingChanged];
    
    [self.textfieldSignupUsername addTarget:self
                                     action:@selector(textfieldDidChange:)
                           forControlEvents:UIControlEventEditingChanged];
    [self.textfieldSignupPassword addTarget:self
                                     action:@selector(textfieldDidChange:)
                           forControlEvents:UIControlEventEditingChanged];
    [self.textfieldSignupEmail addTarget:self
                                  action:@selector(textfieldDidChange:)
                        forControlEvents:UIControlEventEditingChanged];
    
    // make content view scrollable when editing
    [self.textfieldSignupUsername addTarget:self
                                    action:@selector(textfieldDidBeginEditing:)
                           forControlEvents:UIControlEventEditingDidBegin];
    [self.textfieldSignupPassword addTarget:self
                                     action:@selector(textfieldDidBeginEditing:)
                           forControlEvents:UIControlEventEditingDidBegin];
    [self.textfieldSignupEmail addTarget:self
                                     action:@selector(textfieldDidBeginEditing:)
                           forControlEvents:UIControlEventEditingDidBegin];
    [self.textfieldSignupUsername addTarget:self
                                     action:@selector(textfieldDidEndEditing:)
                           forControlEvents:UIControlEventEditingDidEnd];
    [self.textfieldSignupPassword addTarget:self
                                     action:@selector(textfieldDidEndEditing:)
                           forControlEvents:UIControlEventEditingDidEnd];
    [self.textfieldSignupEmail addTarget:self
                                     action:@selector(textfieldDidEndEditing:)
                           forControlEvents:UIControlEventEditingDidEnd];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - View Events

- (IBAction)buttonLoginTouch:(UIButton *)sender {
    NSString *username = self.textfieldLoginUsername.text;
    NSString *password = self.textfieldLoginPassword.text;
    
    // valid?
    [self doLoginWithUsername:username Password:password];
}

- (IBAction)buttonSignupTouch:(UIButton *)sender {
    NSString *username = self.textfieldSignupUsername.text;
    NSString *password = self.textfieldSignupPassword.text;
    NSString *email = self.textfieldSignupEmail.text;
    
    [self doSignupWithUsername:username password:password email:email];
}

#pragma mark TextField Events
- (void)textfieldDidChange:(UITextField*)textfield
{
    [self setButtonStates];
}

- (void)textfieldDidBeginEditing:(UITextField *)textfield
{
    [self addScrollViewContentHeight:80.0 andSetOffsetRelativeToSignupUsername:textfield.frame.origin.y + 80.0];
}
- (void)textfieldDidEndEditing:(UITextField *)textfield
{
    [self addScrollViewContentHeight:-80.0 andSetOffsetRelativeToSignupUsername:textfield.frame.origin.y - 80.0];
}

#pragma mark - Work
#pragma mark View

- (void)setUIEnabled:(BOOL)isEnabled
{
    self.textfieldLoginUsername.enabled = isEnabled;
    self.textfieldLoginPassword.enabled = isEnabled;
    self.buttonLogin.enabled = isEnabled;
    self.textfieldSignupUsername.enabled = isEnabled;
    self.textfieldSignupPassword.enabled = isEnabled;
    self.textfieldSignupEmail.enabled = isEnabled;
    self.buttonSignup.enabled = isEnabled;
}

- (void)setButtonStates
{
    [self setLoginButtonState];
    [self setSignupButtonState];
}
- (void)setLoginButtonState
{
    BOOL hasUsername = ( self.textfieldLoginUsername.text.length > 0 );
    BOOL hasPassword = ( self.textfieldLoginPassword.text.length > 0 );
    
    BOOL enabled = ( hasUsername && hasPassword );
    self.buttonLogin.enabled = enabled;
}
- (void)setSignupButtonState
{
    BOOL hasUsername = ( self.textfieldSignupUsername.text.length > 0 );
    BOOL hasPassword = ( self.textfieldSignupPassword.text.length > 0 );
    BOOL hasEmail = ( self.textfieldSignupEmail.text.length > 0 );
    
    BOOL enabled = ( hasUsername && hasPassword && hasEmail );
    self.buttonSignup.enabled = enabled;
}

- (void)addScrollViewContentHeight:(CGFloat)height andSetOffsetRelativeToSignupUsername:(CGFloat)offset
{
    CGFloat relativeOffset = offset - self.textfieldSignupUsername.frame.origin.y;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.5];
    
    CGSize newSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height + height + relativeOffset);
    self.scrollView.contentSize = newSize;
    
    self.scrollView.contentOffset = CGPointMake(0, relativeOffset);
    [UIView commitAnimations];

}

- (void)done
{
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark Work

- (void)doLoginWithUsername:(NSString *)username Password:(NSString *)password
{
    [self setUIEnabled:NO];
    [self.activityLogin startAnimating];
    
    if ( ![self.textfieldLoginUsername.text isEqualToString:username] ) {
        [self.textfieldLoginUsername setText:username];
    }
    if ( ![self.textfieldLoginPassword.text isEqualToString:password] ) {
        [self.textfieldLoginPassword setText:password];
    }
    
    [self loginWithUsername:username Password:password completion:^(APIError *error, id data) {
        
        [self setUIEnabled:YES];
        [self.activityLogin stopAnimating];
        
        if ( ![APIErrorHandler handleError:error] ) {
            
            BOOL loggedIn = [(NSNumber*)data boolValue];
            
            if ( loggedIn ) {
                // success
                [self done];
            }
            
        }
     }];
}
- (void)loginWithUsername:(NSString *)username Password:(NSString *)password completion:(APIRequestCompletionHandler)completionHandler
{
    [[APIClient client] loginWithUsername:username andPassword:password completion:completionHandler];
}

- (void)doSignupWithUsername:(NSString *)username password:(NSString *)password email:(NSString *)email
{
    [self setUIEnabled:NO];
    [self.activitySignup startAnimating];
    
    if ( ![self.textfieldSignupUsername.text isEqualToString:username] ) {
        self.textfieldSignupUsername.text = username;
    }
    if ( ![self.textfieldSignupPassword.text isEqualToString:password] ) {
        self.textfieldSignupPassword.text = password;
    }
    if ( ![self.textfieldSignupEmail.text isEqualToString:email] ) {
        self.textfieldSignupEmail.text = email;
    }
    
    [self signupWithUsername:username password:password email:email completion:^(APIError *error, id data) {
        
        BOOL signedUp = [(NSNumber*)data boolValue];
        
        [self setUIEnabled:YES];
        [self.activitySignup stopAnimating];
        
        if ( ![APIErrorHandler handleError:error] ) {
            
            if ( signedUp ) {
                // success
                [self done];
            }
            
        }
    }];
}
- (void)signupWithUsername:(NSString *)username password:(NSString *)password email:(NSString *)email completion:(APIRequestCompletionHandler)completion
{
    [[APIClient client] signupWithUsername:username password:password andEmail:email completion:completion];
}

@end
