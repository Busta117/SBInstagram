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


+ (id) imageViewerWithEntity:(SBInstagramMediaEntity *)entity{
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
    
    SBInstagramImageEntity *picEntity = self.entity.images[@"standard_resolution"];
    
    [SBInstagramModel downloadImageWithUrl:picEntity.url andBlock:^(UIImage *image, NSError *error) {
        [self.activityIndicator stopAnimating];
        if (image && !error) {
            [self.imageView setImage:image];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something is wrong" message:@"Please check your Internet connection and try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
    
    self.captionLabel.text = self.entity.caption;
    
}


#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
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
