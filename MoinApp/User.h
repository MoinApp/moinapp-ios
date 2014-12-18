//
//  User.h
//  MoinApp
//
//  Created by Sören Gade on 14/12/14.
//  Copyright (c) 2014 Sören Gade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface User : NSObject

+ (UIImage*)placeholderImage;

- (instancetype)initWithDictionary:(NSDictionary *)data;

- (NSURL *)gravatarImageURL;

// Properties for data
@property (nonatomic, copy) NSString* userId;
@property (nonatomic, copy) NSString* username;
@property (nonatomic, copy) NSString* emailHash;
// Custom App properties
@property (nonatomic, copy) UIImage* profileImage;
@end
