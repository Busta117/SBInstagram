//
//  SBInstagramWevViewController.m
//  instagram
//
//  Created by Santiago Bustamante on 8/28/13.
//  Copyright (c) 2013 Busta117. All rights reserved.
//

#import "SBInstagramWebViewController.h"
#import "SBInstagramController.h"
#import "SBInstagramModel.h"

#define SB_SYSTEM_VERSION_GREATER_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)

@interface SBInstagramWebViewController ()

@end

@implementation SBInstagramWebViewController

+ (id) webViewWithUrl:(NSString *)url andSuccessBlock:(void (^)(NSString *token, UIViewController *viewController))block{
    SBInstagramWebViewController *instance = [[SBInstagramWebViewController alloc] initWithNibName:@"SBInstagramWebViewController" bundle:nil];
    instance.url = url;
    instance.block = block;
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
    
    self.title = @"Instagram";
    
    NSURL *urlns = [NSURL URLWithString:self.url];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlns];
    [self.webView loadRequest:request];
    
    [self.webView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIScrollView class]]) {
            [((UIScrollView *)obj) setBounces:NO];
        }
    }];
    
    if ([UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleDefault && ![UIApplication sharedApplication].statusBarHidden && SB_SYSTEM_VERSION_GREATER_THAN(@"6.9")) {
        CGRect frame = self.webView.frame;
        frame.origin.y += 20;
        self.webView.frame = frame;
    }
    
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.activityIndicator stopAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString *redirectUrl = [SBInstagramModel model].instagramRedirectUri ?: INSTAGRAM_REDIRECT_URI;
    
    if ([request.URL.absoluteString hasPrefix:redirectUrl]) {
        NSString *token = [[request URL] fragment];
        NSArray *arr = [token componentsSeparatedByString:@"="];
        token = [arr objectAtIndex:1];
        self.block(token,self);
        self.block = nil;
        return NO;
        
    }
    
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
