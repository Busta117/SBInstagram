//
//  SBInstagramMediaEntity.m
//  instagram
//
//  Created by Santiago Bustamante on 8/29/13.
//  Copyright (c) 2013 Busta117. All rights reserved.
//

#import "SBInstagramMediaEntity.h"
#import "SBInstagramModel.h"
#import "SBInstagramCollectionViewController.h"

@implementation SBInstagramMediaEntity

+ (id) entityWithDictionary:(NSDictionary *)dictionary{
    
    SBInstagramMediaEntity *entity = [[SBInstagramMediaEntity alloc] init];
    entity.mediaId = dictionary[@"id"];
    entity.type = [dictionary[@"type"] isEqualToString:@"image"]? SBInstagramMediaTypeImage : SBInstagramMediaTypeVideo;
        entity.images = [SBInstagramMediaEntity imagesWithDictionary:dictionary[@"images"]];
    entity.caption = (![dictionary[@"caption"] isKindOfClass:[NSNull class]])?(dictionary[@"caption"])[@"text"]:@"";
    
    entity.userName = dictionary[@"user"][@"username"];
    entity.profilePicture = dictionary[@"user"][@"profile_picture"];

    if (entity.type == SBInstagramMediaTypeVideo) {
        entity.videos = [SBInstagramMediaEntity videosWithDictionary:dictionary[@"videos"]];
    }
    
    entity.likesCount = [dictionary[@"likes"][@"count"] intValue];
    
    if (entity.likesCount > 0) {
        entity.likers = [NSMutableArray array];
        [dictionary[@"likes"][@"data"] enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            [entity.likers addObject:[SBInstagramUserEntity entityWithDictionary:obj]];
        }];
    }
    
    entity.createdTime = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"created_time"] longLongValue]];
    
    return entity;
}


+ (NSMutableDictionary *)imagesWithDictionary: (NSMutableDictionary *)dictionary{
    NSMutableDictionary *retVal = [NSMutableDictionary dictionaryWithCapacity:0];
    [retVal setObject:[SBInstagramImageEntity entityWithDictionary:dictionary[@"low_resolution"]] forKey:@"low_resolution"];
    [retVal setObject:[SBInstagramImageEntity entityWithDictionary:dictionary[@"standard_resolution"]] forKey:@"standard_resolution"];
    [retVal setObject:[SBInstagramImageEntity entityWithDictionary:dictionary[@"thumbnail"]] forKey:@"thumbnail"];
    return retVal;
}

+ (NSMutableDictionary *)videosWithDictionary: (NSMutableDictionary *)dictionary{
    NSMutableDictionary *retVal = [NSMutableDictionary dictionaryWithCapacity:0];
    [retVal setObject:[SBInstagramVideoEntity entityWithDictionary:dictionary[@"low_resolution"]] forKey:@"low_resolution"];
    [retVal setObject:[SBInstagramVideoEntity entityWithDictionary:dictionary[@"standard_resolution"]] forKey:@"standard_resolution"];
    return retVal;
}

@end


@implementation SBInstagramImageEntity

+ (id) entityWithDictionary:(NSDictionary *)dictionary{
    SBInstagramImageEntity *entity = [[SBInstagramImageEntity alloc] init];
    entity.url = dictionary[@"url"];
    entity.width = [dictionary[@"width"] intValue];
    entity.height = [dictionary[@"height"] intValue];
//    [entity downloadImageWithBlock:nil];
    
    return entity;
}


- (void) downloadImageWithBlock:(void (^)(UIImage *image, NSError * error))block{
    
    [SBInstagramModel downloadImageWithUrl:self.url andBlock:^(UIImage *image2, NSError *error) {
        if (image2 && !error) {
            
            if (block) {
                block(image2, nil);
            }
        }
    }];
}



@end


@implementation SBInstagramVideoEntity

+ (id) entityWithDictionary:(NSDictionary *)dictionary{
    
    SBInstagramVideoEntity *entity = [SBInstagramVideoEntity new];
    
    entity.height = [dictionary[@"height"] intValue];
    entity.width = [dictionary[@"width"] intValue];
    entity.url = dictionary[@"url"];
    
    return entity;
}

@end


@implementation SBInstagramMediaPagingEntity

+ (id) entityWithDataDictionary:(NSDictionary *)dataDictionary andPagingDictionary:(NSDictionary *)pagingDictionary{
    SBInstagramMediaPagingEntity *entity = [[SBInstagramMediaPagingEntity alloc] init];
    entity.nextUrl = pagingDictionary[@"next_url"];
    entity.mediaEntity = [SBInstagramMediaEntity entityWithDictionary:dataDictionary];
    
    return entity;
}

@end


@implementation SBInstagramUserEntity

+ (id) entityWithDictionary:(NSDictionary *)dictionary{
    SBInstagramUserEntity *entity = [[SBInstagramUserEntity alloc] init];
    entity.userId = dictionary[@"id"];
    entity.bio = [dictionary[@"bio"] isMemberOfClass:[NSNull class]]?nil:dictionary[@"bio"];
    entity.fullName = dictionary[@"full_name"];
    entity.profilePictureUrl = dictionary[@"profile_picture"];
    entity.username = dictionary[@"username"];
    
    return entity;
}

@end

