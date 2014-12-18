
//
//  User.m
//  MoinApp
//
//  Created by Sören Gade on 14/12/14.
//  Copyright (c) 2014 Sören Gade. All rights reserved.
//

#import "User.h"

static NSString *const kGravatarImageBaseUrl = @"http://www.gravatar.com/avatar/";

@interface User ()
{
    UIImage *_profileImage;
    NSString *_emailHash;
}
@end

@implementation User
@synthesize userId, username, emailHash, profileImage;

#pragma mark - Class

+ (UIImage*)placeholderImage
{
    return [UIImage imageNamed:@"DefaultProfile"];
}

#pragma mark - Instance

- (instancetype)init
{
    return [self initWithDictionary:nil];
}
- (instancetype)initWithDictionary:(NSDictionary *)data
{
    if ( self = [super init] ) {
        if ( data ) {
            
            self.userId = [data objectForKey:@"id"];
            self.username = [data objectForKey:@"username"];
            self.emailHash = [data objectForKey:@"email_hash"];
            
        }
    }
            
    return self;
}

#pragma mark Profile Image

- (NSURL*)gravatarImageURL
{
    return [self gravatarImageURLWithSize:512];
}
- (NSURL*)gravatarImageURLWithSize:(NSInteger)size
{
    NSString *endString = [NSString stringWithFormat:@"%@%@?s=%d", kGravatarImageBaseUrl, _emailHash, size];
    
    return [NSURL URLWithString:endString];;
}

- (NSString*)profileImageFilename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if ( [paths count] > 0 ) {
        NSString *cacheDirectory = [paths objectAtIndex:0];
        
        NSString *path = [cacheDirectory stringByAppendingPathComponent:@"gravatar"];
        NSString *filename = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", self.emailHash]];
        
        return filename;
    }
    
    return nil;
}

- (UIImage *)loadProfileImage
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *filename = [self profileImageFilename];
    if ( [manager fileExistsAtPath:filename] ) {
        return [UIImage imageWithContentsOfFile:filename];
    }
    
    return nil;
}

- (BOOL)saveProfileImage:(UIImage *)image
{
    if ( !image ) {
        return NO;
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if ( [manager fileExistsAtPath:[self profileImageFilename]] ) {
        return NO;
    }
    
    NSString *filename = [self profileImageFilename];
    NSString *cachesDirectory = [filename stringByDeletingLastPathComponent];
    BOOL isDirectory = NO;
    if ( ![manager fileExistsAtPath:cachesDirectory isDirectory:&isDirectory] ) {
        
        NSError *error = nil;
        [manager createDirectoryAtPath:cachesDirectory
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:&error];
        
        if ( error ) {
            NSLog(@"Error creating caches directory. (Error: %@, Path: %@, isDirectory: %@", error, cachesDirectory, (isDirectory)?@"YES":@"NO" );
        }
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    return [manager createFileAtPath:filename contents:imageData attributes:nil];
}

- (UIImage*)profileImage
{
    return _profileImage;
}
- (void)setProfileImage:(UIImage*)image
{
    _profileImage = image;
    
    __block UIImage *_image = image;
    // save in background
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self saveProfileImage:_image];
    });
}

#pragma mark Email Hash

- (NSString*)emailHash
{
    return _emailHash;
}
- (void)setEmailHash:(NSString *)hash
{
    _emailHash = hash;
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        self.profileImage = [self loadProfileImage];
    //});
}

@end
