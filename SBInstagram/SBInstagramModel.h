//
//  SBInstagramModel.h
//  instagram
//
//  Created by Santiago Bustamante on 8/26/13.
//  Copyright (c) 2013 Busta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBInstagramHTTPClient.h"
#import "SBInstagramMediaEntity.h"

#define InstagramAccessTokenErrorCode -1011

@interface SBInstagramModel : NSObject

+ (void) checkInstagramAccesTokenWithBlock:(void (^)(NSError * error))block;
+ (void) mediaUserWithUserId:(NSString *)userId andBlock:(void (^)(NSArray *mediaArray, NSError * error))block;
+ (void) mediaUserWithPagingWntity:(SBInstagramMediaPagingEntity *)entity andBlock:(void (^)(NSArray *mediaArray, NSError * error))block;
+ (void) downloadImageWithUrl:(NSString *)url andBlock:(void (^)(UIImage *image, NSError * error))block;


@end
