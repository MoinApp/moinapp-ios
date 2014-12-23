//
//  APIError.h
//  MoinApp
//
//  Created by Sören Gade on 23/12/14.
//  Copyright (c) 2014 Sören Gade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPRequestOperation.h>

@interface APIError : NSObject

+ (instancetype)errorWithAFHTTPRequest:(AFHTTPRequestOperation *)request;
+ (instancetype)errorWithError:(NSError*)responseError andResponse:(NSDictionary *)responseDictionary;

- (instancetype)initWithError:(NSError *)responseError andResponse:(NSDictionary *)responseDictionary;

@property (nonatomic, copy) NSError *error;
@property (nonatomic, copy) NSDictionary *response;
@end
