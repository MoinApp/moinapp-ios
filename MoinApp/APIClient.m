//
//  APIClient.m
//  MoinApp
//
//  Created by Sören Gade on 14/12/14.
//  Copyright (c) 2014 Sören Gade. All rights reserved.
//

#import "APIClient.h"

// Global API Constants
static NSString *const kMoinAPIServerHost = @"moinapp.herokuapp.com";
//static NSString *const kMoinAPIServerHost = @"localhost:3000";
static NSString *const kMoinAPIUserAgent = @"Moin-iOS";
static NSString *const kMoinAPIUserAgentHeader = @"User-Agent";
static NSString *const kMoinAPIAuthorizationHeader = @"authorization";
// API Paths
static NSString *const kMoinAPIPathLogin = @"/api/auth";
static NSString *const kMoinAPIPathSignup = @"/api/signup";
static NSString *const kMoinAPIPathRegisterAPN = @"/api/addapn";
static NSString *const kMoinAPIPathRecents = @"/api/user/recents";
static NSString *const kMoinAPIPathMoin = @"/api/moin";
static NSString *const kMoinAPIUserSearch = @"/api/user";

@interface APIClient ()
{
    NSString *_session;
}

- (NSString *)getAbsolutePath:(NSString *)path withHost:(NSString *)host;
- (NSString *)getAbsolutePath:(NSString *)path;
@end

@implementation APIClient

#pragma mark - Class
static APIClient *client = nil;

+ (APIClient *)client
{
    static dispatch_once_t once_token;
    
    dispatch_once(&once_token, ^{
        client = [[APIClient alloc] init];
    });
    
    return client;
}

- (NSString *)sessionFilename
{
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"session"];
    
    return filePath;
}
- (void)setSession:(NSString *)sessionToken
{
    NSString *filename = [self sessionFilename];
    
    NSError *error = nil;
    if ( sessionToken ) {
        
        BOOL result = [sessionToken writeToFile:filename atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if ( !result )
        {
            NSLog(@"Could not write session to disk.");
        }
        
    } else {
        
        NSFileManager *manager = [NSFileManager defaultManager];
        
        if ( [manager fileExistsAtPath:filename] ) {
            [manager removeItemAtPath:filename error:&error];
        }
        
    }
    
    if ( error ) {
        NSLog(@"Error saving session token: %@", error);
    } else {
        _session = sessionToken;
    }
}
- (NSString *)session
{
    if ( !_session ) {
        NSString *filename = [self sessionFilename];
        NSFileManager *manager = [NSFileManager defaultManager];
        
        if ( ![manager fileExistsAtPath:filename] ) {
            return nil;
        }
        
        NSError *error = nil;
        NSString *sessionToken = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:&error];
        if ( error ) {
            NSLog(@"Error reading session token: %@", error);
            return nil;
        }
        
        return sessionToken;
    } else {
        return _session;
    }
}

+ (void)prepareAFRequestSerializer:(AFHTTPRequestSerializer *)serializer
{
    [serializer setValue:kMoinAPIUserAgent forHTTPHeaderField:kMoinAPIUserAgentHeader];
    
    NSString *session = [[APIClient client] session];
    if ( session ) {
        [serializer setValue:session forHTTPHeaderField:kMoinAPIAuthorizationHeader];
    }
}
+ (AFHTTPRequestOperationManager *)httpManager
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [APIClient prepareAFRequestSerializer:requestSerializer];
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager setRequestSerializer:requestSerializer];
    [manager setResponseSerializer:responseSerializer];
    
    // automatically add activity indicator to every request
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    return manager;
}

#pragma mark - Instance

#pragma mark Helpers

- (NSString *)getAbsolutePath:(NSString *)path withHost:(NSString *)host
{
    NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:host path:path];
    
    return [url absoluteString];
}
- (NSString *)getAbsolutePath:(NSString *)path
{
    return [self getAbsolutePath:path withHost:kMoinAPIServerHost];
}

- (BOOL)isAuthorized
{
    return ( [self session] != nil );
}

- (void)saveSessionTokenFromResponse:(NSDictionary *)response
{
    NSString *token = [response objectForKey:@"token"];
    
    self.session = token;
}

#pragma mark Authorization Requests

- (AFHTTPRequestOperation *)loginWithUsername:(NSString *)username andPassword:(NSString *)password completion:(APIRequestCompletionHandler)completion
{
    if ( !username || !password ) {
        completion([APIErrorHandler errorObjectNil], nil);
        return nil;
    }
    
    
    NSDictionary *params = @{ @"username": username, @"password": password };
    
    AFHTTPRequestOperationManager *manager = [APIClient httpManager];
    
    return [manager POST:[self getAbsolutePath:kMoinAPIPathLogin] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self saveSessionTokenFromResponse:responseObject];

        completion(nil, [NSNumber numberWithBool:YES]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        APIError *apiError = [APIError errorWithAFHTTPRequest:operation];
        
        completion(apiError, [NSNumber numberWithBool:NO]);
    }];
}

- (void)logoutWithCompletion:(APIRequestCompletionHandler)completion
{
    self.session = nil;
    completion(nil, nil);
}

- (AFHTTPRequestOperation *)signupWithUsername:(NSString *)username password:(NSString *)password andEmail:(NSString *)email completion:(APIRequestCompletionHandler)completion
{
    NSDictionary *params = @{ @"username": username, @"password": password, @"email": email };
    
    AFHTTPRequestOperationManager *manager = [APIClient httpManager];
    
    return [manager POST:[self getAbsolutePath:kMoinAPIPathSignup]
              parameters:params
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     [self saveSessionTokenFromResponse:responseObject];
                     
                     completion(nil, [NSNumber numberWithBool:YES]);
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     APIError *apiError = [APIError errorWithAFHTTPRequest:operation];
                     
                     completion(apiError, [NSNumber numberWithBool:NO]);
                 }];
}

- (AFHTTPRequestOperation *)registerForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken withCompletion:(APIRequestCompletionHandler)completion
{
    NSDictionary *params = @{ @"apnDeviceToken": deviceToken };
    
    AFHTTPRequestOperationManager *manager = [APIClient httpManager];
    
    return [manager POST:[self getAbsolutePath:kMoinAPIPathRegisterAPN]
              parameters:params
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     completion(nil, responseObject);
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     APIError *apiError = [APIError errorWithAFHTTPRequest:operation];
                     
                     completion(apiError, [NSNumber numberWithBool:NO]);
                 }];
}

#pragma mark Data Requests

- (AFHTTPRequestOperation *)getRecentsWithCompletion:(APIRequestCompletionHandler)completion
{
    if ( ![self isAuthorized] ) {
        APIError *error = [APIErrorHandler errorNotAuthorized];
        
        completion(error, nil);
        return nil;
    }
    
    AFHTTPRequestOperationManager *manager = [APIClient httpManager];

    return [manager GET:[self getAbsolutePath:kMoinAPIPathRecents] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSMutableArray *users = [[NSMutableArray alloc] init];
        NSArray *response = (NSArray *)responseObject;
        
        for ( NSDictionary *userDict in response ) {
            User *user = [[User alloc] initWithDictionary:userDict];
            
            [users addObject:user];
        }
        
        completion(nil, users);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        APIError *apiError = [APIError errorWithAFHTTPRequest:operation];
        
        completion(apiError, nil);
    }];
}

- (AFHTTPRequestOperation *)getUsersWithUsername:(NSString *)username completion:(APIRequestCompletionHandler)completion
{
    if ( ![self isAuthorized] ) {
        APIError *error = [APIErrorHandler errorNotAuthorized];
        
        completion(error, nil);
        return nil;
    }
    
    AFHTTPRequestOperationManager *manager = [APIClient httpManager];
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    [APIClient prepareAFRequestSerializer:requestSerializer];
    [manager setRequestSerializer:requestSerializer];
    
    NSDictionary *params = @{ @"username": username };
    
    return [manager GET:[self getAbsolutePath:kMoinAPIUserSearch] parameters:params  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *response = (NSArray *)responseObject;
        NSMutableArray *users = [[NSMutableArray alloc] init];
        
        for ( NSDictionary *userDict in response ) {
            User *user = [[User alloc] initWithDictionary:userDict];
            
            [users addObject:user];
        }
        
        completion(nil, users);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        APIError *apiError = [APIError errorWithAFHTTPRequest:operation];
        
        completion(apiError, nil);
    }];
}

#pragma mark Send Moin

- (AFHTTPRequestOperation *)moinUser:(User *)user completion:(APIRequestCompletionHandler)completion
{
    return [self moinUserWithName:user.username completion:completion];
}
- (AFHTTPRequestOperation *)moinUserWithName:(NSString *)username completion:(APIRequestCompletionHandler)completion
{
    if ( ![self isAuthorized] ) {
        APIError *error = [APIErrorHandler errorNotAuthorized];
        
        completion(error, nil);
        return nil;
    }
    
    NSDictionary *params = @{ @"username": username };
    
    AFHTTPRequestOperationManager *manager = [APIClient httpManager];
    
    return [manager POST:[self getAbsolutePath:kMoinAPIPathMoin] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        completion(nil, [NSNumber numberWithBool:YES]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        APIError *apiError = [APIError errorWithAFHTTPRequest:operation];
        
        completion(apiError, [NSNumber numberWithBool:NO]);
    }];
}

@end
