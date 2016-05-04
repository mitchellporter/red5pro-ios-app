//
//  HelpDialogViewController.h
//  Red5ProiOS
//
//  Created by Todd Anderson on 11/6/14.
//  Copyright (c) 2014 Infrared5. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpDialogViewController : UIViewController<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *helpTextView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end
