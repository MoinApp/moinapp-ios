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
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingString:@"Documents"];
    NSString *filePath = [documentsDirectory stringByAppendingString:@"session"];
    
    return filePath;
}
- (void)setSession:(NSString *)sessionToken
{
    NSString *filename = [self sessionFilename];
    
    NSError *error = nil;
    if ( sessionToken ) {
        
        [sessionToken writeToFile:filename atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
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

#pragma mark Authorization Requests

- (AFHTTPRequestOperation *)loginWithUsername:(NSString *)username andPassword:(NSString *)password completion:(APIRequestCompletionHandler)completion
{
    if ( !username || !password ) {
        completion([APIErrorHandler errorObjectNil], nil, nil);
        return nil;
    }
    
    NSDictionary *params = @{ @"username": username, @"password": password };
    
    AFHTTPRequestOperationManager *manager = [APIClient httpManager];
    
    return [manager POST:[self getAbsolutePath:kMoinAPIPathLogin] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(nil, (NSDictionary *)responseObject, [NSNumber numberWithBool:YES]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(error, operation.responseObject, [NSNumber numberWithBool:NO]);
    }];
}

- (void)logoutWithCompletion:(APIRequestCompletionHandler)completion
{
    self.session = nil;
    completion(nil, nil, nil);
}

- (AFHTTPRequestOperation *)signupWithUsername:(NSString *)username password:(NSString *)password andEmail:(NSString *)email completion:(APIRequestCompletionHandler)completion
{
    NSDictionary *params = @{ @"username": username, @"password": password, @"email": email };
    
    AFHTTPRequestOperationManager *manager = [APIClient httpManager];
    
    return [manager POST:[self getAbsolutePath:kMoinAPIPathSignup]
              parameters:params
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     completion(nil, (NSDictionary *)responseObject, [NSNumber numberWithBool:YES]);
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     completion(error, operation.responseObject, [NSNumber numberWithBool:NO]);
                 }];
}

#pragma mark Data Requests

- (AFHTTPRequestOperation *)getRecentsWithCompletion:(APIRequestCompletionHandler)completion
{
    if ( ![self isAuthorized] ) {
        NSError *error = [APIErrorHandler errorNotAuthorized];
        
        completion(error, nil, nil);
        return nil;
    }
    
    AFHTTPRequestOperationManager *manager = [APIClient httpManager];
    
    return [manager GET:[self getAbsolutePath:kMoinAPIPathRecents] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = (NSDictionary *)responseObject;
        NSMutableArray *users = [[NSMutableArray alloc] init];
        
        for ( NSDictionary *userDict in [response objectForKey:@"message"] ) {
            User *user = [[User alloc] initWithDictionary:userDict];
            
            [users addObject:user];
        }
        
        completion(nil, response, users);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(error, operation.responseObject, nil);
    }];
}

- (AFHTTPRequestOperation *)getUsersWithUsername:(NSString *)username completion:(APIRequestCompletionHandler)completion
{
    if ( ![self isAuthorized] ) {
        NSError *error = [APIErrorHandler errorNotAuthorized];
        
        completion(error, nil, nil);
        return nil;
    }
    
    AFHTTPRequestOperationManager *manager = [APIClient httpManager];
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    [APIClient prepareAFRequestSerializer:requestSerializer];
    [manager setRequestSerializer:requestSerializer];
    
    NSDictionary *params = @{ @"username": username };
    
    return [manager GET:[self getAbsolutePath:kMoinAPIUserSearch] parameters:params  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = (NSDictionary *)responseObject;
        NSMutableArray *users = [[NSMutableArray alloc] init];
        
        for ( NSDictionary *userDict in [response objectForKey:@"message"] ) {
            User *user = [[User alloc] initWithDictionary:userDict];
            
            [users addObject:user];
        }
        
        completion(nil, response, users);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(error, operation.responseObject, nil);
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
        NSError *error = [APIErrorHandler errorNotAuthorized];
        
        completion(error, nil, nil);
        return nil;
    }
    
    NSDictionary *params = @{ @"username": username };
    
    AFHTTPRequestOperationManager *manager = [APIClient httpManager];
    
    return [manager POST:[self getAbsolutePath:kMoinAPIPathMoin] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        completion(nil, (NSDictionary *)responseObject, [NSNumber numberWithBool:YES]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(error, operation.responseObject, [NSNumber numberWithBool:NO]);
    }];
}

@end
