//
//  HomeViewController.h
//  Red5ProiOS
//
//  Created by Andy Zupko on 10/9/14.
//  Copyright (c) 2014 Infrared5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"

@interface HomeViewController : UIViewController<SlideNavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *headerBar;
@end
