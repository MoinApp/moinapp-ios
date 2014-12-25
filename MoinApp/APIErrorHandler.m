//
//  APIErrorHandler.m
//  MoinApp
//
//  Created by Sören Gade on 17/12/14.
//  Copyright (c) 2014 Sören Gade. All rights reserved.
//

#import "APIErrorHandler.h"

@implementation APIErrorHandler

NSString *const kMoinErrorDomain = @"MPMoinErrorDomain";

#pragma mark - Handle Error (UI)

+ (BOOL)handleError:(APIError *)error
{
    return [APIErrorHandler handleError:error.error withResponse:error.response];
}
+ (BOOL)handleError:(NSError *)error withResponse:(NSDictionary *)response
{
    if ( !error ) {
        return NO;
    }
    
    NSString *title = nil;
    NSString *body = nil;
    
    if ( response ) {
        title = [NSString stringWithFormat:@"%@", [response objectForKey:@"code"]];
        // split the title by captial letters
        NSRegularExpression *regexTitle = [NSRegularExpression regularExpressionWithPattern:@"([a-z])([A-Z])"
                                                                                    options:0
                                                                                      error:nil];
        title = [regexTitle stringByReplacingMatchesInString:title
                                                     options:0
                                                       range:NSMakeRange(0, [title length])
                                                withTemplate:@"$1 $2"];
        NSRegularExpression *regexErrorWord = [NSRegularExpression regularExpressionWithPattern:NSLocalizedString(@"Error", @"Error")
                                                                                        options:0
                                                                                          error:nil];
        title = [regexErrorWord stringByReplacingMatchesInString:title
                                                         options:0
                                                           range:NSMakeRange(0, [title length])
                                                    withTemplate:@"$1"];
        
        body = [NSString stringWithFormat:@"%@", [response objectForKey:@"message"]];
    } else {
        NSString *titleFormat = NSLocalizedString(@"Unexpected server error (%ld)", @"Title if an unexpected error occurs. %ld is the error code.");
        title = [NSString stringWithFormat:titleFormat, (long)error.code];
        
        body = [NSString stringWithFormat:@"%@", error.localizedDescription];
    }
    
    [[[UIAlertView alloc] initWithTitle:title
                                message:body
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"Dismiss", @"Close a notification dialog.")
                      otherButtonTitles:nil]
     show];
    
    return YES;
}

# pragma mark - Errors

+ (APIError *)errorNotAuthorized
{
    NSError *error = [NSError errorWithDomain:kMoinErrorDomain code:kMoinErrorNotAuthorized userInfo:nil];
    
    return [APIError errorWithError:error andResponse:nil];
}

+ (APIError *)errorObjectNil
{
    NSError *error = [NSError errorWithDomain:kMoinErrorDomain code:kMoinErrorObjectNil userInfo:nil];
    
    return [APIError errorWithError:error andResponse:nil];
}

@end
