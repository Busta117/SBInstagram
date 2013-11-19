//
//  SBInstagramController.h
//  instagram
//
//  Created by Santiago Bustamante on 8/26/13.
//  Copyright (c) 2013 Busta. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SBInstagramMediaPagingEntity;

#warning setup your application information here

static NSString *const INSTAGRAM_API_VERSION = @"1";
//client information (from www.instagram.com/developer)
static NSString *const INSTAGRAM_REDIRECT_URI = @"http://www.sushimarket.com.co";
static NSString *const INSTAGRAM_CLIENT_SECRET = @"bce0d3a2c01c41aeb7ce4484b0e75a80";
static NSString *const INSTAGRAM_CLIENT_ID  = @"16e009e361a64e5d8752d98c3fee8708";

//if this value is empty or this token is expired or not valid, automatically request a new one. (if you set nil the app crash)
//static NSString *const INSTAGRAM_DEFAULT_ACCESS_TOKEN  = @"";
static NSString *const INSTAGRAM_DEFAULT_ACCESS_TOKEN  = @"295956532.16e009e.654a9915051c4ae89d8247bdd66b8f73";

static NSString *const INSTAGRAM_USER_ID  = @"295956532"; //user id to requests

@interface SBInstagramController : NSObject

@property (nonatomic, assign) UIViewController *viewController;

- (NSString *) AccessToken;
+ (id) instagramControllerWithMainViewController:(UIViewController *) viewController;
- (void) mediaUserWithUserId:(NSString *)userId andBlock:(void (^)(NSArray *mediaArray, NSError * error))block;
- (void) mediaUserWithPagingWntity:(SBInstagramMediaPagingEntity *)entity andBlock:(void (^)(NSArray *mediaArray, NSError * error))block;


@end
