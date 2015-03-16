//
//  Constants.m
//  MoinApp
//
//  Created by Sören Gade on 23/12/14.
//  Copyright (c) 2014 Sören Gade. All rights reserved.
//

#import "Constants.h"

@implementation Constants
+ (UIColor*)styleColor
{
    return [UIColor colorWithRed:227.0f/255 green:0.0f/255 blue:84.0f/255 alpha:1.0];
}

+ (NSTimeInterval)searchDelay
{
    return 0.35f;
}
+ (NSString*)googleAnalyticsTrackingID
{
    return @"UA-59543236-1";
}
@end
