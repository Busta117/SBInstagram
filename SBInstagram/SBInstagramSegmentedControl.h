//
//  SBInstagramSegmentedControl.h
//  SBInstagramExample
//
//  Created by Santiago Bustamante on 10/8/14.
//  Copyright (c) 2014 Busta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBInstagramSegmentedControl : UIControl


@property NSArray *items;
@property(nonatomic) NSInteger selectedSegmentIndex;
@property (nonatomic) UIColor *borderColor;



- (instancetype)initWithItems:(NSArray *)items;


@end


@interface UIImage (tint)

- (instancetype)tintedImageWithColor:(UIColor *)tintColor;

@end