//
//  SBInstagramController.m
//  instagram
//
//  Created by Santiago Bustamante on 8/26/13.
//  Copyright (c) 2013 Busta. All rights reserved.
//

#import "SBInstagramController.h"
#import "SBInstagramModel.h"
#import "SBInstagramWebViewController.h"
#import "SBInstagramCollectionViewController.h"

@implementation SBInstagramController

+ (SBInstagramCollectionViewController *) instagramViewController{
    SBInstagramCollectionViewController *instagram = [[SBInstagramCollectionViewController alloc] initWithCollectionViewLayout:[UICollectionViewFlowLayout new]];
    return instagram;
}


+ (id) instagramControllerWithMainViewController:(UIViewController *) viewController {
    SBInstagramController *instance = [[SBInstagramController alloc] init];
    instance.viewController = viewController;
    return instance;
}


- (void) setIsSearchByTag:(BOOL)isSearchByTag{
    _isSearchByTag = isSearchByTag;
    SBInstagramModel.isSearchByTag = isSearchByTag;
}

- (void) setSearchTag:(NSString *)searchTag{
    _searchTag = searchTag;
    SBInstagramModel.searchTag = searchTag;
}

- (NSString *) AccessToken{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *token = [def objectForKey:@"instagram_access_token"];
    if (!token) {
        token = INSTAGRAM_DEFAULT_ACCESS_TOKEN;
        [def setObject:token forKey:@"instagram_access_token"];
        [def synchronize];
    }
    return token;
}


-(void) validateTokenWithBlock:(void (^)(NSError *error))block{
    
    [SBInstagramModel checkInstagramAccesTokenWithBlock:^(NSError *error) {
        if (error.code == InstagramAccessTokenErrorCode) {
            [self renewAccessTokenWithBlock:block];
        }else{
            block(nil);
        }
    }];
}

- (void) renewAccessTokenWithBlock:(void (^)(NSError *error))block{
    __weak typeof(self) weakSelf = self;
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSString *urlString = [NSString stringWithFormat:@"https://instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token",INSTAGRAM_CLIENT_ID,INSTAGRAM_REDIRECT_URI];
        
        SBInstagramWebViewController *viewCon = [SBInstagramWebViewController webViewWithUrl:urlString andSuccessBlock:^(NSString *token, UIViewController *viewController) {
            NSLog(@"your new access token is: %@",token);
             NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
             [def setObject:token forKey:@"instagram_access_token"];
             [def synchronize];
            [viewController dismissViewControllerAnimated:YES completion:^{
                block(nil);
            }];
        }];
        
        [viewCon setModalPresentationStyle:UIModalPresentationPageSheet];
        [viewCon setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        
        [weakSelf.viewController presentViewController:viewCon animated:YES completion:nil];
        
    });
}

- (void) mediaUserWithUserId:(NSString *)userId andBlock:(void (^)(NSArray *mediaArray, NSError * error))block{
    
    [self validateTokenWithBlock:^(NSError *error) {
        if (!error) {
            [SBInstagramModel mediaUserWithUserId:userId andBlock:block];
        }
    }];
    
}

- (void) mediaUserWithPagingEntity:(SBInstagramMediaPagingEntity *)entity andBlock:(void (^)(NSArray *mediaArray, NSError * error))block{
    
    [self validateTokenWithBlock:^(NSError *error) {
        if (!error) {
            [SBInstagramModel mediaUserWithPagingEntity:entity andBlock:block];
        }
    }];
    
}


@end
