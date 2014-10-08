//
//  SBInstagramWevViewController.h
//  instagram
//
//  Created by Santiago Bustamante on 8/28/13.
//  Copyright (c) 2013 Busta117. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBInstagramWebViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSString *url;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) void (^block)(NSString *token, UIViewController *viewController);


+ (id) webViewWithUrl:(NSString *)url andSuccessBlock:(void (^)(NSString *token, UIViewController *viewController))block;

@end
