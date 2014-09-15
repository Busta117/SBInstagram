//
//  SBInstagramCell.h
//  instagram
//
//  Created by Santiago Bustamante on 8/31/13.
//  Copyright (c) 2013 Pineapple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBInstagramMediaEntity.h"
#import <AVFoundation/AVFoundation.h>

@interface SBInstagramCell : UICollectionViewCell

@property (strong, nonatomic) UILabel *userLabel;
@property (strong, nonatomic) UIImageView *userImage;
@property (strong, nonatomic) UILabel *captionLabel;
@property (strong, nonatomic) UIButton *imageButton;
@property (assign, nonatomic) SBInstagramMediaPagingEntity *entity;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) BOOL showOnePicturePerRow;
@property (nonatomic, strong) UIImageView *videoPlayImage;

@property (nonatomic, strong) AVPlayerLayer *avPlayerLayer;
@property (nonatomic, strong) AVPlayer *avPlayer;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL loadComplete;

@property (nonatomic, copy) void (^videoControlBlock)(AVPlayer *avPlayer,BOOL tap,UIImageView *playImage);

-(void)setEntity:(SBInstagramMediaPagingEntity *)entity andIndexPath:(NSIndexPath *)index;
-(void) playVideo:(NSString *)url;
-(void) removeNoti;
@end
