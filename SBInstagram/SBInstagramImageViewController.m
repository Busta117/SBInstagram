//
//  SBInstagramImageViewController.m
//  MedellinHipHop
//
//  Created by Santiago Bustamante on 9/2/13.
//  Copyright (c) 2013 Pineapple Inc. All rights reserved.
//

#import "SBInstagramImageViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface SBInstagramImageViewController ()

@end

@implementation SBInstagramImageViewController


+ (id) imageViewerWithEntity:(SBInstagramImageEntity *)entity{
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGPoint center = self.imageView.center;
    
    CGRect frame = self.imageView.frame;
    frame.size = CGSizeMake(CGRectGetWidth([[UIScreen mainScreen] applicationFrame]), CGRectGetWidth([[UIScreen mainScreen] applicationFrame]));
    [self.imageView setFrame:frame];
    
    [self.imageView setCenter:center];
    
    
    
    self.title = @"";
    
    [SBInstagramModel downloadImageWithUrl:self.entity.url andBlock:^(UIImage *image, NSError *error) {
        if (image && !error) {
            [self.imageView setImage:image];
        }
    }];
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
