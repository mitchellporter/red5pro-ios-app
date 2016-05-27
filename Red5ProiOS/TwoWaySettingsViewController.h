//
//  TwoWaySettingsViewController.h
//  Red5Pro
//
//  Created by Kyle Kellogg on 5/3/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StreamListUtility.h"
#import "SlideNavigationController.h"

@interface TwoWaySettingsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, listListener, SlideNavigationControllerDelegate>

@property enum StreamMode currentMode;

@property (weak, nonatomic) IBOutlet UITextField *stream;

@property (weak, nonatomic) IBOutlet UITableView *table;

@property (weak, nonatomic) IBOutlet UIButton *subscribeBtn;

@property (weak, nonatomic) IBOutlet UILabel *streamsAvailableLbl;

@end