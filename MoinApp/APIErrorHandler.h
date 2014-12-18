//
//  APIErrorHandler.h
//  MoinApp
//
//  Created by Sören Gade on 17/12/14.
//  Copyright (c) 2014 Sören Gade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *const kMoinErrorDomain;
typedef enum {
    kMoinErrorNotAuthorized = 1,
    kMoinErrorObjectNil = 2
} MoinErrorCode;

@interface APIErrorHandler : NSObject

+ (BOOL)handleError:(NSError *)error;
+ (BOOL)handleError:(NSError *)error withResponse:(NSDictionary *)response;

+ (NSError *)errorNotAuthorized;
+ (NSError *)errorObjectNil;

@end
