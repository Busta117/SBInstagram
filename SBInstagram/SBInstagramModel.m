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


+ (void) checkInstagramAccesTokenWithBlock:(void (^)(NSError * error))block{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *token = [def objectForKey:@"instagram_access_token"];
    
    if (!token) {
        token = INSTAGRAM_DEFAULT_ACCESS_TOKEN;
        [def setObject:token forKey:@"instagram_access_token"];
        [def synchronize];
    }
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:token forKey:@"access_token"];
    
    [[SBInstagramHTTPClient sharedClient] getPath:[NSString stringWithFormat:@"users/%@",INSTAGRAM_USER_ID] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
    
    NSString *path = [NSString stringWithFormat:@"users/%@/media/recent",userId];
    
    
    [[SBInstagramHTTPClient sharedClient] getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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

+ (void) mediaUserWithPagingWntity:(SBInstagramMediaPagingEntity *)entity andBlock:(void (^)(NSArray *mediaArray, NSError * error))block{

    
    NSString *path = [entity.nextUrl stringByReplacingOccurrencesOfString:[[SBInstagramHTTPClient sharedClient].baseURL absoluteString] withString:@""];
    
    
    [[SBInstagramHTTPClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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
    
    [[AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:^UIImage *(UIImage *image) {
        return image;
    } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        block(image,nil);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        block(nil,error);
    }] start];

}




@end
