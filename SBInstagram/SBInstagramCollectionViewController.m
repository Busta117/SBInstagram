//
//  SBInstagramCollectionViewController.m
//  instagram
//
//  Created by Santiago Bustamante on 8/31/13.
//  Copyright (c) 2013 Pineapple Inc. All rights reserved.
//

#import "SBInstagramCollectionViewController.h"
#import "SBInstagramController.h"
#import "SBInstagramMediaEntity.h"
#import "SBInstagramModel.h"

@interface SBInstagramCollectionViewController()

@property (nonatomic, strong) NSMutableArray *mediaArray;
@property (nonatomic, strong) SBInstagramController *instagramController;
@property (nonatomic, assign) BOOL downloading;
@property (nonatomic, assign) BOOL hideFooter;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSMutableArray *videoPlayerArr;
@property (nonatomic, strong) NSMutableArray *videoPlayerImagesArr;

@end

@implementation SBInstagramCollectionViewController

-(NSString *)version{
    return @"2.0.1";
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
    
    self.instagramController = [SBInstagramController instagramControllerWithMainViewController:self];
    self.instagramController.isSearchByTag = self.isSearchByTag;
    self.instagramController.searchTag = self.searchTag;
    [self downloadNext];
    
    self.collectionView.alwaysBounceVertical = YES;
    refreshControl_ = [[SBInstagramRefreshControl alloc] initInScrollView:self.collectionView];
    [refreshControl_ addTarget:self action:@selector(refreshCollection:) forControlEvents:UIControlEventValueChanged];

    loaded_ = YES;
    
    self.videoPlayerArr = [NSMutableArray array];
    self.videoPlayerImagesArr = [NSMutableArray array];
    [self showSwitch];
    
}



-(void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];
    
}

-(void) segmentChanged:(id)sender{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
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
        NSString *uId = [SBInstagramModel model].instagramUserId ?: INSTAGRAM_USER_ID;
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


- (void) setShowOnePicturePerRow:(BOOL)showOnePicturePerRow{
    BOOL reload = NO;
    if (_showOnePicturePerRow != showOnePicturePerRow) {
        reload = YES;
    }
    _showOnePicturePerRow = showOnePicturePerRow;
    if (reload && loaded_) {
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
        segmentedControl_ = [[UISegmentedControl alloc] initWithItems:@[[UIImage imageNamed:@"sb-grid-selected.png"],[UIImage imageNamed:@"sb-table-selected.png"]]];
        [self.view addSubview:segmentedControl_];
        
        segmentedControl_.segmentedControlStyle = UISegmentedControlStylePlain;
        CGRect frame = segmentedControl_.frame;
        frame.origin.y = 5;
        frame.size.width  = 200;
        frame.origin.x = self.view.center.x - 100;
        segmentedControl_.frame = frame;
        segmentedControl_.selectedSegmentIndex = _showOnePicturePerRow;
        [segmentedControl_ addTarget:self
                              action:@selector(segmentChanged:)
                    forControlEvents:UIControlEventValueChanged];
        
        frame = self.collectionView.frame;
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

//- (void) playVideo{
//    
//    if (self.videoPlayerArr.count == 0) {
//        return;
//    }
//    
//    [self.videoPlayerArr enumerateObjectsUsingBlock:^(SBInstagramCell *cell, NSUInteger idx, BOOL *stop) {
//        if (cell.avPlayer) {
//            [cell.avPlayer pause];
//        }
//    }];
//
//    [self.videoPlayerArr enumerateObjectsUsingBlock:^(SBInstagramCell *cell, NSUInteger idx, BOOL *stop) {
//        if (cell.entity.mediaEntity.type == SBInstagramMediaTypeVideo) {
//            NSString *url = ((SBInstagramVideoEntity *) cell.entity.mediaEntity.videos[@"low_resolution"]).url;
//            if ([SBInstagramModel model].playStandardResolution) {
//                url = ((SBInstagramVideoEntity *) cell.entity.mediaEntity.videos[@"standard_resolution"]).url;
//            }
//            
//            [cell playVideo:url];
//            
//        }
//        *stop = YES;
//
//    }];
//    
//}

- (void) pauseAllVideos:(AVPlayer *)avPlayer{
    [self.videoPlayerArr enumerateObjectsUsingBlock:^(AVPlayer *obj, NSUInteger idx, BOOL *stop) {
        if (avPlayer != obj) {
            [obj pause];
            UIImageView *img = self.videoPlayerImagesArr[idx];
            img.image = [UIImage imageNamed:[SBInstagramModel model].videoPlayImageName];
        }else{
            UIImageView *img = self.videoPlayerImagesArr[idx];
            img.image = [UIImage imageNamed:[SBInstagramModel model].videoPauseImageName];
        }
    }];
    [avPlayer play];
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
        [cell setVideoControlBlock:^(AVPlayer *avPlayer, BOOL tap, UIImageView *videoPlayImage) {
            if (!tap) {
                [self.videoPlayerArr addObject:avPlayer];
                [self.videoPlayerImagesArr addObject:videoPlayImage];
//                [self playVideo];
            }else{
                [self pauseAllVideos:avPlayer];
            }
            
        }];
        [cell setEntity:entity andIndexPath:indexPath];
//        [self.videoPlayerArr addObject:cell];
//        [self playVideo];
        

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

        SBInstagramCell *cell = (SBInstagramCell *)cell1;
        [cell.avPlayer pause];
        [cell removeNoti];
        [self.videoPlayerArr removeObject:cell.avPlayer];
        [self.videoPlayerImagesArr removeObject:cell.videoPlayImage];

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
        if (SB_IS_IPAD) {
            return CGSizeMake(600, 680);
        }
        return CGSizeMake(320, 400);
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
