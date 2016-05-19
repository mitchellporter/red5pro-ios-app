//
//  SideNavigationViewController.h
//  Red5Pro
//
//  Created by Kyle Kellogg on 5/12/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideNavigationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *helpBtn;
@property (weak, nonatomic) IBOutlet UIButton *publishBtn;
@property (weak, nonatomic) IBOutlet UIButton *serverBtn;
@property (weak, nonatomic) IBOutlet UIButton *subscribeBtn;
@property (weak, nonatomic) IBOutlet UIButton *twoWayBtn;

@end
