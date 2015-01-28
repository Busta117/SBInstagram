//
//  SBInstagramCollectionViewController.m
//  instagram
//
//  Created by Santiago Bustamante on 8/31/13.
//  Copyright (c) 2013 Busta117. All rights reserved.
//

#import "SBInstagramCollectionViewController.h"
#import "SBInstagramController.h"
#import "SBInstagramMediaEntity.h"
#import "SBInstagramModel.h"

@interface SBInstagramCollectionViewController()
{
    NSString *currentVideoURL_;
    BOOL isVideoPlaying_;
    
}
@property (nonatomic, strong) NSMutableArray *mediaArray;
@property (nonatomic, strong) SBInstagramController *instagramController;
@property (nonatomic, assign) BOOL downloading;
@property (nonatomic, assign) BOOL hideFooter;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSArray *multipleLastEntities;


@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVPlayerLayer *avPlayerLayer;
@property (nonatomic, strong) UIView *avPlayerView;
@property (nonatomic, strong) NSTimer *timerVideo;
@property (nonatomic, assign) BOOL loadCompleteVideo;
@property (nonatomic, strong) UIImageView *videoPlayImage;


@end

@implementation SBInstagramCollectionViewController

+(NSString *)appVersion{
    return @"2.2";
}

-(NSString *)version{
    return [SBInstagramCollectionViewController appVersion];
}

- (id) initWithCollectionViewLayout:(UICollectionViewLayout *)layout{
    if ((self = [super initWithCollectionViewLayout:layout])) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.activityIndicator startAnimating];
    }
    return self;
}


- (void)viewDidLoad {
	[super viewDidLoad];
    self.title = @"Instagram";
    self.downloading = YES;
    self.mediaArray = [NSMutableArray arrayWithCapacity:0];
    [self.collectionView registerClass:[SBInstagramCell class] forCellWithReuseIdentifier:@"SBInstagramCell"];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];

    [self.navigationController.navigationBar setTranslucent:NO];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.multipleLastEntities = [NSArray array];
    
    self.instagramController = [SBInstagramController instagramControllerWithMainViewController:self];
    self.instagramController.isSearchByTag = self.isSearchByTag;
    self.instagramController.searchTag = self.searchTag;
    [self downloadNext];
    
    self.collectionView.alwaysBounceVertical = YES;
    refreshControl_ = [[SBInstagramRefreshControl alloc] initInScrollView:self.collectionView];
    [refreshControl_ addTarget:self action:@selector(refreshCollection:) forControlEvents:UIControlEventValueChanged];

    loaded_ = YES;
    
    [self showSwitch];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    
}



-(void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];
    
}

-(void) segmentChanged:(id)sender{
    SBInstagramSegmentedControl *segmentedControl = (SBInstagramSegmentedControl *)sender;
    
    if (self.showOnePicturePerRow != segmentedControl.selectedSegmentIndex) {
        self.showOnePicturePerRow = segmentedControl.selectedSegmentIndex;
    }
}

- (void) refreshCollection{
    [self refreshCollection:nil];
}

- (void) refreshCollection:(id) sender{
    [self.mediaArray removeAllObjects];
    [self downloadNext];
    if (self.activityIndicator.isAnimating)
        [self.activityIndicator stopAnimating];
}

- (void) downloadNext{
    __weak typeof(self) weakSelf = self;
    self.downloading = YES;
    if (!self.activityIndicator.isAnimating)
        [self.activityIndicator startAnimating];
    if ([self.mediaArray count] == 0) {
        
        //multiple users id
        if ([SBInstagramModel model].instagramMultipleUsersId) {
            [self.instagramController mediaMultipleUserWithArr:[SBInstagramModel model].instagramMultipleUsersId complete:^(NSArray *mediaArray,NSArray *lastMedias, NSError *error) {
                if ([refreshControl_ isRefreshing]) {
                    [refreshControl_ endRefreshing];
                }
                if (mediaArray.count == 0 && error) {
                    SB_showAlert(@"Instagram", @"No results found", @"OK");
                    [weakSelf.activityIndicator stopAnimating];
                }else{
                    [weakSelf.mediaArray addObjectsFromArray:mediaArray];
                    [weakSelf.collectionView reloadData];
                    weakSelf.multipleLastEntities = lastMedias;
                }
                weakSelf.downloading = NO;
            }];
        }
        //only one user configured
        else{
            NSString *uId = [SBInstagramModel model].instagramUserId ?: INSTAGRAM_USER_ID;
            if (SBInstagramModel.isSearchByTag && [SBInstagramModel searchTag].length > 0) {
                uId = [SBInstagramModel searchTag];
            }
            
            [self.instagramController mediaUserWithUserId:uId andBlock:^(NSArray *mediaArray, NSError *error) {
                if ([refreshControl_ isRefreshing]) {
                    [refreshControl_ endRefreshing];
                }
                if (error || mediaArray.count == 0) {
                    SB_showAlert(@"Instagram", @"No results found", @"OK");
                    [weakSelf.activityIndicator stopAnimating];
                }else{
                    [weakSelf.mediaArray addObjectsFromArray:mediaArray];
                    [weakSelf.collectionView reloadData];
                }
                weakSelf.downloading = NO;
                
            }];
        }
    }
    //download nexts
    else{
        
        //multiple users id
        if ([SBInstagramModel model].instagramMultipleUsersId) {

            [self.instagramController mediaMultiplePagingWithArr:self.multipleLastEntities complete:^(NSArray *mediaArray, NSArray *lastMedia, NSError *error) {
                
                weakSelf.multipleLastEntities = lastMedia;
                
                NSUInteger a = [self.mediaArray count];
                [weakSelf.mediaArray addObjectsFromArray:mediaArray];
                
                NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
                [mediaArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSUInteger b = a+idx;
                    NSIndexPath *path = [NSIndexPath indexPathForItem:b inSection:0];
                    [arr addObject:path];
                }];
                
                [weakSelf.collectionView performBatchUpdates:^{
                    [weakSelf.collectionView insertItemsAtIndexPaths:arr];
                } completion:nil];
                
                weakSelf.downloading = NO;
                
                if (mediaArray.count == 0) {
                    [weakSelf.activityIndicator stopAnimating];
                    weakSelf.activityIndicator.hidden = YES;
                    weakSelf.hideFooter = YES;
                    [weakSelf.collectionView reloadData];
                }
            }];
            
        }else{
            
            [self.instagramController mediaUserWithPagingEntity:[self.mediaArray objectAtIndex:(self.mediaArray.count-1)] andBlock:^(NSArray *mediaArray, NSError *error) {
                
                NSUInteger a = [self.mediaArray count];
                [weakSelf.mediaArray addObjectsFromArray:mediaArray];
                
                NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
                [mediaArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSUInteger b = a+idx;
                    NSIndexPath *path = [NSIndexPath indexPathForItem:b inSection:0];
                    [arr addObject:path];
                }];
                
                [weakSelf.collectionView performBatchUpdates:^{
                    [weakSelf.collectionView insertItemsAtIndexPaths:arr];
                } completion:nil];
                
                weakSelf.downloading = NO;
                
                if (mediaArray.count == 0) {
                    [weakSelf.activityIndicator stopAnimating];
                    weakSelf.activityIndicator.hidden = YES;
                    weakSelf.hideFooter = YES;
                    [weakSelf.collectionView reloadData];
                }
                
            }];
        }
    }
    
}


- (void) setShowOnePicturePerRow:(BOOL)showOnePicturePerRow{
    BOOL reload = NO;
    if (_showOnePicturePerRow != showOnePicturePerRow) {
        reload = YES;
    }
    _showOnePicturePerRow = showOnePicturePerRow;
    if (reload && loaded_) {
        [self.avPlayer pause];
        [[self.avPlayer currentItem] removeObserver:self forKeyPath:@"status"];
        [self.avPlayer replaceCurrentItemWithPlayerItem:nil];
        [self.avPlayerView removeFromSuperview];
        isVideoPlaying_ = NO;
        [self.collectionView reloadData];
    }
    
}

- (void) setShowSwitchModeView:(BOOL)showSwitchModeView{
    _showSwitchModeView = showSwitchModeView;
    if (loaded_) {
        [self showSwitch];
    }

}

- (void) showSwitch{
    if (self.showSwitchModeView) {
        segmentedControl_ = [[SBInstagramSegmentedControl alloc] initWithItems:@[[UIImage imageNamed:@"sb-grid-selected.png"],[UIImage imageNamed:@"sb-table-selected.png"]]];
        [self.view addSubview:segmentedControl_];
        
        segmentedControl_.selectedSegmentIndex = _showOnePicturePerRow;
        [segmentedControl_ addTarget:self
                              action:@selector(segmentChanged:)
                    forControlEvents:UIControlEventValueChanged];
        
        CGRect frame = self.collectionView.frame;
        frame.origin.y = CGRectGetMaxY(segmentedControl_.frame) + 5;
        frame.size.height = CGRectGetHeight([[UIScreen mainScreen] applicationFrame]) - CGRectGetMinY(frame);
        self.collectionView.frame = frame;
        
    }else{
        if (segmentedControl_) {
            [segmentedControl_ removeFromSuperview];
            segmentedControl_ = nil;
        }
        
        CGRect frame = self.collectionView.frame;
        frame.origin.y = 0;
        frame.size.height = CGRectGetHeight([[UIScreen mainScreen] applicationFrame]);
        self.collectionView.frame = frame;
    }
}



- (void) videoConfig{
    
    if (!currentVideoURL_) {
        return;
    }
    
    AVAsset* avAsset = [AVAsset assetWithURL:[NSURL URLWithString:currentVideoURL_]];
    AVPlayerItem *avPlayerItem =[[AVPlayerItem alloc]initWithAsset:avAsset];
    
    if (!self.avPlayer) {
        self.avPlayer = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
        [avPlayerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    }else{
        [[self.avPlayer currentItem] removeObserver:self forKeyPath:@"status"];
        [self.avPlayer replaceCurrentItemWithPlayerItem:nil];
        [self.avPlayer replaceCurrentItemWithPlayerItem:avPlayerItem];
        [avPlayerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    }
    
    if (!self.avPlayerLayer) {
        self.avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
        self.avPlayerView = [[UIView alloc] initWithFrame:CGRectZero];
//        self.avPlayerLayer.backgroundColor = [UIColor redColor].CGColor;
//        self.avPlayerView.backgroundColor = [UIColor greenColor];
        [self.avPlayerView.layer addSublayer:self.avPlayerLayer];
        [self.collectionView addSubview:self.avPlayerView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:nil];
        
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapVideo:)];
        [self.avPlayerView addGestureRecognizer:singleFingerTap];
        
        if (!_videoPlayImage) {
            _videoPlayImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        }
        [_videoPlayImage setImage:[UIImage imageNamed:[SBInstagramModel model].videoPlayImageName]];
        [self.avPlayerView addSubview:_videoPlayImage];
        
    }
    
    [self.avPlayerView removeFromSuperview];
    [self.collectionView addSubview:self.avPlayerView];
    
    
    
    [self.avPlayer seekToTime:kCMTimeZero];
    [self.avPlayer play];
    isVideoPlaying_ = YES;
    [self.videoPlayImage setImage:[UIImage imageNamed:[SBInstagramModel model].videoPlayImageName]];
    
    self.loadCompleteVideo = NO;

}

- (void)tapVideo:(UITapGestureRecognizer *)recognizer {

    if (self.avPlayer.rate == 0) {
        if (CMTimeCompare(self.avPlayer.currentItem.currentTime, self.avPlayer.currentItem.duration) == 0) {
            [self.avPlayer seekToTime:kCMTimeZero];
        }
        [self.avPlayer play];
        [self.videoPlayImage setImage:[UIImage imageNamed:[SBInstagramModel model].videoPauseImageName]];
        
        if (!_loadCompleteVideo) {
            _timerVideo = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(loadingVideo) userInfo:nil repeats:YES];
        }
        
        
    }else{
        [self.avPlayer pause];
        [self.videoPlayImage setImage:[UIImage imageNamed:[SBInstagramModel model].videoPlayImageName]];
    }

    
}

- (void) loadingVideo{
    self.videoPlayImage.hidden = !self.videoPlayImage.hidden;
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    
    if ([self.avPlayer currentItem] == [notification object]) {
        [self.avPlayer seekToTime:kCMTimeZero];
        [self.videoPlayImage setImage:[UIImage imageNamed:[SBInstagramModel model].videoPlayImageName]];
    }
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
                    if (_timerVideo) {
                        [_timerVideo invalidate];
                    }
                    break;
                case AVPlayerItemStatusReadyToPlay:
                    if (_timerVideo) {
                        [_timerVideo invalidate];
                    }
                    self.loadCompleteVideo = YES;
                    self.videoPlayImage.hidden = NO;
                    [self.videoPlayImage setImage:[UIImage imageNamed:[SBInstagramModel model].videoPauseImageName]];
                    break;
                case AVPlayerItemStatusUnknown:
                    break;
            }
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.mediaArray count];
}



///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SBInstagramCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SBInstagramCell" forIndexPath:indexPath];

    if ([self.mediaArray count]>0) {
        SBInstagramMediaPagingEntity *entity = [self.mediaArray objectAtIndex:indexPath.row];
        cell.indexPath = indexPath;
        cell.showOnePicturePerRow = self.showOnePicturePerRow;
        
        __weak SBInstagramCell* weakCell = cell;
        
        [cell setVideoControlBlock:^(BOOL tap, NSString *videoUrl) {
            
            if (tap) {
                currentVideoURL_ = videoUrl;
                [self videoConfig];
                
                weakCell.videoPlayImage.hidden = YES;
                
                CGPoint point = [weakCell convertPoint:weakCell.imageButton.frame.origin toView:self.collectionView];
                
                CGRect frame = weakCell.imageButton.frame;
                frame.origin = point;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.avPlayerView.frame = frame;
                    [self.avPlayerLayer setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
                });

                
                self.videoPlayImage.frame = CGRectMake(CGRectGetMaxX(weakCell.imageButton.frame) - 34, 4, 30, 30);
                
                if (_timerVideo) {
                    [_timerVideo invalidate];
                }
                _timerVideo = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(loadingVideo) userInfo:nil repeats:YES];
            }
            
            
            
        }];
        
        if (entity.mediaEntity.type != SBInstagramMediaTypeVideo || !self.showOnePicturePerRow) {
            currentVideoURL_ = nil;
        }
        
        [cell setEntity:entity indexPath:indexPath playerContent:self.avPlayer];
        

    }

    if (indexPath.row == [self.mediaArray count]-1 && !self.downloading) {
        [self downloadNext];
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell1 forItemAtIndexPath:(NSIndexPath *)indexPath

{
    if ([collectionView.indexPathsForVisibleItems indexOfObject:indexPath] == NSNotFound)
    {
//        SBInstagramCell *cell = (SBInstagramCell *)cell1;
        
        if (isVideoPlaying_) {
            [self.avPlayer pause];
            [[self.avPlayer currentItem] removeObserver:self forKeyPath:@"status"];
            [self.avPlayer replaceCurrentItemWithPlayerItem:nil];
            [self.avPlayerView removeFromSuperview];
            isVideoPlaying_ = NO;
        }

    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (self.hideFooter) {
        return CGSizeZero;
    }
    return CGSizeMake(CGRectGetWidth(self.view.frame),40);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if (kind != UICollectionElementKindSectionFooter || self.hideFooter){
        return nil;
    }
    
    UICollectionReusableView *foot = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footer" forIndexPath:indexPath];
    
    CGPoint center = self.activityIndicator.center;
    center.x = foot.center.x;
    center.y = 20;
    self.activityIndicator.center = center;
    
    [foot addSubview:self.activityIndicator];
    
    return foot;
}


///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDelegateFlowLayout


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (self.showOnePicturePerRow) {
        SBInstagramMediaPagingEntity *entity = [self.mediaArray objectAtIndex:indexPath.row];
        if (SB_IS_IPAD) {
            
            return CGSizeMake(600, [SBInstagramCell cellHeightForEntity:entity]);
        }
        
        return CGSizeMake(320, [SBInstagramCell cellHeightForEntity:entity]);
    }else{
        if (SB_IS_IPAD) {
            return CGSizeMake(200, 200);
        }
        return CGSizeMake(100, 100);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (self.showOnePicturePerRow) {
        return 0;
    }
    return 10* (SB_IS_IPAD?2:1);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (self.showOnePicturePerRow) {
        return 0;
    }
    return 10 * (SB_IS_IPAD?2:1);
}


@end
