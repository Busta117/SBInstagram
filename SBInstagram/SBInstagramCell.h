//
//  SBInstagramCell.h
//  instagram
//
//  Created by Santiago Bustamante on 8/31/13.
//  Copyright (c) 2013 Pineapple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBInstagramMediaEntity.h"

@interface SBInstagramCell : UICollectionViewCell

@property (strong, nonatomic) UILabel *userLabel;
@property (strong, nonatomic) UIImageView *userImage;
@property (strong, nonatomic) UILabel *captionLabel;
@property (strong, nonatomic) UIButton *imageButton;
@property (assign, nonatomic) SBInstagramMediaPagingEntity *entity;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) BOOL showOnePicturePerRow;

-(void)setEntity:(SBInstagramMediaPagingEntity *)entity andIndexPath:(NSIndexPath *)index;

@end
