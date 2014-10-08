//
//  SBInstagramCollectionViewController.h
//  instagram
//
//  Created by Santiago Bustamante on 8/31/13.
//  Copyright (c) 2013 Busta117. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBInstagramCell.h"
#import "SBInstagramRefreshControl.h"
#import "SBInstagramSegmentedControl.h"

#define SB_IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define SB_showAlert(Title, Message, CancelButton) UIAlertView * alert = [[UIAlertView alloc] initWithTitle:Title message:Message delegate:nil cancelButtonTitle:CancelButton otherButtonTitles:nil, nil]; \
[alert show];



@interface SBInstagramCollectionViewController : UICollectionViewController
{
    SBInstagramRefreshControl *refreshControl_;
    SBInstagramSegmentedControl *segmentedControl_;
    BOOL loaded_;
}
@property (nonatomic, readonly) NSString *version;

@property (nonatomic, assign) BOOL isSearchByTag;
@property (nonatomic, strong) NSString *searchTag;

@property (nonatomic, assign) BOOL showOnePicturePerRow;
@property (nonatomic, assign) BOOL showSwitchModeView;

- (void) refreshCollection;
+(NSString *)appVersion;
@end
