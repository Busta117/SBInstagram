//
//  SBInstagramModel.h
//  instagram
//
//  Created by Santiago Bustamante on 8/26/13.
//  Copyright (c) 2013 Busta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBInstagramHTTPRequestOperationManager.h"
#import "SBInstagramMediaEntity.h"

#define InstagramAccessTokenErrorCode -1011

@interface SBInstagramModel : NSObject


//v2 setup
@property (nonatomic, strong) NSString *instagramRedirectUri;
@property (nonatomic, strong) NSString *instagramClientSecret;
@property (nonatomic, strong) NSString *instagramClientId;
@property (nonatomic, strong) NSString *instagramDefaultAccessToken;
@property (nonatomic, strong) NSString *instagramUserId;
@property (nonatomic, strong) NSString *loadingImageName; //if you need set your oun loading image
@property (nonatomic, strong) NSString *videoPlayImageName; //if you need set your oun play video image
@property (nonatomic, strong) NSString *videoPauseImageName; //if you need set your oun pause video image
@property (nonatomic, assign) BOOL playStandardResolution;

+ (void) setIsSearchByTag:(BOOL) isSearchByTag;
+ (BOOL) isSearchByTag;
+ (void) setSearchTag:(NSString *)searchTag;
+ (NSString *)searchTag;
+ (void) checkInstagramAccesTokenWithBlock:(void (^)(NSError * error))block;
+ (void) mediaUserWithUserId:(NSString *)userId andBlock:(void (^)(NSArray *mediaArray, NSError * error))block;
+ (void) mediaUserWithPagingEntity:(SBInstagramMediaPagingEntity *)entity andBlock:(void (^)(NSArray *mediaArray, NSError * error))block;
+ (void) downloadImageWithUrl:(NSString *)url andBlock:(void (^)(UIImage *image, NSError * error))block;

+ (SBInstagramModel *) model;

@end
