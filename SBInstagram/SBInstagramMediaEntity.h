//
//  SBInstagramMediaEntity.h
//  instagram
//
//  Created by Santiago Bustamante on 8/29/13.
//  Copyright (c) 2013 Pineapple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, SBInstagramMediaType) {
    SBInstagramMediaTypeImage,
    SBInstagramMediaTypeVideo
};


@interface SBInstagramMediaEntity : NSObject

@property (nonatomic, assign) enum SBInstagramMediaType type;
@property (nonatomic, strong) NSMutableDictionary *images;
@property (nonatomic, strong) NSMutableDictionary *videos;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *profilePicture;
@property (nonatomic, strong) NSDate *createdTime;

+ (id) entityWithDictionary:(NSDictionary *)dictionary;

@end


@interface SBInstagramImageEntity : NSObject

@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) int width;
@property (nonatomic, strong) UIImage *image;

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
