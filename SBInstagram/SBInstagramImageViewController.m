//
//  SBInstagramImageViewController.m
//  MedellinHipHop
//
//  Created by Santiago Bustamante on 9/2/13.
//  Copyright (c) 2013 Busta117. All rights reserved.
//

#import "SBInstagramImageViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SBInstagramCollectionViewController.h"

@interface SBInstagramImageViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *likesTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;

@end

@implementation SBInstagramImageViewController


+ (id) imageViewerWithEntity:(SBInstagramMediaEntity *)entity{
    SBInstagramImageViewController *instance = [[SBInstagramImageViewController alloc] initWithNibName:@"SBInstagramImageViewController" bundle:nil];
    instance.entity = entity;
    return instance;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLayoutSubviews{
    if (self.avPlayerLayer) {
        CGRect frame = self.imageView.frame;
        frame.size.width = frame.size.height;
        [self.avPlayerLayer setFrame:self.imageView.frame];
        
        self.videoPlayImage.frame = CGRectMake(self.imageView.center.x + CGRectGetHeight(self.avPlayerLayer.frame)/2 - 34, CGRectGetMinY(self.avPlayerLayer.frame) + 4, 30, 30);
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;

    
    [self setCustomAutolayout];
    
    
    self.title = @"";
    
    SBInstagramImageEntity *picEntity = self.entity.images[@"standard_resolution"];
    [SBInstagramModel downloadImageWithUrl:picEntity.url andBlock:^(UIImage *image, NSError *error) {
        [weakSelf.activityIndicator stopAnimating];
        if (image && !error) {
            [weakSelf.imageView setImage:image];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something is wrong" message:@"Please check your Internet connection and try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
    
//    frame = self.likesLabel.frame;
    if (self.entity.likesCount > 0) {
        self.likesLabel.text = [NSString stringWithFormat:@"%d Likes",self.entity.likesCount];
//        frame.origin.y = CGRectGetMaxY(self.containerView.frame) + 2;
    }else{
        self.likesLabel.hidden = YES;
        _likesTopConstraint.constant = - CGRectGetHeight(self.likesLabel.frame)-4;
//        frame.origin.y = CGRectGetMaxY(self.containerView.frame) - CGRectGetHeight(frame);
    }
//    self.likesLabel.frame = frame;
    
    
    NSString *newCaption = [NSString stringWithFormat:@"%@ %@",self.entity.userName,self.entity.caption];
    
    CGSize constrainedSize = CGSizeMake(self.captionLabel.frame.size.width  , 9999);
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [self.captionLabel font], NSFontAttributeName,
                                          nil];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:newCaption attributes:attributesDictionary];
    
    NSRange range=[newCaption rangeOfString:self.entity.userName];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:10.0/255.0 green:83.0/255.0 blue:143.0/255.0 alpha:1] range:range];
    
    CGRect requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    [self.captionLabel setAttributedText:string];
//    CGRect frame = self.captionLabel.frame;
    self.captionHeightConstraint.constant = CGRectGetHeight(requiredHeight);
    [self.view layoutIfNeeded];
//    self.captionLabel.frame = frame;
    
    
    CGSize size = self.scrollView.contentSize;
    size.height = CGRectGetMaxY(self.captionLabel.frame) + 5;
    self.scrollView.contentSize = size;
//    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].applicationFrame.size.width, CGRectGetMaxY(self.captionLabel.frame) + 10);
    
    
    self.activityIndicator.center = self.imageView.center;
    
    
    self.userLabel = [[UILabel alloc] init];
    self.userLabel.frame = CGRectMake(CGRectGetMinX(self.imageView.frame) + 55, CGRectGetMinY(self.imageView.frame) - 45, CGRectGetWidth(self.imageView.frame) - 65, 35);
    self.userLabel.textColor = [UIColor colorWithRed:10.0/255.0 green:83.0/255.0 blue:143.0/255.0 alpha:1];
    self.userLabel.backgroundColor = [UIColor clearColor];
    self.userLabel.font = [UIFont boldSystemFontOfSize:12];
    
    self.userImage = [[UIImageView alloc] init];
    self.userImage.frame = CGRectMake(CGRectGetMinX(self.imageView.frame) + 10, CGRectGetMinY(self.imageView.frame) - 45, 35, 35);
    self.userImage.contentMode = UIViewContentModeScaleAspectFit;
    self.userImage.layer.masksToBounds = YES;
    self.userImage.layer.cornerRadius = 17.5;
    
    self.userLabel.text = self.entity.userName;
    [self.imageView.superview addSubview:self.userLabel];
    
    [self.userImage setImage:[UIImage imageNamed:[SBInstagramModel model].loadingImageName]];
    [self.imageView.superview addSubview:self.userImage];
    
    [SBInstagramModel downloadImageWithUrl:self.entity.profilePicture andBlock:^(UIImage *image2, NSError *error) {
        if (image2 && !error) {
            [weakSelf.userImage setImage:image2];
        }
    }];
    
    
    
    //video
    if (self.entity.type == SBInstagramMediaTypeVideo) {
        
        if (!_videoPlayImage) {
            _videoPlayImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        }
        [_videoPlayImage setImage:[UIImage imageNamed:[SBInstagramModel model].videoPlayImageName]];
        [self.imageView.superview addSubview:_videoPlayImage];
        
        self.videoPlayImage.frame = CGRectMake(CGRectGetMaxX(self.imageView.frame) - 34, CGRectGetMinY(self.imageView.frame) + 4, 30, 30);
        
        
        NSString *url = ((SBInstagramVideoEntity *) self.entity.videos[@"low_resolution"]).url;
        if ([SBInstagramModel model].playStandardResolution) {
            url = ((SBInstagramVideoEntity *) self.entity.videos[@"standard_resolution"]).url;
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
        
        [self.avPlayerLayer setFrame:self.imageView.frame];
        
        [self.imageView.superview.layer insertSublayer:self.avPlayerLayer above:self.imageView.layer];
        [self.avPlayer seekToTime:kCMTimeZero];
        [self.avPlayer play];

        if (!_loadComplete) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(loadingVideo) userInfo:nil repeats:YES];
        }
        
        [self.videoPlayImage setImage:[UIImage imageNamed:[SBInstagramModel model].videoPauseImageName]];
        [avPlayerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
        
        self.controlButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.controlButton.frame = self.imageView.frame;
        [self.controlButton addTarget:self action:@selector(controlAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.imageView.superview addSubview:self.controlButton];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:nil];
        
    }
    


}


-(void) setCustomAutolayout{
    
    [self.containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.likesLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.captionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.scrollView addSubview:self.containerView];
    [self.scrollView addSubview:self.likesLabel];
    [self.scrollView addSubview:self.captionLabel];
    
    float contentWidth = 320;
    if (SB_IS_IPAD) {
        contentWidth = 500;
        self.imageHeightConstraint.constant = contentWidth;
    }
    
    NSDictionary *viewsDictionary = @{@"cv":self.containerView,@"likes":self.likesLabel,@"caption":self.captionLabel};
    NSDictionary *metrics = @{@"screenW": @(contentWidth),
                              @"descriptonW": @(contentWidth-6),
                              @"screenH": @(contentWidth+50)
                              };
    
    NSArray *constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[cv(screenW)]" options:0 metrics:metrics views:viewsDictionary];
    NSArray *constraint_H_likes = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[likes(descriptonW)]" options:0 metrics:metrics views:viewsDictionary];
    NSArray *constraint_H_caption = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[caption(descriptonW)]" options:0 metrics:metrics views:viewsDictionary];
    NSArray *constraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[cv(screenH)]-10-[likes(13)][caption]" options:0 metrics:metrics views:viewsDictionary];
    
    [self.scrollView addConstraints:constraint_H];
    [self.scrollView addConstraints:constraint_V];
    [self.scrollView addConstraints:constraint_H_likes];
    [self.scrollView addConstraints:constraint_H_caption];
    
    NSLayoutConstraint *centerConstraint = [NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    [self.scrollView addConstraint:centerConstraint];
    
    self.captionHeightConstraint = [NSLayoutConstraint constraintWithItem:self.captionLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.likesLabel attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    [self.scrollView addConstraint:self.captionHeightConstraint];
    
    NSLayoutConstraint *centerConstraint_likes = [NSLayoutConstraint constraintWithItem:self.likesLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    [self.scrollView addConstraint:centerConstraint_likes];
    
    NSLayoutConstraint *centerConstraint_caption = [NSLayoutConstraint constraintWithItem:self.captionLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    [self.scrollView addConstraint:centerConstraint_caption];
    
    [self.scrollView layoutIfNeeded];
    
    
}



-(void)viewWillDisappear:(BOOL)animated{
    [[self.avPlayer currentItem] removeObserver:self forKeyPath:@"status"];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    
    if ([self.avPlayer currentItem] == [notification object]) {
        [self.avPlayer seekToTime:kCMTimeZero];
        [self.videoPlayImage setImage:[UIImage imageNamed:[SBInstagramModel model].videoPlayImageName]];
    }
}

- (void) loadingVideo{
    self.videoPlayImage.hidden = !self.videoPlayImage.hidden;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[AVPlayerItem class]])
    {
        AVPlayerItem *item = (AVPlayerItem *)object;
        //playerItem status value changed?
        if ([keyPath isEqualToString:@"status"])
        {   //yes->check it...
            switch(item.status)
            {
                case AVPlayerItemStatusFailed:
                    if (_timer) {
                        [_timer invalidate];
                    }
                    break;
                case AVPlayerItemStatusReadyToPlay:
                    if (_timer) {
                        [_timer invalidate];
                    }
                    self.loadComplete = YES;
                    self.videoPlayImage.hidden = NO;
                    break;
                case AVPlayerItemStatusUnknown:
                    break;
            }
        }
    }
}

- (void) controlAction:(id)sender{
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
}


#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [super viewDidUnload];
}
@end
