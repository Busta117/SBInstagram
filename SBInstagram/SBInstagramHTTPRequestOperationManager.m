//
//  SBInstagramHTTPRequestOperationManager.m
//  instagram
//
//  Created by Santiago Bustamante on 8/26/13.
//  Copyright (c) 2013 busta117. All rights reserved.
//

#import "SBInstagramHTTPRequestOperationManager.h"
#import "SBInstagramController.h"

@implementation SBInstagramHTTPRequestOperationManager


+ (SBInstagramHTTPRequestOperationManager *)sharedManager {
    static SBInstagramHTTPRequestOperationManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[SBInstagramHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v%@/",INSTAGRAM_API_VERSION]]];
    });
    
    return _sharedManager;
}


@end
