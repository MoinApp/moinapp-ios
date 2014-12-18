//
//  LoginViewController.m
//  MoinApp
//
//  Created by Sören Gade on 14/12/14.
//  Copyright (c) 2014 Sören Gade. All rights reserved.
//

#import "LoginViewController.h"

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupTextfields];
    [self setButtonStates];
}
- (void)setupTextfields
{
    [self.textfieldLoginPassword addTarget:self
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

#pragma mark View Events

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

- (void)textfieldDidChange:(UITextField*)textfield
{
    [self setButtonStates];
}

#pragma mark View Work

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
    
    [self loginWithUsername:username Password:password completion:^(NSError *error, NSDictionary *response, id data) {
        
        BOOL loggedIn = [(NSNumber*)data boolValue];
        
        [self setUIEnabled:YES];
        [self.activityLogin stopAnimating];
        
        if ( ![APIErrorHandler handleError:error withResponse:response] ) {
            
            if ( !loggedIn ) {
                // error
                [[[UIAlertView alloc] initWithTitle:[response objectForKey:@"code"]
                                            message:[response objectForKey:@"message"]
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            } else {
                // success
                NSString *session = [response objectForKey:@"message"];
                [[APIClient client] setSession:session];
                
                [self dismissViewControllerAnimated:true completion:nil];
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
    
    [self signupWithUsername:username password:password email:email completion:^(NSError *error, NSDictionary *response, id data) {
        
        BOOL signedUp = [(NSNumber*)data boolValue];
        
        [self setUIEnabled:YES];
        [self.activitySignup stopAnimating];
        
        if ( ![APIErrorHandler handleError:error withResponse:response] ) {
            
            if ( !signedUp ) {
                // error
                [[[UIAlertView alloc] initWithTitle:[response objectForKey:@"code"]
                                            message:[response objectForKey:@"message"]
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            } else {
                // success
                NSString *session = [response objectForKey:@"message"];
                [[APIClient client] setSession:session];
                
                [self dismissViewControllerAnimated:true completion:nil];
            }
            
        }
    }];
}
- (void)signupWithUsername:(NSString *)username password:(NSString *)password email:(NSString *)email completion:(APIRequestCompletionHandler)completion
{
    [[APIClient client] signupWithUsername:username password:password andEmail:email completion:completion];
}

@end
