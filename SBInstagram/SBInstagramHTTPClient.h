//
//  MHHHTTPClient.h
//  instagram
//
//  Created by Santiago Bustamante on 8/26/13.
//  Copyright (c) 2013 Pineapple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface SBInstagramHTTPClient : AFHTTPClient

+ (SBInstagramHTTPClient *)sharedClient;

@end
