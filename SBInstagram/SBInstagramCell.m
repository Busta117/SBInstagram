//
//  SBInstagramCell.m
//  instagram
//
//  Created by Santiago Bustamante on 8/31/13.
//  Copyright (c) 2013 Busta117. All rights reserved.
//

#import "SBInstagramCell.h"
#import "SBInstagramImageViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SBInstagramCollectionViewController.h"

@implementation SBInstagramCell

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {

    }
    return self;
}


-(void)setEntity:(SBInstagramMediaPagingEntity *)entity indexPath:(NSIndexPath *)index playerContent:(id )avPlayerIn{
    
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
        
        
        CGRect frame = self.imageButton.frame;
        frame.origin.y = CGRectGetMaxY(self.userImage.frame) + 4;
        self.imageButton.frame = frame;
        
        
        frame = self.likesLabel.frame;
        frame.origin.y = CGRectGetMaxY(self.imageButton.frame) + 4;
        self.likesLabel.frame = frame;
        self.likesLabel.text =  [NSString stringWithFormat:@"%d Likes", self.entity.mediaEntity.likesCount];
        [self.contentView addSubview:self.likesLabel];
        
        NSString *newCaption = [NSString stringWithFormat:@"%@ %@",self.entity.mediaEntity.userName,self.entity.mediaEntity.caption];
        
        CGSize constrainedSize = CGSizeMake(CGRectGetWidth(self.captionLabel.frame)  , 9999);
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [UIFont systemFontOfSize:12], NSFontAttributeName,
                                              nil];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:newCaption attributes:attributesDictionary];
        
        NSRange range=[newCaption rangeOfString:self.entity.mediaEntity.userName];
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:10.0/255.0 green:83.0/255.0 blue:143.0/255.0 alpha:1] range:range];
        
        CGRect requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];

        frame = self.captionLabel.frame;
        frame.origin.y = CGRectGetMaxY(self.likesLabel.frame) + 4;
        frame.size.height = CGRectGetHeight(requiredHeight);
        self.captionLabel.frame = frame;
        
        [self.captionLabel setAttributedText:string];
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
        [self.likesLabel removeFromSuperview];
        
        self.videoPlayImage.frame = CGRectMake(CGRectGetMaxX(self.imageButton.frame) - 22, CGRectGetMinY(self.imageButton.frame) + 2, 20, 20);
        
    }
    
    self.videoPlayImage.hidden = YES;
    if (entity.mediaEntity.type == SBInstagramMediaTypeVideo) {
        self.videoPlayImage.hidden = NO;
        if (self.showOnePicturePerRow) {
            self.imageButton.userInteractionEnabled = YES;
        }
        
    }
    
}



-(void) selectedImage:(id)selector{
    
    if (self.entity.mediaEntity.type == SBInstagramMediaTypeVideo && self.showOnePicturePerRow) {

        NSString *url = ((SBInstagramVideoEntity *) _entity.mediaEntity.videos[@"low_resolution"]).url;
        if ([SBInstagramModel model].playStandardResolution) {
            url = ((SBInstagramVideoEntity *) _entity.mediaEntity.videos[@"standard_resolution"]).url;
        }
        if (self.videoControlBlock) {
            self.videoControlBlock(YES,url);
        }
//        
//        if (self.avPlayer.rate == 0) {
//            if (CMTimeCompare(self.avPlayer.currentItem.currentTime, self.avPlayer.currentItem.duration) == 0) {
//                [self.avPlayer seekToTime:kCMTimeZero];
//            }
//            [self.avPlayer play];
//            [self.videoPlayImage setImage:[UIImage imageNamed:[SBInstagramModel model].videoPauseImageName]];
//            
//            if (!_loadComplete) {
//                _timer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(loadingVideo) userInfo:nil repeats:YES];
//            }
//
//        
//        }else{
//            [self.avPlayer pause];
//            [self.videoPlayImage setImage:[UIImage imageNamed:[SBInstagramModel model].videoPlayImageName]];
//        }
        
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
    _userLabel.textColor = [UIColor colorWithRed:10.0/255.0 green:83.0/255.0 blue:143.0/255.0 alpha:1];
    _userLabel.font = [UIFont boldSystemFontOfSize:12];
    
    if (!_captionLabel) {
        _captionLabel = [[UILabel alloc] init];
    }
    
    _captionLabel.frame = CGRectMake(5, CGRectGetHeight(self.frame) - 40, CGRectGetWidth(self.frame) - 10, 30);
    _captionLabel.numberOfLines = 0;
    _captionLabel.textColor = [UIColor blackColor];
    _captionLabel.font = [_captionLabel.font fontWithSize:12];
    
    
    if (!_likesLabel) {
        _likesLabel = [[UILabel alloc] init];
    }
    _likesLabel.frame = CGRectMake(5, CGRectGetHeight(self.frame) - 40, CGRectGetWidth(self.frame) - 10, 15);
    _likesLabel.font = [_likesLabel.font fontWithSize:12];
    _likesLabel.textColor = [UIColor colorWithRed:10.0/255.0 green:83.0/255.0 blue:143.0/255.0 alpha:1];
    
    
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


+ (CGFloat) cellHeightForEntity:(SBInstagramMediaPagingEntity *)entityPag{
    SBInstagramMediaEntity *entity = entityPag.mediaEntity;
    
    NSString *newCaption = [NSString stringWithFormat:@"%@ %@",entity.userName,entity.caption];
    
    CGSize constrainedSize = CGSizeMake((SB_IS_IPAD?600:320) - 10 , 9999);
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont systemFontOfSize:12], NSFontAttributeName,
                                          nil];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:newCaption attributes:attributesDictionary];
    
    NSRange range=[newCaption rangeOfString:entity.userName];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:10.0/255.0 green:83.0/255.0 blue:143.0/255.0 alpha:1] range:range];
    
    CGRect requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    
    return CGRectGetHeight(requiredHeight) + (SB_IS_IPAD?670:390);
    
}

@end
