//
//  SBInstagramCell.m
//  instagram
//
//  Created by Santiago Bustamante on 8/31/13.
//  Copyright (c) 2013 Pineapple Inc. All rights reserved.
//

#import "SBInstagramCell.h"
#import "SBInstagramImageViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation SBInstagramCell

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {

    }
    return self;
}


-(void)setEntity:(SBInstagramMediaPagingEntity *)entity andIndexPath:(NSIndexPath *)index{
    
    [self setupCell];
    
    [self.imageButton setBackgroundImage:[UIImage imageNamed:[SBInstagramModel model].loadingImageName] forState:UIControlStateNormal];
    _entity = entity;
    
    SBInstagramImageEntity *imgEntity = entity.mediaEntity.images[@"thumbnail"];
    if (imgEntity.width <= CGRectGetWidth(self.imageButton.frame)) {
        imgEntity = entity.mediaEntity.images[@"low_resolution"];
    }
    
    if (imgEntity.width <= CGRectGetWidth(self.imageButton.frame)) {
        imgEntity = entity.mediaEntity.images[@"standard_resolution"];
    }
    
    [imgEntity downloadImageWithBlock:^(UIImage *image, NSError *error) {
        if (self.indexPath.row == index.row) {
            [self.imageButton setBackgroundImage:image forState:UIControlStateNormal];
        }
    }];
    
    self.imageButton.userInteractionEnabled = !self.showOnePicturePerRow;
    self.imageButton.center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);

    
    if (self.showOnePicturePerRow) {
        
        self.userLabel.text = self.entity.mediaEntity.userName;
        [self.contentView addSubview:self.userLabel];
        
        self.captionLabel.text = self.entity.mediaEntity.caption;
        [self.contentView addSubview:self.captionLabel];
        
        [self.userImage setImage:[UIImage imageNamed:[SBInstagramModel model].loadingImageName]];
        [self.contentView addSubview:self.userImage];
        
        [SBInstagramModel downloadImageWithUrl:self.entity.mediaEntity.profilePicture andBlock:^(UIImage *image2, NSError *error) {
            if (image2 && !error && self.indexPath.row == index.row) {
                [self.userImage setImage:image2];
            }
        }];
        
        self.videoPlayImage.frame = CGRectMake(CGRectGetMaxX(self.imageButton.frame) - 34, CGRectGetMinY(self.imageButton.frame) + 4, 30, 30);
        
    }else{
        [self.userLabel removeFromSuperview];
        [self.userImage removeFromSuperview];
        [self.captionLabel removeFromSuperview];
        
        self.videoPlayImage.frame = CGRectMake(CGRectGetMaxX(self.imageButton.frame) - 22, CGRectGetMinY(self.imageButton.frame) + 2, 20, 20);
        
    }
    
    self.videoPlayImage.hidden = YES;
    if (entity.mediaEntity.type == SBInstagramMediaTypeVideo) {
        self.videoPlayImage.hidden = NO;
        
        if (self.showOnePicturePerRow) {
            NSString *url = ((SBInstagramVideoEntity *) entity.mediaEntity.videos[@"low_resolution"]).url;
            if ([SBInstagramModel model].playStandardResolution) {
                url = ((SBInstagramVideoEntity *) entity.mediaEntity.videos[@"standard_resolution"]).url;
            }
            AVAsset* avAsset = [AVAsset assetWithURL:[NSURL URLWithString:url]];
            AVPlayerItem *avPlayerItem =[[AVPlayerItem alloc]initWithAsset:avAsset];
            
            if (!self.avPlayer) {
                self.avPlayer = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
            }else{
                [self.avPlayer replaceCurrentItemWithPlayerItem:avPlayerItem];
            }
            
            if (!self.avPlayerLayer) {
                self.avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
            }
            
            [self.avPlayerLayer setFrame:self.imageButton.frame];
            [self.imageButton.superview.layer insertSublayer:self.avPlayerLayer above:self.imageButton.layer];
            [self.avPlayer seekToTime:kCMTimeZero];
            [self.avPlayer play];
            [self.videoPlayImage setImage:[UIImage imageNamed:[SBInstagramModel model].videoPauseImageName]];
            self.imageButton.userInteractionEnabled = YES;
        }else{
            if (self.avPlayerLayer) {
                [self.avPlayerLayer removeFromSuperlayer];
            }
        }
        
    }
    
    
}

-(void) selectedImage:(id)selector{
    
    if (self.entity.mediaEntity.type == SBInstagramMediaTypeVideo && self.showOnePicturePerRow) {
        
        if (self.avPlayer.rate == 0) {
            if (CMTimeCompare(self.avPlayer.currentItem.currentTime, self.avPlayer.currentItem.duration) == 0) {
                [self.avPlayer seekToTime:kCMTimeZero];
            }
            [self.avPlayer play];
            [self.videoPlayImage setImage:[UIImage imageNamed:[SBInstagramModel model].videoPauseImageName]];
        }else{
            [self.avPlayer pause];
            [self.videoPlayImage setImage:[UIImage imageNamed:[SBInstagramModel model].videoPlayImageName]];
        }
        
        return;
    }
    
    UIViewController *viewCon = (UIViewController *)self.nextResponder;
    
    while (![viewCon isKindOfClass:[UINavigationController class]]) {
        viewCon = (UIViewController *)viewCon.nextResponder;
    }
    
    SBInstagramImageViewController *img = [SBInstagramImageViewController imageViewerWithEntity:self.entity.mediaEntity];
    
    [((UINavigationController *)viewCon) pushViewController:img animated:YES];
    
}

- (void) setupCell{
    
    if (!_imageButton) {
        _imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    [_imageButton setFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.width)];
    [_imageButton addTarget:self action:@selector(selectedImage:) forControlEvents:UIControlEventTouchUpInside];
    [_imageButton setBackgroundImage:[UIImage imageNamed:[SBInstagramModel model].loadingImageName] forState:UIControlStateNormal];
    self.imageButton.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_imageButton];
    
    if (!_userLabel) {
        _userLabel = [[UILabel alloc] init];
    }
    _userLabel.frame = CGRectMake(40, 0, CGRectGetWidth(self.frame) - 45, 35);
    _userLabel.textColor = [UIColor blackColor];
    _userLabel.font = [_userLabel.font fontWithSize:12];
    
    if (!_captionLabel) {
        _captionLabel = [[UILabel alloc] init];
    }
    
    _captionLabel.frame = CGRectMake(5, CGRectGetHeight(self.frame) - 40, CGRectGetWidth(self.frame) - 10, 30);
    _captionLabel.numberOfLines = 0;
    _captionLabel.textColor = [UIColor blackColor];
    _captionLabel.font = [_captionLabel.font fontWithSize:12];
    
    if (!_userImage) {
        _userImage = [[UIImageView alloc] init];
    }
    _userImage.frame = CGRectMake(0, 0, 35, 35);
    _userImage.contentMode = UIViewContentModeScaleAspectFit;
    _userImage.layer.masksToBounds = YES;
    _userImage.layer.cornerRadius = 17.5;
    
    
    if (!_videoPlayImage) {
        _videoPlayImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    [_videoPlayImage setImage:[UIImage imageNamed:[SBInstagramModel model].videoPlayImageName]];
    [self.contentView addSubview:_videoPlayImage];
    
}


@end
