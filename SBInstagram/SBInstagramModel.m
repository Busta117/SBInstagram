//
//  SBInstagramModel.m
//  instagram
//
//  Created by Santiago Bustamante on 8/26/13.
//  Copyright (c) 2013 Busta. All rights reserved.
//

#import "SBInstagramModel.h"
#import "SBInstagramController.h"


@implementation SBInstagramModel


+ (void) setIsSearchByTag:(BOOL) isSearchByTag{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:isSearchByTag forKey:@"instagram_isSearchByTag"];
    [def synchronize];
}

+ (BOOL) isSearchByTag{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    return [def boolForKey:@"instagram_isSearchByTag"];
}

+ (void) setSearchTag:(NSString *)searchTag{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:searchTag forKey:@"instagram_searchTag"];
    [def synchronize];
}

+ (NSString *)searchTag{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    return [def objectForKey:@"instagram_searchTag"];
}

+ (void) checkInstagramAccesTokenWithBlock:(void (^)(NSError * error))block{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *token = [def objectForKey:@"instagram_access_token"];
    
    if (!token) {
        token = [SBInstagramModel model].instagramDefaultAccessToken ?: INSTAGRAM_DEFAULT_ACCESS_TOKEN;
        [def setObject:token forKey:@"instagram_access_token"];
        [def synchronize];
    }
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:token forKey:@"access_token"];
    
    NSString *uId = [SBInstagramModel model].instagramUserId ?: INSTAGRAM_USER_ID;
    
    if (!uId || uId.length <= 0) {
        uId = @"25025320"; //instagram user
    }
    
    [[SBInstagramHTTPRequestOperationManager sharedManager] GET:[NSString stringWithFormat:@"users/%@",uId?:@""] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (block){
            block(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block){
            block(error);
        }
    }];
}


+ (void) mediaUserWithUserId:(NSString *)userId andBlock:(void (^)(NSArray *mediaArray, NSError * error))block{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *token = [def objectForKey:@"instagram_access_token"];
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:token forKey:@"access_token"];
    [params setObject:@"33" forKey:@"count"];
    
    NSString *path = [NSString stringWithFormat:@"users/%@/media/recent",userId?:@""];
    
    if (SBInstagramModel.isSearchByTag) {
        path = [NSString stringWithFormat:@"tags/%@/media/recent",userId];
    }
    
    [[SBInstagramHTTPRequestOperationManager sharedManager] GET:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *mediaArr = responseObject[@"data"];
        NSDictionary *paging = responseObject[@"pagination"];
        
        __block NSMutableArray *mediaArrEntities = [NSMutableArray arrayWithCapacity:0];
        
        [mediaArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            SBInstagramMediaPagingEntity *media = [SBInstagramMediaPagingEntity entityWithDataDictionary:obj andPagingDictionary:paging];
            [mediaArrEntities addObject:media];
        }];
        if (block) {
            block(mediaArrEntities,nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block){
            block(nil, error);
        }
    }];
}


+ (void) mediaMultipleUsersWithArr:(NSArray *)usersId complete:(void (^)(NSArray *mediaArray,NSArray *multipleMedia, NSError * error))block{
    
    NSMutableArray *entitiesArr = [NSMutableArray array];
    NSMutableArray *lastEntitiesArr = [NSMutableArray array];
    
    __block int count = 0;
    __block NSError *error1 = nil;;
    
    [usersId enumerateObjectsUsingBlock:^(NSString *userId, NSUInteger idx, BOOL *stop) {
        [SBInstagramModel mediaUserWithUserId:userId andBlock:^(NSArray *mediaArray, NSError *error) {
            if (!error) {
                if (mediaArray.count > 0) {
                    [entitiesArr addObjectsFromArray:mediaArray];
                    [lastEntitiesArr addObject:mediaArray[mediaArray.count-1]];
                }
            }else{
                error1 = error;
            }
            
            count++;
            if (count == usersId.count) {
                
                [entitiesArr sortUsingComparator:^NSComparisonResult(SBInstagramMediaPagingEntity *obj1, SBInstagramMediaPagingEntity *obj2) {
                    return [obj2.mediaEntity.createdTime  compare:obj1.mediaEntity.createdTime];
                }];
                
                block(entitiesArr,lastEntitiesArr,error1);
            }
            
        }];
        
    }];
    
}




+ (void) mediaUserWithPagingEntity:(SBInstagramMediaPagingEntity *)entity andBlock:(void (^)(NSArray *mediaArray, NSError * error))block{

    
    NSString *path = [entity.nextUrl stringByReplacingOccurrencesOfString:[[SBInstagramHTTPRequestOperationManager sharedManager].baseURL absoluteString] withString:@""];
    
    if (!path) {
        block(@[],nil);
        return;
    }
    
    [[SBInstagramHTTPRequestOperationManager sharedManager] GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *mediaArr = responseObject[@"data"];
        NSDictionary *paging = responseObject[@"pagination"];
        
        __block NSMutableArray *mediaArrEntities = [NSMutableArray arrayWithCapacity:0];
        
        [mediaArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            SBInstagramMediaPagingEntity *media = [SBInstagramMediaPagingEntity entityWithDataDictionary:obj andPagingDictionary:paging];
            [mediaArrEntities addObject:media];
        }];
        if (block) {
            block(mediaArrEntities,nil);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block){
            block(nil, error);
        }
    }];

}


+(void) mediaMultiplePagingWithArr:(NSArray *)entities complete:(void (^)(NSArray *mediaArray,NSArray *multipleMedia, NSError * error))block{
    
    NSMutableArray *entitiesArr = [NSMutableArray array];
    NSMutableArray *lastEntitiesArr = [NSMutableArray array];
    
    __block int count = 0;
    __block NSError *error1 = nil;;
    
    [entities enumerateObjectsUsingBlock:^(SBInstagramMediaPagingEntity *entity, NSUInteger idx, BOOL *stop) {
        
        [SBInstagramModel mediaUserWithPagingEntity:entity andBlock:^(NSArray *mediaArray, NSError *error) {
            if (!error) {
                if (mediaArray.count > 0) {
                    [entitiesArr addObjectsFromArray:mediaArray];
                    [lastEntitiesArr addObject:mediaArray[mediaArray.count-1]];
                }
            }else{
                error1 = error;
            }
            
            count++;
            if (count == entities.count) {
                
                [entitiesArr sortUsingComparator:^NSComparisonResult(SBInstagramMediaPagingEntity *obj1, SBInstagramMediaPagingEntity *obj2) {
                    return [obj2.mediaEntity.createdTime  compare:obj1.mediaEntity.createdTime];
                }];
                
                block(entitiesArr,lastEntitiesArr,error1);
            }
            
        }];
        
        
    }];
    
}






+ (void) downloadImageWithUrl:(NSString *)url andBlock:(void (^)(UIImage *image, NSError * error))block{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setResponseSerializer:[AFImageResponseSerializer serializer]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *error = nil;
        if (responseObject) {
            if (block) {
                block(responseObject, error);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
    
    [operation start];
    
}

+ (void) downloadVideoWithUrl:(NSString *)url complete:(void (^)(NSString *localUrl, NSError * error))block{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"SBInstagramVideo.mp4"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *op = [manager GET:url
                                   parameters:nil
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          NSLog(@"successful download to %@", path);
                                          if (block) {
                                              block(path,nil);
                                          }
                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSLog(@"Error: %@", error);
                                          if (block) {
                                              block(nil,error);
                                          }
                                      }];
    
    op.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    
}

+ (void) likersFromMediaEntity:(SBInstagramMediaEntity *)mediaEntity complete:(void (^)(NSMutableArray *likers, NSError * error))block{
    
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *token = [def objectForKey:@"instagram_access_token"];
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:token forKey:@"access_token"];
    
    NSString *path = [NSString stringWithFormat:@"media/%@/likes",mediaEntity.mediaId];
    
    
    [[SBInstagramHTTPRequestOperationManager sharedManager] GET:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (block) {
            
            NSMutableArray *likers = [NSMutableArray array];
            
            NSArray *arr = responseObject[@"data"];
            
            [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [likers addObject:[SBInstagramUserEntity entityWithDictionary:obj]];
            }];
            
            block(likers,nil);
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];

    
}

#pragma mark - v2

+ (SBInstagramModel *) model{
    return [self new];
}

//setters
- (void) setInstagramRedirectUri:(NSString *)instagramRedirectUri{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:instagramRedirectUri forKey:@"instagram_instagramRedirectUri"];
    [def synchronize];
}

- (void) setInstagramClientSecret:(NSString *)instagramClientSecret{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:instagramClientSecret forKey:@"instagram_instagramClientSecret"];
    [def synchronize];
}
- (void) setInstagramClientId:(NSString *)instagramClientId{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:instagramClientId forKey:@"instagram_instagramClientId"];
    [def synchronize];
}
- (void) setInstagramDefaultAccessToken:(NSString *)instagramDefaultAccessToken{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:instagramDefaultAccessToken forKey:@"instagram_instagramDefaultAccessToken"];
    [def synchronize];
}
- (void) setInstagramUserId:(NSString *)instagramUserId{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:instagramUserId forKey:@"instagram_instagramUserId"];
    [def synchronize];
}
-(void) setLoadingImageName:(NSString *)loadingImageName{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:loadingImageName forKey:@"instagram_loadingImageName"];
    [def synchronize];
}
-(void) setVideoPlayImageName:(NSString *)videoPlayImageName{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:videoPlayImageName forKey:@"instagram_videoPlayImageName"];
    [def synchronize];
}
-(void) setVideoPauseImageName:(NSString *)videoPauseImageName{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:videoPauseImageName forKey:@"instagram_videoPauseImageName"];
    [def synchronize];
}
-(void) setplayStandardResolution:(BOOL)playStandardResolution{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:playStandardResolution forKey:@"instagram_playStandardResolution"];
    [def synchronize];
}
- (void) setInstagramMultipleUsersId:(NSArray *)instagramMultipleUsersId{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:instagramMultipleUsersId forKey:@"instagram_instagramMultipleUsersId"];
    [def synchronize];
}



//getters
- (NSString *) instagramRedirectUri{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    return [def objectForKey:@"instagram_instagramRedirectUri"];
}
- (NSString *) instagramClientSecret{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    return [def objectForKey:@"instagram_instagramClientSecret"];
}
- (NSString *) instagramClientId{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    return [def objectForKey:@"instagram_instagramClientId"];
}
- (NSString *) instagramDefaultAccessToken{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    return [def objectForKey:@"instagram_instagramDefaultAccessToken"];
}
- (NSString *) instagramUserId{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    return [def objectForKey:@"instagram_instagramUserId"];
}
-(NSString *) loadingImageName{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *name = [def objectForKey:@"instagram_loadingImageName"];
    return name ?: @"SBInstagramLoading";
}
-(NSString *) videoPlayImageName{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *name = [def objectForKey:@"instagram_videoPlayImageName"];
    return name ?: @"SBInsta_play";
}
-(NSString *) videoPauseImageName{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *name = [def objectForKey:@"instagram_videoPauseImageName"];
    return name ?: @"SBInsta_pause";
}
- (BOOL) playStandardResolution{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    return [def boolForKey:@"instagram_playStandardResolution"];
}
- (NSArray *) instagramMultipleUsersId{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    return [def objectForKey:@"instagram_instagramMultipleUsersId"];
}


@end
