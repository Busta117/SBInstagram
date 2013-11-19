//
//  MHHHTTPClient.m
//  instagram
//
//  Created by Santiago Bustamante on 8/26/13.
//  Copyright (c) 2013 Pineapple Inc. All rights reserved.
//

#import "SBInstagramHTTPClient.h"
#import "SBInstagramController.h"

@implementation SBInstagramHTTPClient


+ (SBInstagramHTTPClient *)sharedClient {
    static SBInstagramHTTPClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SBInstagramHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v%@/",INSTAGRAM_API_VERSION]]];
    });
    
    return _sharedClient;
}

-(id)initWithBaseURL:(NSURL *)url {
    
    self = [super initWithBaseURL:url];
    if (self) {
        
        self.parameterEncoding = AFJSONParameterEncoding;
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        return self;
    }
    
    return  nil;
}

@end
