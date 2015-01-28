//
//  SBInstagramMediaEntity.h
//  instagram
//
//  Created by Santiago Bustamante on 8/29/13.
//  Copyright (c) 2013 Busta117. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, SBInstagramMediaType) {
    SBInstagramMediaTypeImage,
    SBInstagramMediaTypeVideo
};

#define SBInstagramImageThumbnailKey @"thumbnail"
#define SBInstagramImageLowResolutionKey @"low_resolution"
#define SBInstagramImageStandardResolutionKey @"standard_resolution"

#define SBInstagramVideoLowResolutionKey @"low_resolution"
#define SBInstagramVideoStandardResolutionKey @"standard_resolution"



@interface SBInstagramMediaEntity : NSObject

@property (nonatomic, strong) NSString *mediaId;
@property (nonatomic, assign) enum SBInstagramMediaType type;
@property (nonatomic, strong) NSMutableDictionary *images; //dictionary of SBInstagramImageEntity
@property (nonatomic, strong) NSMutableDictionary *videos; //dictionary of SBInstagramVideoEntity
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *profilePicture;
@property (nonatomic, strong) NSDate *createdTime;
@property (nonatomic, assign) int likesCount;
@property (nonatomic, strong) NSMutableArray *likers;

+ (id) entityWithDictionary:(NSDictionary *)dictionary;

@end


@interface SBInstagramImageEntity : NSObject

@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) int width;


+ (id) entityWithDictionary:(NSDictionary *)dictionary;
- (void) downloadImageWithBlock:(void (^)(UIImage *image, NSError * error))block;

@end

@interface SBInstagramVideoEntity : NSObject

@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) int width;

+ (id) entityWithDictionary:(NSDictionary *)dictionary;
@end


@interface SBInstagramMediaPagingEntity : NSObject

@property (nonatomic, strong) SBInstagramMediaEntity *mediaEntity;
@property (nonatomic, strong) NSString *nextUrl;

+ (id) entityWithDataDictionary:(NSDictionary *)dataDictionary andPagingDictionary:(NSDictionary *)pagingDictionary;

@end

@interface SBInstagramUserEntity : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *bio;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *profilePictureUrl;
@property (nonatomic, strong) NSString *username;

+ (id) entityWithDictionary:(NSDictionary *)dictionary;

@end
