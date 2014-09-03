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
    
    //init view controller
    SBInstagramCollectionViewController *instagram = [SBInstagramController instagramViewController];
    
    NSLog(@"framework version: %@",instagram.version);
    
    //both are optional, but if you need search by tag you need set both
    instagram.isSearchByTag = YES; //if you want serach by tag
    instagram.searchTag = @"colombia"; //search by tag query
    
    instagram.showOnePicturePerRow = YES; //to change way to show the feed, one picture per row(default = NO)
    
    instagram.showSwitchModeView = YES; //show a segment controller with view option
    
    [instagram refreshCollection]; //refresh instagram feed
    
    //push instagram view controller into navigation
    [self.navigationController pushViewController:instagram animated:YES];
    
    
}


@end
