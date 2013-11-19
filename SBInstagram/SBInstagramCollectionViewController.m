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

@interface SBInstagramCollectionViewController()

@property (nonatomic, strong) NSMutableArray *mediaArray;
@property (nonatomic, strong) SBInstagramController *instagramController;
@property (nonatomic, assign) BOOL downloading;

@end

@implementation SBInstagramCollectionViewController

- (void)viewDidLoad {
	[super viewDidLoad];
    self.title = @"Instagram";
    self.downloading = YES;
    self.mediaArray = [NSMutableArray arrayWithCapacity:0];
    [self.collectionView registerClass:[SBInstagramCell class] forCellWithReuseIdentifier:@"SBInstagramCell"];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    
    self.instagramController = [SBInstagramController instagramControllerWithMainViewController:self];
    [self downloadNext];
    
}

-(void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];
}

- (void) downloadNext{
    self.downloading = YES;
    if ([self.mediaArray count] == 0) {
        [self.instagramController mediaUserWithUserId:INSTAGRAM_USER_ID andBlock:^(NSArray *mediaArray, NSError *error) {
            [self.mediaArray addObjectsFromArray:mediaArray];
            [self.collectionView reloadData];
            self.downloading = NO;
        }];
    }else{
        [self.instagramController mediaUserWithPagingWntity:[self.mediaArray objectAtIndex:(self.mediaArray.count-1)] andBlock:^(NSArray *mediaArray, NSError *error) {
            
            int a = [self.mediaArray count]-1;
            [self.mediaArray addObjectsFromArray:mediaArray];
            
            NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
            [mediaArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                int b = a+idx;
                NSIndexPath *path = [NSIndexPath indexPathForItem:b inSection:0];
                [arr addObject:path];
            }];
            
            [self.collectionView performBatchUpdates:^{
                [self.collectionView insertItemsAtIndexPaths:arr];
            } completion:nil];
            
            self.downloading = NO;
            
        }];
    }    
    
}


///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSTCollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return 33;//[self.mediaArray count];
}



///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSTCollectionViewDelegate

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SBInstagramCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SBInstagramCell" forIndexPath:indexPath];

    if ([self.mediaArray count]>0) {
        SBInstagramMediaPagingEntity *entity = [self.mediaArray objectAtIndex:indexPath.row];
        cell.indexPath = indexPath;
        [cell setEntity:entity andIndexPath:indexPath];
    }

    
//    if (indexPath.row == ([self.mediaArray count]-1) && !self.downloading && self.mediaArray.count < 200) {
//        [self downloadNext];
//    }
    
    return cell;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSTCollectionViewDelegateFlowLayout

- (CGSize)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (IS_IPAD) {
        return CGSizeMake(200, 200);
    }
    return CGSizeMake(100, 100);

}

- (CGFloat)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10* (IS_IPAD?2:1);
}

- (CGFloat)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10 * (IS_IPAD?2:1);
}


@end
