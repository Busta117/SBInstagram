//
//  SBInstagramImageViewController.h
//  MedellinHipHop
//
//  Created by Santiago Bustamante on 9/2/13.
//  Copyright (c) 2013 Pineapple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBInstagramModel.h"

@interface SBInstagramImageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (assign, nonatomic) SBInstagramImageEntity* entity;

+ (id) imageViewerWithEntity:(SBInstagramImageEntity *)entity;

@end
