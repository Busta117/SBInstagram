//
//  FirstViewController.m
//  SBInstagramDataSourceExample
//
//  Created by Santiago Bustamante on 9/29/14.
//  Copyright (c) 2014 busta. All rights reserved.
//

#import "FirstViewController.h"
#import "AFNetworking.h"
#import "SBInstagramController.h"
#import "UIImageView+AFNetworking.h"
#import "LikersTableViewController.h"

@interface FirstViewController ()

@property SBInstagramController *instagramController;

 @property BOOL downloading;

@property NSArray * tagsArray;
@property NSArray * lastEntities;
@property NSMutableArray *currentEntities;

@property (nonatomic, strong) NSArray * likers;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    self.currentEntities = [NSMutableArray array];
    
    //here create the instagram data source
    self.instagramController = [SBInstagramController dataSource];
    
    //setting up, data were taken from instagram app setting (www.instagram.com/developer)
    self.instagramController.instagramRedirectUri = @"http://www.santiagobustamante.info";
    self.instagramController.instagramClientSecret = @"dd9f687e1ffb4ff48ebc77188a14d283";
    self.instagramController.instagramClientId = @"436eb0b4692245c899091391eaa5cdf1";
    self.instagramController.instagramDefaultAccessToken = @"6874212.436eb0b.9768fd326f9b423eab7dd260972ee6db";
    self.instagramController.instagramMultipleUsersId = @[@"6874212"];
    self.instagramController.instagramMultipleTags = @[@"colombia", @"england", @"japan"];
    
    //get first elements
    [self.instagramController mediaMultiplesWithComplete:^(NSArray *mediaArray, NSArray *lastMedia, NSError *error) {
        if (!error) {
            self.currentEntities = [mediaArray mutableCopy];
            self.lastEntities = lastMedia;
            [self.tableView reloadData];
        }else{
            NSLog(@"error: %@", error.localizedDescription);
        }

    }];
    
    
}

- (void) downloadNext{
    self.downloading = YES;
    
    //get pages
    [self.instagramController mediaMultiplePagingWithArr:self.lastEntities complete:^(NSArray *mediaArray, NSArray *lastMedia, NSError *error) {
        self.downloading = NO;
        if (!error) {
            [self.currentEntities addObjectsFromArray:mediaArray];
            self.lastEntities = lastMedia;
            [self.tableView reloadData];
        }else{
           NSLog(@"error: %@", error.localizedDescription);
        }
    }];

}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.currentEntities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"instaSampleCell"];
    
    SBInstagramMediaEntity *entity = ((SBInstagramMediaPagingEntity *)self.currentEntities[indexPath.row]).mediaEntity;
    
    SBInstagramImageEntity *imageEntity = entity.images[SBInstagramImageThumbnailKey];
//    SBInstagramImageEntity *imageEntity = entity.images[SBInstagramImageLowResolutionKey];
//    SBInstagramImageEntity *imageEntity = entity.images[SBInstagramImageStandardResolutionKey];
    
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:imageEntity.url] placeholderImage:[UIImage imageNamed:@"SBInstagramLoading.png"]];
    cell.textLabel.text = entity.userName;
    cell.detailTextLabel.text = entity.caption ?: @"";
    
    
    if (indexPath.row == self.currentEntities.count - 1 && !self.downloading) {
        [self downloadNext];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SBInstagramMediaEntity *entity = ((SBInstagramMediaPagingEntity *)self.currentEntities[indexPath.row]).mediaEntity;
    
    [self.instagramController likersFromMediaEntity:entity complete:^(NSMutableArray *likers, NSError *error) {
        self.likers = likers;
        if (!error) {
            if (likers.count > 0) {
                [self performSegueWithIdentifier:@"likers" sender:nil];
            }
        }
        
    }];
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"likers"]) {
        LikersTableViewController *likersVC = segue.destinationViewController;
        likersVC.likersArray = self.likers;
    }
    
}


@end
