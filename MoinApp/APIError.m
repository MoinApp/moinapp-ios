
//
//  APIError.m
//  MoinApp
//
//  Created by Sören Gade on 23/12/14.
//  Copyright (c) 2014 Sören Gade. All rights reserved.
//

#import "APIError.h"

@implementation APIError
@synthesize error, response;

+ (instancetype)errorWithAFHTTPRequest:(AFHTTPRequestOperation *)request
{
    return [APIError errorWithError:request.error andResponse:request.responseObject];
}
+ (instancetype)errorWithError:(NSError*)responseError andResponse:(NSDictionary *)responseDictionary
{
    return [[APIError alloc] initWithError:responseError andResponse:responseDictionary];
}

- (instancetype)initWithError:(NSError *)responseError andResponse:(NSDictionary *)responseDictionary
{
    if ( self = [super init] ) {
        self.error = responseError;
        self.response = responseDictionary;
    }
    
    return self;
}

@end
