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
    
    if (SBInstagramModel.isSearchByTag && [SBInstagramModel searchTag].length > 0) {
        path = [NSString stringWithFormat:@"tags/%@/media/recent",[SBInstagramModel searchTag]];
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


@end
