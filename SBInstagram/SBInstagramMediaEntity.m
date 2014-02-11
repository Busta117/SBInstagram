//
//  SBInstagramMediaEntity.m
//  instagram
//
//  Created by Santiago Bustamante on 8/29/13.
//  Copyright (c) 2013 Pineapple Inc. All rights reserved.
//

#import "SBInstagramMediaEntity.h"
#import "SBInstagramModel.h"

@implementation SBInstagramMediaEntity

+ (id) entityWithDictionary:(NSDictionary *)dictionary{
    
    SBInstagramMediaEntity *entity = [[SBInstagramMediaEntity alloc] init];
    entity.type = [dictionary[@"type"] isEqualToString:@"image"]? SBInstagramMediaTypeImage : SBInstagramMediaTypeVideo;
    entity.caption = (![dictionary[@"caption"] isKindOfClass:[NSNull class]])?(dictionary[@"caption"])[@"text"]:@"";
    entity.images = [SBInstagramMediaEntity imagesWithDictionary:dictionary[@"images"]];
    entity.userName = dictionary[@"user"][@"username"];
    entity.profilePicture = dictionary[@"user"][@"profile_picture"];

    
    return entity;
}


+ (NSMutableDictionary *)imagesWithDictionary: (NSMutableDictionary *)dictionary{
    NSMutableDictionary *retVal = [NSMutableDictionary dictionaryWithCapacity:0];
    [retVal setObject:[SBInstagramImageEntity entityWithDictionary:dictionary[@"low_resolution"]] forKey:@"low_resolution"];
    [retVal setObject:[SBInstagramImageEntity entityWithDictionary:dictionary[@"standard_resolution"]] forKey:@"standard_resolution"];
    [retVal setObject:[SBInstagramImageEntity entityWithDictionary:dictionary[@"thumbnail"]] forKey:@"thumbnail"];
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

@implementation SBInstagramMediaPagingEntity

+ (id) entityWithDataDictionary:(NSDictionary *)dataDictionary andPagingDictionary:(NSDictionary *)pagingDictionary{
    SBInstagramMediaPagingEntity *entity = [[SBInstagramMediaPagingEntity alloc] init];
    entity.nextUrl = pagingDictionary[@"next_url"];
    entity.mediaEntity = [SBInstagramMediaEntity entityWithDictionary:dataDictionary];
    
    return entity;
}

@end


