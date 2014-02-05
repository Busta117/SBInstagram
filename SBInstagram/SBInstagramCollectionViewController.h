//
//  SBInstagramCollectionViewController.h
//  instagram
//
//  Created by Santiago Bustamante on 8/31/13.
//  Copyright (c) 2013 Pineapple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBInstagramCell.h"

#define SB_IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define SB_showAlert(Title, Message, CancelButton) UIAlertView * alert = [[UIAlertView alloc] initWithTitle:Title message:Message delegate:nil cancelButtonTitle:CancelButton otherButtonTitles:nil, nil]; \
[alert show];



@interface SBInstagramCollectionViewController : UICollectionViewController


@property (nonatomic, assign) BOOL isSearchByTag;
@property (nonatomic, strong) NSString *searchTag;



@end
