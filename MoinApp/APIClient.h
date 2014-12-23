//
//  APIClient.h
//  MoinApp
//
//  Created by Sören Gade on 14/12/14.
//  Copyright (c) 2014 Sören Gade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

#import "APIError.h"
#import "APIErrorHandler.h"
#import "User.h"

typedef void(^APIRequestCompletionHandler)(APIError*, id);

@interface APIClient : NSObject
+ (APIClient *)client;

// Get the preconfigured request manager
+ (AFHTTPRequestOperationManager *)httpManager;

- (AFHTTPRequestOperation *)loginWithUsername:(NSString *)username andPassword:(NSString *)password completion:(APIRequestCompletionHandler)completion;
- (void)logoutWithCompletion:(APIRequestCompletionHandler)completion;
- (AFHTTPRequestOperation *)signupWithUsername:(NSString *)username password:(NSString *)password andEmail:(NSString *)email completion:(APIRequestCompletionHandler)completion;

- (AFHTTPRequestOperation *)getRecentsWithCompletion:(APIRequestCompletionHandler)completion;
- (AFHTTPRequestOperation *)getUsersWithUsername:(NSString *)username completion:(APIRequestCompletionHandler)completion;

- (AFHTTPRequestOperation *)moinUser:(User *)user completion:(APIRequestCompletionHandler)completion;
- (AFHTTPRequestOperation *)moinUserWithName:(NSString *)username completion:(APIRequestCompletionHandler)completion;

- (void)setSession:(NSString*)sessionToken;
- (NSString *)session;
@end
