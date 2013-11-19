//
//  SBInstagramCell.m
//  instagram
//
//  Created by Santiago Bustamante on 8/31/13.
//  Copyright (c) 2013 Pineapple Inc. All rights reserved.
//

#import "SBInstagramCell.h"
#import "SBInstagramImageViewController.h"

@implementation SBInstagramCell

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [imageButton setFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        [imageButton addTarget:self action:@selector(selectedImage:) forControlEvents:UIControlEventTouchUpInside];
        [imageButton setImage:[UIImage imageNamed:@"InstagramLoading.png"] forState:UIControlStateNormal];
        [self.contentView addSubview:imageButton];
        _imageButton = imageButton;
    }
    return self;
}


-(void)setEntity:(SBInstagramMediaPagingEntity *)entity andIndexPath:(NSIndexPath *)index{
    [self.imageButton setImage:[UIImage imageNamed:@"InstagramLoading.png"] forState:UIControlStateNormal];
    _entity = entity;
    
    SBInstagramImageEntity *imgEntity = entity.mediaEntity.images[@"low_resolution"];
    
    [imgEntity downloadImageWithBlock:^(UIImage *image, NSError *error) {
        if (self.indexPath.row == index.row) {
            [self.imageButton setImage:image forState:UIControlStateNormal];
        }
    }];
    
}

-(void) selectedImage:(id)selector{
    
    UIViewController *viewCon = (UIViewController *)self.nextResponder;
    
    while (![viewCon isKindOfClass:[UINavigationController class]]) {
        viewCon = (UIViewController *)viewCon.nextResponder;
    }
    
    SBInstagramImageEntity *imgEntity = self.entity.mediaEntity.images[@"standard_resolution"];
    
    SBInstagramImageViewController *img = [SBInstagramImageViewController imageViewerWithEntity:imgEntity];
    
    [((UINavigationController *)viewCon) pushViewController:img animated:YES];
    
}


@end
