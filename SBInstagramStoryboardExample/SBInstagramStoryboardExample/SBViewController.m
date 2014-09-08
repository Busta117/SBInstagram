//
//  SBViewController.m
//  SBInstagramStoryboardExample
//
//  Created by Santiago Bustamante on 9/2/14.
//  Copyright (c) 2014 Busta. All rights reserved.
//

#import "SBViewController.h"
#import "SBInstagramCollectionViewController.h"
#import "SBInstagramController.h"

@interface SBViewController ()

@end

@implementation SBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showInstagramAction:(id)sender {
    
    //here create the instagram view
    SBInstagramController *instagram = [SBInstagramController instagram];
    
    //setting up, data got from instagram app setting (www.instagram.com/developer)
    instagram.instagramRedirectUri = @"http://www.santiagobustamante.info";
    instagram.instagramClientSecret = @"dd9f687e1ffb4ff48ebc77188a14d283";
    instagram.instagramClientId = @"436eb0b4692245c899091391eaa5cdf1";
    instagram.instagramDefaultAccessToken = @"6874212.436eb0b.9768fd326f9b423eab7dd260972ee6db";
    instagram.instagramUserId = @"6874212";
    
    //both are optional, but if you need search by tag you need set both
    instagram.isSearchByTag = YES; //if you want serach by tag
    instagram.searchTag = @"colombia"; //search by tag query
    
//    instagram.showOnePicturePerRow = YES; //to change way to show the feed, one picture per row(default = NO)
    
    instagram.showSwitchModeView = YES; //show a segment controller with view option
    
    instagram.loadingImageName = @"SBInstagramLoading"; //config a custom loading image
    instagram.videoPlayImageName = @"SBInsta_play";
    instagram.videoPauseImageName = @"SBInsta_pause";
    instagram.playStandardResolution = YES; //if you want play a regular resuluton, low resolution per default
    
    
//    [instagram refreshCollection]; //refresh instagram feed
    
    NSLog(@"framework version: %@",instagram.version);
    
    //push instagram view controller into navigation
    [self.navigationController pushViewController:instagram.feed animated:YES];
    
    
}


@end
