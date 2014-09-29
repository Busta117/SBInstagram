SBInstagram v2.1.0
===========

Easy Objective-C framework to show an instagram feed, initially only shows the pictures and the videos preview(picture). 

if you need this working with AFNetworking v1.x use [version 1.3](https://github.com/Busta117/SBInstagram/releases/tag/v1.3)


**if you don't setup an access token or the existing one expire, this framework request a new one with the login view.**


Setup
===========

* You need add the ***AVFoundation.framework*** to your project


* to initialize and setup the ***default views*** add the following code.

```objective-c
//init controller
SBInstagramController *instagram = [SBInstagramController instagram];
    
//setting up, data were taken from instagram app setting (www.instagram.com/developer)
instagram.instagramRedirectUri = @"http://www.santiagobustamante.info";
instagram.instagramClientSecret = @"dd9f687e1ffb4ff48ebc77188a14d283";
instagram.instagramClientId = @"436eb0b4692245c899091391eaa5cdf1";
instagram.instagramDefaultAccessToken = @"6874212.436eb0b.9768fd326f9b423eab7dd260972ee6db";
instagram.instagramUserId = @"6874212"; //if you want request the feed of one user
    
//both are optional, but if you need search by tag you need set both
instagram.isSearchByTag = YES; //if you want serach by tag
instagram.searchTag = @"colombia"; //search by tag query

//multiple users id or multiple tags (not both)
instagram.instagramMultipleUsersId = @[@"386407356",@"6874212"];
instagram.instagramMultipleTags = @[@"sea",@"ground",@"fire"]; //if you set this you don't need set isSearchByTag in true
    
instagram.showOnePicturePerRow = YES; //to change way to show the feed, one picture per row(default = NO)
    
instagram.showSwitchModeView = YES; //show a segment controller with view option (default = NO)
    
instagram.loadingImageName = @"SBInstagramLoading"; //config a custom loading image
instagram.videoPlayImageName = @"SBInsta_play"; //config a custom video play image
instagram.videoPauseImageName = @"SBInsta_pause"; //config a custom video pause image
instagram.playStandardResolution = YES; //if you want play a standard resuluton, low resolution per default
    
[instagram refreshCollection]; //refresh instagram feed
		
//push instagram view controller into navigation
[self.navigationController pushViewController:instagram.feed animated:YES];
```

* to initialize and setup ***only the data source*** add the following code (you can check the project named ***"SBInstagramDataSourceExample"***):

```objective-c

SBInstagramController *instagram = [SBInstagramController dataSource];
    
//setting up, data were taken from instagram app setting (www.instagram.com/developer)
instagram.instagramRedirectUri = @"http://www.santiagobustamante.info";
instagram.instagramClientSecret = @"dd9f687e1ffb4ff48ebc77188a14d283";
instagram.instagramClientId = @"436eb0b4692245c899091391eaa5cdf1";
instagram.instagramDefaultAccessToken = @"6874212.436eb0b.9768fd326f9b423eab7dd260972ee6db";

self.instagramController.instagramMultipleUsersId = @[@"6874212"]; //here you can set 1 or more
self.instagramController.instagramMultipleTags = @[@"colombia", @"england", @"japan"]; //here you can set 1 or more


//to download media you need execute this methods

/* first you need download the initial elements, use this method
 /mediaArray: array of *SBInstagramMediaPagingEntity* 
 /lastMedia: array of the last object (SBInstagramMediaPagingEntity), this is for the pagging
 /error: if anything is wrong
*/
- (void) mediaMultiplesWithComplete:(void (^)(NSArray *mediaArray,NSArray *lastMedia, NSError * error))block;


/* to download the next page you need use this method
 /entites: this is the lastMedia array you saved in the last call
 /mediaArray: array of *SBInstagramMediaPagingEntity* 
 /lastMedia: array of the last object (SBInstagramMediaPagingEntity), this is for the pagging
 /error: if anything is wrong
*/
- (void) mediaMultiplePagingWithArr:(NSArray *)entites complete:(void (^)(NSArray *mediaArray,NSArray *lastMedia, NSError * error))block;

```



===========  
- this framework needs the **AFNetworking v2.x**
- this framework support **iOS 6 and above**   
- this is a Xcode 6 project (Xcode 5 compatibility)
- iOS8 compatibility
- examples with and without storyboard


Change Log
===========
**v2.1.0**
- download only data to customezed views
- data source example with a custom view

**v2.0.3**
- video player completely redesigned, bugs fixed

**v2.0.2**
- bugs fixed in video player
- multiple users feed
- multiple hast tags search

**v2.0.0**
- Play videos inline in the feed and in the pic detail
- Another option to setup
- Images customized

**v1.4.1**
- create a method to refresh the instragram feed

**v1.4**
- upgrade AFNetworking framework, now use **AFNetworking v2.x**
- username and user picture in the image detail view

**v1.3**
- add new way to show the feed, one picture per row

**v1.2**
- add support for search by tag
- new way to init the instagram view controller

**v1.1**
- load all instagram photos per demand (lazy loading)
- add a loading animation
- add caption field in the picture detail
- remove PSTCollectionView framework (remove iOS 5 support)


**v1.0**
- first version

####feedback?

* twitter: [@busta117](http://www.twitter.com/busta117)
* mail: <busta117@gmail.com>
* <http://www.santiagobustamante.info>

