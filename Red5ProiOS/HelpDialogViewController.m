//
//  HelpDialogViewController.m
//  Red5ProiOS
//
//  Created by Todd Anderson on 11/6/14.
//  Copyright (c) 2014 Infrared5. All rights reserved.
//

#import "HelpDialogViewController.h"
#import <R5Streaming/R5Streaming.h>

@interface HelpDialogViewController ()
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation HelpDialogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    NSString *formattedStr = [NSString stringWithFormat:@"v%@ - SDK %s", bundleVersion, R5PRO_VERSION ];
    
    [self.versionLabel setText:formattedStr];
    
    // Create URL from HTML file in application bundle
    NSURL *html = [[NSBundle mainBundle] URLForResource: @"help" withExtension:@"html"];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:html]];
}

- (IBAction)dismiss:(id)sender {
    [UIView animateWithDuration:0.3f animations:^{
        self.view.alpha = 0.0f;
    } completion: ^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL isFileURL]) {
        return YES;
    }
    
    [[UIApplication sharedApplication] openURL:request.URL];
    return NO;
}

@end
