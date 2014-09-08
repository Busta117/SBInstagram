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


// this is only for support the v1 of the SBInstagram
+ (SBInstagramCollectionViewController *) instagramViewController{
    
return [[SBInstagramCollectionViewController alloc] initWithCollectionViewLayout:[UICollectionViewFlowLayout new]];
}

//v2 initiallization
+ (SBInstagramController *) instagram{
    
    SBInstagramController *instance = [SBInstagramController new];
    
    instance.instagramCollection = [[SBInstagramCollectionViewController alloc] initWithCollectionViewLayout:[UICollectionViewFlowLayout new]];
    
    return instance;
}


+ (id) instagramControllerWithMainViewController:(UIViewController *) viewController {
    SBInstagramController *instance = [[SBInstagramController alloc] init];
    instance.viewController = viewController;
    return instance;
}


- (NSString *) AccessToken{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *token = [def objectForKey:@"instagram_access_token"];
    if (!token) {
        token = [SBInstagramModel model].instagramDefaultAccessToken ?: INSTAGRAM_DEFAULT_ACCESS_TOKEN;
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
    
    NSString *clientId = [SBInstagramModel model].instagramClientId ?: INSTAGRAM_CLIENT_ID;
    NSString *redirectUrl = [SBInstagramModel model].instagramRedirectUri ?: INSTAGRAM_REDIRECT_URI;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSString *urlString = [NSString stringWithFormat:@"https://instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token",clientId,redirectUrl];
        
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


#pragma mark - v2
//mapping variables

-(NSString *)version{
    return _instagramCollection.version;
}

-(void) setShowSwitchModeView:(BOOL)showSwitchModeView{
    _instagramCollection.showSwitchModeView = showSwitchModeView;
}

-(BOOL) showSwitchModeView{
    return _instagramCollection.showSwitchModeView;
}

- (void) setIsSearchByTag:(BOOL)isSearchByTag{
    SBInstagramModel.isSearchByTag = isSearchByTag;
    _instagramCollection.isSearchByTag = isSearchByTag;
}

-(BOOL) isSearchByTag{
    return _instagramCollection.isSearchByTag;
}

- (void) setSearchTag:(NSString *)searchTag{
    SBInstagramModel.searchTag = searchTag;
    _instagramCollection.searchTag = searchTag;
}

- (NSString *) searchTag{
    return _instagramCollection.searchTag;
}

-(UIViewController *) feed{
    return _instagramCollection;
}

-(void) refreshCollection{
    [_instagramCollection refreshCollection];
}

- (void) setShowOnePicturePerRow:(BOOL)showOnePicturePerRow{
    _instagramCollection.showOnePicturePerRow = showOnePicturePerRow;
}

- (BOOL) showOnePicturePerRow{
    return _instagramCollection.showOnePicturePerRow;
}



//setup v2
- (void) setInstagramRedirectUri:(NSString *)instagramRedirectUri{
    [SBInstagramModel model].instagramRedirectUri = instagramRedirectUri;
}
- (void) setInstagramClientSecret:(NSString *)instagramClientSecret{
    [SBInstagramModel model].instagramClientSecret = instagramClientSecret;
}
- (void) setInstagramClientId:(NSString *)instagramClientId{
    [SBInstagramModel model].instagramClientId = instagramClientId;
}
- (void) setInstagramDefaultAccessToken:(NSString *)instagramDefaultAccessToken{
    [SBInstagramModel model].instagramDefaultAccessToken = instagramDefaultAccessToken;
}
- (void) setInstagramUserId:(NSString *)instagramUserId{
    [SBInstagramModel model].instagramUserId = instagramUserId;
}

- (NSString *) instagramRedirectUri{
    return [SBInstagramModel model].instagramRedirectUri;
}
- (NSString *) instagramClientSecret{
    return [SBInstagramModel model].instagramClientSecret;
}
- (NSString *) instagramClientId{
    return [SBInstagramModel model].instagramClientId;
}
- (NSString *) instagramDefaultAccessToken{
    return [SBInstagramModel model].instagramUserId;
}
- (NSString *) instagramUserId{
    return [SBInstagramModel model].instagramUserId;
}






@end
