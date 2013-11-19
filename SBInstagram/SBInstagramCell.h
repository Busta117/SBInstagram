//
//  SBInstagramCell.h
//  instagram
//
//  Created by Santiago Bustamante on 8/31/13.
//  Copyright (c) 2013 Pineapple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSTCollectionView.h"
#import "SBInstagramMediaEntity.h"

@interface SBInstagramCell : PSUICollectionViewCell

@property (assign, nonatomic) UILabel* label;
@property (assign, nonatomic) UIButton *imageButton;
@property (assign, nonatomic) SBInstagramMediaPagingEntity *entity;
@property (nonatomic, assign) NSIndexPath *indexPath;

-(void)setEntity:(SBInstagramMediaPagingEntity *)entity andIndexPath:(NSIndexPath *)index;

@end
