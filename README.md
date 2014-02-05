SBInstagram v1.2
===========

Easy Objective-C framework to show an instagram feed, initially only shows the pictures and the videos preview(picture). 

**if you don't setup an access token or the existing one expire, this framework request a new one with the login view.**


Setup
===========


to setup your Application only change the file ***SBInstagramController.h***, setup with all of your Instagram application information.

to initialize add the following code.

	//init view controller
	SBInstagramCollectionViewController *instagram = [SBInstagramController instagramViewController];
    
    //both are optional, but if you need search by tag you need set both
    instagram.isSearchByTag = YES; //if you want serach by tag
    instagram.searchTag = @"colombia"; //search by tag query
    
	//push instagram view controller into navigation
	[self.navigationController pushViewController:instagram animated:YES];
	


===========  
this framework needs the **AFNetworking v1.x** to support iOS 6  
this framework support **iOS 6 and above**   
this is a Xcode 5 project


Change Log
===========

**v1.2**
- add support for search by tag
- new way to init the instagram view controller

**v1.1**
- load all instagram photos per demand (lazy loading)
- add a loading animation
- add caption field in the picture detail
- remove PSTCollectionView framework (remove iOS 5 support)


**v1.0**
- firts version


