//
//  SBInstagramHTTPRequestOperationManager.h
//  instagram
//
//  Created by Santiago Bustamante on 8/26/13.
//  Copyright (c) 2013 busta117. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface SBInstagramHTTPRequestOperationManager : AFHTTPRequestOperationManager

+ (SBInstagramHTTPRequestOperationManager *)sharedManager;

@end
