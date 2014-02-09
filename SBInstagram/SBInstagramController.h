//
//  SBInstagramController.h
//  instagram
//
//  Created by Santiago Bustamante on 8/26/13.
//  Copyright (c) 2013 Busta. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SBInstagramMediaPagingEntity;
@class SBInstagramCollectionViewController;

#warning setup your application information here

static NSString *const INSTAGRAM_API_VERSION = @"1";
//client information (from www.instagram.com/developer)
static NSString *const INSTAGRAM_REDIRECT_URI = @"http://www.santiagobustamante.info";
static NSString *const INSTAGRAM_CLIENT_SECRET = @"dd9f687e1ffb4ff48ebc77188a14d283";
static NSString *const INSTAGRAM_CLIENT_ID  = @"436eb0b4692245c899091391eaa5cdf1";

//if this value is empty or this token is expired or not valid, automatically request a new one. (if you set nil the app crash)
//static NSString *const INSTAGRAM_DEFAULT_ACCESS_TOKEN  = @"";
static NSString *const INSTAGRAM_DEFAULT_ACCESS_TOKEN  = @"6874212.436eb0b.9768fd326f9b423eab7dd260972ee6db";

static NSString *const INSTAGRAM_USER_ID  = @"6874212"; //user id to requests



@interface SBInstagramController : NSObject

@property (nonatomic, assign) UIViewController *viewController;
@property (nonatomic, assign) BOOL isSearchByTag;
@property (nonatomic, strong) NSString *searchTag;

+ (SBInstagramCollectionViewController *) instagramViewController;
+ (id) instagramControllerWithMainViewController:(UIViewController *) viewController;
- (NSString *) AccessToken;
- (void) mediaUserWithUserId:(NSString *)userId andBlock:(void (^)(NSArray *mediaArray, NSError * error))block;
- (void) mediaUserWithPagingEntity:(SBInstagramMediaPagingEntity *)entity andBlock:(void (^)(NSArray *mediaArray, NSError * error))block;


@end
