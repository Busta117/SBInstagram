//
//  SBInstagramImageViewController.h
//  MedellinHipHop
//
//  Created by Santiago Bustamante on 9/2/13.
//  Copyright (c) 2013 Busta117. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBInstagramModel.h"
#import <AVFoundation/AVFoundation.h>

@interface SBInstagramImageViewController : UIViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (assign, nonatomic) SBInstagramMediaEntity* entity;
@property (strong, nonatomic) UILabel *userLabel;
@property (strong, nonatomic) UIImageView *userImage;


//video player
@property (strong, nonatomic) UIButton *controlButton;
@property (strong, nonatomic) UIImageView *videoPlayImage;
@property (nonatomic, strong) AVPlayerLayer *avPlayerLayer;
@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL loadComplete;


+ (id) imageViewerWithEntity:(SBInstagramMediaEntity *)entity;

@end
